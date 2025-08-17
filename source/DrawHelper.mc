import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;

module Format {
  const INT_ZERO = "%02d";
  const INT = "%i";
  const FLOAT = "%2.0d";
}

module LayoutId {
  const ORBIT = 0;
  const CIRCLES = 1;
}

module FieldId {
  const NO_PROGRESS_1 = 0;
  const NO_PROGRESS_2 = 1;
  const NO_PROGRESS_3 = 2;
  const ORBIT_OUTER = 3;
  const ORBIT_LEFT = 4;
  const ORBIT_RIGHT = 5;
  const OUTER = 6;
  const UPPER_1 = 7;
  const UPPER_2 = 8;
  const LOWER_1 = 9;
  const LOWER_2 = 10;
  const SLEEP_BATTERY = 11;
  const SLEEP_HR = 12;
  const SLEEP_ALARMS = 13;
  const SLEEP_NOTIFY = 14;
  const DATE_AND_TIME = 15;
}

module FieldType {
  const NOTHING = 0;
  const STEPS = 1;
  const BATTERY = 2;
  const CALORIES = 3;
  const ACTIVE_MINUTES = 4;
  const HEART_RATE = 5;
  const NOTIFICATION = 6;
  const FLOORS_UP = 7;
  const FLOORS_DOWN = 8;
  const BLUETOOTH = 9;
  const ALARMS = 10;
  const BODY_BATTERY = 11;
  const SECONDS = 12;
  const STRESS_LEVEL = 13;
  const ACTIVE_CALORIES = 14;
}

module Color {
  const TEXT_ACTIVE as Number = 0;
  const TEXT_INACTIVE as Number = 1;
  const PRIMARY as Number = 2;
  const SECONDARY_1 as Number = 3;
  const SECONDARY_2 as Number = 4;
  const BACKGROUND as Number = 5;
  const FOREGROUND as Number = 6;
  const INACTIVE as Number = 7;

  const MAX_COLOR_ID as Number = 8;

  const _COLORS as Array<ColorType> = [
    /* EXPANSE */
    Graphics.COLOR_WHITE, // TEXT_ACTIVE
    Graphics.COLOR_LT_GRAY, // TEXT_INACTIVE
    Graphics.COLOR_YELLOW, // PRIMARY
    Graphics.COLOR_BLUE, // SECONDARY_1
    Graphics.COLOR_RED, // SECONDARY_2
    Graphics.COLOR_BLACK, // BACKGROUND
    Graphics.COLOR_WHITE, // FOREGROUND
    Graphics.COLOR_DK_GRAY, // INACTIVE,
    /* EARTH */
    Graphics.COLOR_WHITE, // TEXT_ACTIVE
    Graphics.COLOR_LT_GRAY, // TEXT_INACTIVE
    0x0055aa, // PRIMARY
    Graphics.COLOR_BLUE, // SECONDARY_1
    Graphics.COLOR_BLUE, // SECONDARY_2
    Graphics.COLOR_BLACK, // BACKGROUND
    Graphics.COLOR_WHITE, // FOREGROUND
    Graphics.COLOR_DK_GRAY, // INACTIVE
    /* MARS */
    Graphics.COLOR_WHITE, // TEXT_ACTIVE
    Graphics.COLOR_LT_GRAY, // TEXT_INACTIVE
    Graphics.COLOR_RED, // PRIMARY
    Graphics.COLOR_ORANGE, // SECONDARY_1
    Graphics.COLOR_ORANGE, // SECONDARY_2
    Graphics.COLOR_BLACK, // BACKGROUND
    Graphics.COLOR_WHITE, // FOREGROUND
    Graphics.COLOR_DK_GRAY, // INACTIVE
    /* BELT */
    Graphics.COLOR_WHITE, // TEXT_ACTIVE
    Graphics.COLOR_LT_GRAY, // TEXT_INACTIVE
    Graphics.COLOR_YELLOW, // PRIMARY
    0xffff00, // SECONDARY_1
    0xffff00, // SECONDARY_2
    Graphics.COLOR_BLACK, // BACKGROUND
    Graphics.COLOR_WHITE, // FOREGROUND
    Graphics.COLOR_DK_GRAY, // INACTIVE
    /* EXPANSE (Light) */
    Graphics.COLOR_BLACK, // TEXT_ACTIVE
    Graphics.COLOR_DK_GRAY, // TEXT_INACTIVE
    Graphics.COLOR_YELLOW, // PRIMARY
    Graphics.COLOR_BLUE, // SECONDARY_1
    Graphics.COLOR_BLUE, // SECONDARY_2
    Graphics.COLOR_WHITE, // BACKGROUND
    Graphics.COLOR_BLACK, // FOREGROUND
    Graphics.COLOR_LT_GRAY, // INACTIVE
    /* EARTH (Light) */
    Graphics.COLOR_BLACK, // TEXT_ACTIVE
    Graphics.COLOR_DK_GRAY, // TEXT_INACTIVE
    Graphics.COLOR_DK_BLUE, // PRIMARY
    Graphics.COLOR_BLUE, // SECONDARY_1
    Graphics.COLOR_BLUE, // SECONDARY_2
    Graphics.COLOR_WHITE, // BACKGROUND
    Graphics.COLOR_BLACK, // FOREGROUND
    Graphics.COLOR_LT_GRAY, // INACTIVE
  ];
}

function themeColor(sectionId as Number) as ColorType {
  var theme = Settings.get("theme") as Number;
  return Color._COLORS[theme * Color.MAX_COLOR_ID + sectionId];
}

function saveSetAntiAlias(dc as Graphics.Dc, enabled as Boolean) as Void {
  if (Graphics.Dc has :setAntiAlias) {
    dc.setAntiAlias(enabled);
  }
}

function saveClearClip(dc as Graphics.Dc) as Void {
  if (Graphics.Dc has :clearClip) {
    dc.clearClip();
  }
}
