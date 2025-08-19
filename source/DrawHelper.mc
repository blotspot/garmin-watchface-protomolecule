import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;

module Format {
  const INT_ZERO as String = "%02d";
  const INT as String = "%i";
  const FLOAT as String = "%2.0d";
}

module LayoutId {
  const ORBIT as Number = 0;
  const CIRCLES as Number = 1;
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
  ];
}

function themeColor(sectionId as Number) as ColorType {
  return Color._COLORS[(Settings.get(1) as Number) * Color.MAX_COLOR_ID + sectionId];
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
