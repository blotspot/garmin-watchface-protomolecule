#!/usr/bin/env python3
"""Synchronize device-specific jungle settings from Garmin device specs."""

from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "manifest.xml"
DEFAULT_JUNGLE = ROOT / "monkey.jungle"
DEFAULT_SPECS_URL = (
    "https://github.com/blotspot/garmin-device-specs/releases/latest/download/"
    "garmin_devices.json"
)
BEGIN_MARKER = "# BEGIN GENERATED DEVICE CONFIG"
END_MARKER = "# END GENERATED DEVICE CONFIG"
MANAGED_ASSIGNMENT = re.compile(
    r"^([A-Za-z0-9_]+)\.(excludeAnnotations|resourcePath|lang\.deu|lang\.fre)\s*="
)
API_VERSION = re.compile(r"^\d+(?:\.\d+)*$")


class SyncError(Exception):
    """Raised when input device data cannot safely drive jungle generation."""


def load_specs(path: Path | None, url: str = DEFAULT_SPECS_URL) -> list[dict[str, Any]]:
    if path is not None:
        raw = path.read_bytes()
    else:
        request = urllib.request.Request(
            url,
            headers={"User-Agent": "garmin-watchface-jungle-sync/1.0"},
        )
        with urllib.request.urlopen(request, timeout=30) as response:
            raw = response.read()

    try:
        specs = json.loads(raw)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise SyncError(f"Device specs are not valid JSON: {error}") from error

    if not isinstance(specs, list) or not all(isinstance(item, dict) for item in specs):
        raise SyncError("Device specs must be a JSON array of device objects.")
    return specs


def manifest_device_ids(path: Path) -> list[str]:
    try:
        root = ET.parse(path).getroot()
    except (ET.ParseError, OSError) as error:
        raise SyncError(f"Cannot read manifest {path}: {error}") from error

    ids = [
        product.attrib.get("id", "")
        for product in root.iter()
        if product.tag.rsplit("}", 1)[-1] == "product"
    ]
    if not ids or any(not device_id for device_id in ids):
        raise SyncError("Manifest must contain products with non-empty IDs.")
    duplicates = sorted({device_id for device_id in ids if ids.count(device_id) > 1})
    if duplicates:
        raise SyncError(
            "Manifest contains duplicate product IDs: " + ", ".join(duplicates)
        )
    return ids


def _api_version(value: Any, device_id: str) -> tuple[int, ...]:
    version = str(value)
    if not API_VERSION.fullmatch(version):
        raise SyncError(f"Device {device_id} has invalid APILevel {value!r}.")
    return tuple(int(part) for part in version.split("."))


def _compare_versions(left: tuple[int, ...], right: tuple[int, ...]) -> int:
    width = max(len(left), len(right))
    left = left + (0,) * (width - len(left))
    right = right + (0,) * (width - len(right))
    return (left > right) - (left < right)


def generated_lines(device_ids: list[str], specs: list[dict[str, Any]]) -> list[str]:
    specs_by_id: dict[str, dict[str, Any]] = {}
    for device in specs:
        device_id = device.get("Id")
        if not isinstance(device_id, str) or not device_id:
            raise SyncError("Every device spec must have a non-empty Id.")
        if device_id in specs_by_id:
            raise SyncError(f"Device specs contain duplicate ID {device_id}.")
        specs_by_id[device_id] = device

    output = [BEGIN_MARKER]
    missing = [device_id for device_id in device_ids if device_id not in specs_by_id]
    if missing:
        raise SyncError("No device specs found for manifest IDs: " + ", ".join(missing))

    for device_id in device_ids:
        device = specs_by_id[device_id]
        touch = device.get("Touch")
        if not isinstance(touch, bool):
            raise SyncError(f"Device {device_id} has invalid Touch value {touch!r}.")
        try:
            colors = int(device["DisplayColors"])
        except (KeyError, TypeError, ValueError) as error:
            raise SyncError(f"Device {device_id} has invalid DisplayColors.") from error

        api = _api_version(device.get("APILevel"), device_id)
        api_minimum = _compare_versions(api, (4, 2, 0))
        excluded: list[str] = []
        if not touch or api_minimum < 0:
            excluded.append("onPressComplication")
        if colors > 64:
            excluded.append("mipDisplay")
        if excluded:
            output.append(f"{device_id}.excludeAnnotations = {';'.join(excluded)}")

        if touch and api_minimum >= 0:
            output.extend(
                [
                    f"{device_id}.resourcePath = $({device_id}.resourcePath);resources-complication",
                    f"{device_id}.lang.deu = $({device_id}.lang.deu);resources-complication-deu",
                    f"{device_id}.lang.fre = $({device_id}.lang.fre);resources-complication-fre",
                ]
            )

    output.append(END_MARKER)
    return output


def synchronize_text(
    text: str, device_ids: list[str], specs: list[dict[str, Any]]
) -> str:
    newline = "\r\n" if "\r\n" in text else "\n"
    had_trailing_newline = text.endswith(("\n", "\r"))
    lines = text.splitlines()
    generated = generated_lines(device_ids, specs)
    # Global exclusions would also disable annotations on devices that support them.
    cleaned_lines = []
    for line in lines:
        if line.startswith("base.excludeAnnotations = "):
            annotations = [
                annotation
                for annotation in line.partition("=")[2].strip().split(";")
                if annotation
                and annotation not in {"onPressComplication", "mipDisplay"}
            ]
            if annotations:
                line = "base.excludeAnnotations = " + ";".join(annotations)
            else:
                continue
        cleaned_lines.append(line)
    lines = cleaned_lines

    begin_positions = [
        index for index, line in enumerate(lines) if line == BEGIN_MARKER
    ]
    end_positions = [index for index, line in enumerate(lines) if line == END_MARKER]
    if begin_positions or end_positions:
        if len(begin_positions) != 1 or len(end_positions) != 1:
            raise SyncError("Jungle generated block markers are missing or duplicated.")
        begin, end = begin_positions[0], end_positions[0]
        if begin >= end:
            raise SyncError("Jungle generated block markers are out of order.")
        lines[begin : end + 1] = generated
    else:
        managed_ids = set(device_ids)
        lines = [
            line
            for line in lines
            if not (
                (match := MANAGED_ASSIGNMENT.match(line))
                and match.group(1) in managed_ids
            )
        ]
        if lines and lines[-1]:
            lines.append("")
        lines.extend(generated)

    result = newline.join(lines)
    if had_trailing_newline:
        result += newline
    return result


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--jungle", type=Path, default=DEFAULT_JUNGLE)
    parser.add_argument(
        "--specs-file",
        type=Path,
        help="Use a local device JSON instead of downloading.",
    )
    parser.add_argument("--specs-url", default=DEFAULT_SPECS_URL)
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit non-zero if jungle needs synchronization; do not write files.",
    )
    args = parser.parse_args(argv)

    try:
        ids = manifest_device_ids(args.manifest)
        specs = load_specs(args.specs_file, args.specs_url)
        current = args.jungle.read_bytes().decode("utf-8")
        expected = synchronize_text(current, ids, specs)
    except (OSError, UnicodeDecodeError, SyncError, urllib.error.URLError) as error:
        print(f"sync-jungle: error: {error}", file=sys.stderr)
        return 2

    if current == expected:
        print("Jungle device configuration is up to date.")
        return 0
    if args.check:
        print(
            "Jungle device configuration is out of date. Run tools/sync_jungle.py.",
            file=sys.stderr,
        )
        return 1

    args.jungle.write_bytes(expected.encode("utf-8"))
    print(f"Updated {args.jungle} for {len(ids)} manifest devices.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
