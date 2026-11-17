import tempfile
import unittest
from pathlib import Path

from tools.sync_jungle import (
    BEGIN_MARKER,
    END_MARKER,
    SyncError,
    generated_lines,
    manifest_device_ids,
    synchronize_text,
)


def device(device_id, *, touch, api, colors):
    return {
        "Id": device_id,
        "Touch": touch,
        "APILevel": api,
        "DisplayColors": str(colors),
    }


class JungleSyncTests(unittest.TestCase):
    def test_device_capability_thresholds(self):
        ids = ["old_touch", "at_420", "above_420", "no_touch"]
        specs = [
            device("old_touch", touch=True, api="4.1", colors=65536),
            device("at_420", touch=True, api="4.2.0", colors=64),
            device("above_420", touch=True, api="4.2.1", colors=65536),
            device("no_touch", touch=False, api="5.0", colors=64),
        ]

        output = generated_lines(ids, specs)

        self.assertIn(
            "old_touch.excludeAnnotations = onPressComplication;mipDisplay", output
        )
        self.assertIn("at_420.excludeAnnotations = onPressComplication", output)
        self.assertNotIn(
            "above_420.excludeAnnotations = onPressComplication;mipDisplay", output
        )
        self.assertIn("above_420.excludeAnnotations = mipDisplay", output)
        self.assertIn("no_touch.excludeAnnotations = onPressComplication", output)
        for device_id in ("at_420", "above_420"):
            self.assertIn(
                f"{device_id}.resourcePath = $({device_id}.resourcePath);resources-complication",
                output,
            )
        self.assertFalse(
            any(line.startswith("old_touch.resourcePath =") for line in output)
        )
        self.assertFalse(
            any(line.startswith("no_touch.resourcePath =") for line in output)
        )

    def test_legacy_jungle_is_migrated_and_unrelated_content_preserved(self):
        legacy = (
            "project.manifest = manifest.xml\r\n"
            "custom.setting = enabled\r\n"
            "at_420.excludeAnnotations = mipDisplay\r\n"
            "at_420.resourcePath = $(at_420.resourcePath);resources-complication\r\n"
            "unrelated.excludeAnnotations = customAnnotation\r\n"
        )
        specs = [device("at_420", touch=True, api="4.2", colors=64)]

        result = synchronize_text(legacy, ["at_420"], specs)

        self.assertIn("custom.setting = enabled\r\n", result)
        self.assertIn("unrelated.excludeAnnotations = customAnnotation\r\n", result)
        self.assertIn(BEGIN_MARKER, result)
        self.assertIn(END_MARKER, result)
        self.assertIn("at_420.excludeAnnotations = onPressComplication\r\n", result)
        self.assertEqual(result.count("at_420.resourcePath ="), 1)
        self.assertNotIn("\n", result.replace("\r\n", ""))

    def test_synchronization_is_idempotent(self):
        specs = [device("touch", touch=True, api="5.1", colors=65536)]
        first = synchronize_text(
            "project.manifest = manifest.xml\n"
            "base.excludeAnnotations = onPressComplication;mipDisplay;custom\n",
            ["touch"],
            specs,
        )

        self.assertEqual(first, synchronize_text(first, ["touch"], specs))
        self.assertIn("base.excludeAnnotations = custom\n", first)
        self.assertNotIn("base.excludeAnnotations = onPressComplication", first)

    def test_manifest_product_ids_are_parsed_and_duplicates_rejected(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            manifest = Path(temporary_directory) / "manifest.xml"
            manifest.write_text(
                '<iq:manifest xmlns:iq="urn:test"><iq:products>'
                '<iq:product id="one"/><iq:product id="two"/>'
                "</iq:products></iq:manifest>",
                encoding="utf-8",
            )
            self.assertEqual(manifest_device_ids(manifest), ["one", "two"])

            manifest.write_text(
                '<iq:manifest xmlns:iq="urn:test"><iq:products>'
                '<iq:product id="one"/><iq:product id="one"/>'
                "</iq:products></iq:manifest>",
                encoding="utf-8",
            )
            with self.assertRaisesRegex(SyncError, "duplicate product IDs"):
                manifest_device_ids(manifest)

    def test_missing_specs_fail_before_generation(self):
        with self.assertRaisesRegex(SyncError, "No device specs found"):
            generated_lines(
                ["missing"], [device("other", touch=True, api="5.1", colors=64)]
            )


if __name__ == "__main__":
    unittest.main()
