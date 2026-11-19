import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application.Properties;

module Format {
  const INT_ZERO as String = "%02d";
  const INT as String = "%i";
}

module Config {
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
    COLOR_CUSTOM = -1,
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
    FIELD_CIRCLES_OUTER,
    FIELD_CIRCLES_UPPER_1,
    FIELD_CIRCLES_UPPER_2,
    FIELD_CIRCLES_LOWER_1,
    FIELD_CIRCLES_LOWER_2,
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

  (:onPressComplication)
  enum ComplicationTrigger {
    TRIGGER_DATE,
    TRIGGER_TIME,
    TRIGGER_LEFT,
    TRIGGER_RIGHT,
  }
}

function themeColor(sectionId as Config.Color) as ColorType {
  if (sectionId == Config.COLOR_CUSTOM) {
    // do something
    return Graphics.COLOR_WHITE;
  } else {
    var _COLORS = [
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
    return _COLORS[(Properties.getValue("theme") as Config.Theme) * 3 /* MAX_COLOR_ID */ + sectionId];
  }
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

function isPointInHitbox(hitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?, x as Number, y as Number) as Boolean {
  if (hitbox == null) {
    return false;
  }
  return x >= hitbox[:x]
    && x <= hitbox[:x] + hitbox[:width]
    && y >= hitbox[:y]
    && y <= hitbox[:y] + hitbox[:height];
}

function getLayoutPriority(
  burnInProtection as Boolean,
  hasDisplayMode as Boolean,
  sleepLayout as Boolean,
  defaultLayout as Config.Layout
) as Config.Layout {
  if (burnInProtection && !hasDisplayMode) {
    return Config.LAYOUT_BIP;
  }
  if (sleepLayout) {
    return Config.LAYOUT_SLEEP;
  }
  if (burnInProtection && hasDisplayMode) {
    return Config.LAYOUT_LPM;
  }
  return defaultLayout;
}

function hasCompleteActiveCalorieProfile(birthYear as Number?, height as Numeric?, weight as Numeric?) as Boolean {
  return birthYear != null && height != null && weight != null;
}

function safeProgress(current as Numeric, goal as Numeric?) as Numeric {
  if (goal == null || goal <= 0) {
    return 0;
  }
  return current.toDouble() / goal.toDouble();
}

function clamp(value as Numeric, minimum as Numeric, maximum as Numeric) as Numeric {
  if (value < minimum) {
    return minimum;
  }
  if (value > maximum) {
    return maximum;
  }
  return value;
}
