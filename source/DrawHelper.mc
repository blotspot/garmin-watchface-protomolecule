import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application.Properties;

module Format {
  const INT_ZERO as String = "%02d";
  const INT as String = "%i";
}

module Enums {
  enum Layout {
    LAYOUT_ORBIT,
    LAYOUT_CIRCLES,
    LAYOUT_BIP,
    LAYOUT_LPM,
    LAYOUT_SLEEP,
  }

  enum Theme {
    THEME_EXPANSE,
    THEME_EARTH,
    THEME_MARS,
    THEME_BELT,
  }

  enum Color {
    COLOR_PRIMARY,
    COLOR_SECONDARY_1,
    COLOR_SECONDARY_2,
  }

  enum FieldId {
    FIELD_NO_PROGRESS_1,
    FIELD_NO_PROGRESS_2,
    FIELD_NO_PROGRESS_3,
    FIELD_ORBIT_OUTER,
    FIELD_ORBIT_LEFT,
    FIELD_ORBIT_RIGHT,
    FIELD_OUTER,
    FIELD_UPPER_1,
    FIELD_UPPER_2,
    FIELD_LOWER_1,
    FIELD_LOWER_2,
    FIELD_SLEEP_UP,
    FIELD_SLEEP_LEFT,
    FIELD_SLEEP_RIGHT,
    FIELD_SLEEP_MIDDLE,
    FIELD_DATE_AND_TIME,
  }

  enum FieldType {
    DATA_NOTHING,
    DATA_STEPS,
    DATA_BATTERY,
    DATA_CALORIES,
    DATA_ACTIVE_MINUTES,
    DATA_HEART_RATE,
    DATA_NOTIFICATION,
    DATA_FLOORS_UP,
    DATA_FLOORS_DOWN,
    DATA_BLUETOOTH,
    DATA_ALARMS,
    DATA_BODY_BATTERY,
    DATA_SECONDS,
    DATA_STRESS_LEVEL,
    DATA_ACTIVE_CALORIES,
  }
}

module Color {
  const _COLORS as Array<ColorType> = [
    /* EXPANSE */
    0xffaa00, // PRIMARY
    0x00aaff, // SECONDARY_1
    0xff0000, // SECONDARY_2
    /* EARTH */
    0x00aaff, // PRIMARY
    0x00ffff, // SECONDARY_1
    0x00ffff, // SECONDARY_2
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

function themeColor(sectionId as Enums.Color) as ColorType {
  return Color._COLORS[(Properties.getValue("theme") as Enums.Theme) * 3 /* MAX_COLOR_ID */ + sectionId];
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
