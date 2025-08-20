import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application.Properties;

module Format {
  const INT_ZERO as String = "%02d";
  const INT as String = "%i";
}

module FieldId {
  const NO_PROGRESS_1 as Number = 0;
  const NO_PROGRESS_2 as Number = 1;
  const NO_PROGRESS_3 as Number = 2;
  const ORBIT_OUTER as Number = 3;
  const ORBIT_LEFT as Number = 4;
  const ORBIT_RIGHT as Number = 5;
  const OUTER as Number = 6;
  const UPPER_1 as Number = 7;
  const UPPER_2 as Number = 8;
  const LOWER_1 as Number = 9;
  const LOWER_2 as Number = 10;
  const SLEEP_BATTERY as Number = 11;
  const SLEEP_HR as Number = 12;
  const SLEEP_ALARMS as Number = 13;
  const SLEEP_NOTIFY as Number = 14;
  const DATE_AND_TIME as Number = 15;
}

module FieldType {
  const NOTHING as Number = 0;
  const STEPS as Number = 1;
  const BATTERY as Number = 2;
  const CALORIES as Number = 3;
  const ACTIVE_MINUTES as Number = 4;
  const HEART_RATE as Number = 5;
  const NOTIFICATION as Number = 6;
  const FLOORS_UP as Number = 7;
  const FLOORS_DOWN as Number = 8;
  const BLUETOOTH as Number = 9;
  const ALARMS as Number = 10;
  const BODY_BATTERY as Number = 11;
  const SECONDS as Number = 12;
  const STRESS_LEVEL as Number = 13;
  const ACTIVE_CALORIES as Number = 14;
}

module Color {
  const PRIMARY as Number = 0;
  const SECONDARY_1 as Number = 1;
  const SECONDARY_2 as Number = 2;

  const _COLORS as Array<ColorType> = [
    /* EXPANSE */
    0xffaa00, // PRIMARY
    0x00aaff, // SECONDARY_1
    0xff0000, // SECONDARY_2
    /* EARTH */
    0x00aaff, // PRIMARY
    0x0055ff, // SECONDARY_1
    0x0055ff, // SECONDARY_2
    /* MARS */
    0xff0000, // PRIMARY
    0xff5500, // SECONDARY_1
    0xff5500, // SECONDARY_2
    /* BELT */
    0xffaa00, // PRIMARY
    0xffff00, // SECONDARY_1
    0xffff00, // SECONDARY_2
  ];
}

function themeColor(sectionId as Number) as ColorType {
  return Color._COLORS[(Properties.getValue("theme") as Number) * 3 /* MAX_COLOR_ID */ + sectionId];
}

function saveSetAntiAlias(dc, enabled as Boolean) as Void {
  if (Graphics.Dc has :setAntiAlias) {
    dc.setAntiAlias(enabled);
  }
}

function saveClearClip(dc) as Void {
  if (Graphics.Dc has :clearClip) {
    dc.clearClip();
  }
}
