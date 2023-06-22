import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;

module Color {
  const TEXT_ACTIVE as Lang.Number = 0;
  const TEXT_INACTIVE as Lang.Number = 1;
  const PRIMARY as Lang.Number = 2;
  const SECONDARY_1 as Lang.Number = 3;
  const SECONDARY_2 as Lang.Number = 4;
  const BACKGROUND as Lang.Number = 5;
  const FOREGROUND as Lang.Number = 6;
  const INACTIVE as Lang.Number = 7;

  const MAX_COLOR_ID as Lang.Number = 8;

  const _COLORS as Array<Lang.Number> = [
    /* EXPANSE */
      Graphics.COLOR_WHITE,   // TEXT_ACTIVE
      Graphics.COLOR_LT_GRAY, // TEXT_INACTIVE
      Graphics.COLOR_YELLOW,  // PRIMARY
      Graphics.COLOR_BLUE,    // SECONDARY_1
      Graphics.COLOR_RED,     // SECONDARY_2
      Graphics.COLOR_BLACK,   // BACKGROUND
      Graphics.COLOR_WHITE,   // FOREGROUND
      Graphics.COLOR_DK_GRAY, // INACTIVE,
    /* EARTH */
      Graphics.COLOR_WHITE,   // TEXT_ACTIVE
      Graphics.COLOR_LT_GRAY, // TEXT_INACTIVE
      0x0055aa,               // PRIMARY
      Graphics.COLOR_BLUE,    // SECONDARY_1
      Graphics.COLOR_BLUE,    // SECONDARY_2
      Graphics.COLOR_BLACK,   // BACKGROUND
      Graphics.COLOR_WHITE,   // FOREGROUND
      Graphics.COLOR_DK_GRAY, // INACTIVE
    /* MARS */
      Graphics.COLOR_WHITE,   // TEXT_ACTIVE
      Graphics.COLOR_LT_GRAY, // TEXT_INACTIVE
      Graphics.COLOR_RED,     // PRIMARY
      Graphics.COLOR_ORANGE,  // SECONDARY_1
      Graphics.COLOR_ORANGE,  // SECONDARY_2
      Graphics.COLOR_BLACK,   // BACKGROUND
      Graphics.COLOR_WHITE,   // FOREGROUND
      Graphics.COLOR_DK_GRAY, // INACTIVE
    /* BELT */
      Graphics.COLOR_WHITE,   // TEXT_ACTIVE
      Graphics.COLOR_LT_GRAY, // TEXT_INACTIVE
      Graphics.COLOR_YELLOW,  // PRIMARY
      0xffff00,               // SECONDARY_1
      0xffff00,               // SECONDARY_2
      Graphics.COLOR_BLACK,   // BACKGROUND
      Graphics.COLOR_WHITE,   // FOREGROUND
      Graphics.COLOR_DK_GRAY, // INACTIVE
    /* EXPANSE (Light) */
      Graphics.COLOR_BLACK,   // TEXT_ACTIVE
      Graphics.COLOR_DK_GRAY, // TEXT_INACTIVE
      Graphics.COLOR_YELLOW,  // PRIMARY
      Graphics.COLOR_BLUE,    // SECONDARY_1
      Graphics.COLOR_BLUE,    // SECONDARY_2
      Graphics.COLOR_WHITE,   // BACKGROUND
      Graphics.COLOR_BLACK,   // FOREGROUND
      Graphics.COLOR_LT_GRAY, // INACTIVE
    /* EARTH (Light) */
      Graphics.COLOR_BLACK,   // TEXT_ACTIVE
      Graphics.COLOR_DK_GRAY, // TEXT_INACTIVE
      Graphics.COLOR_DK_BLUE, // PRIMARY
      Graphics.COLOR_BLUE,    // SECONDARY_1
      Graphics.COLOR_BLUE,    // SECONDARY_2
      Graphics.COLOR_WHITE,   // BACKGROUND
      Graphics.COLOR_BLACK,   // FOREGROUND
      Graphics.COLOR_LT_GRAY  // INACTIVE
  ];
}

function themeColor(sectionId as Lang.Number) as Lang.Number {
  var theme = Settings.get("theme") as Lang.Number;
  return Color._COLORS[(theme * Color.MAX_COLOR_ID) + sectionId];
}

function setAntiAlias(dc, enabled as Lang.Boolean) as Void {
  if (Graphics.Dc has :setAntiAlias) {
    dc.setAntiAlias(enabled);
  }
}

function clearClip(dc) as Void {
  if (Graphics.Dc has :clearClip) {
    dc.clearClip();
  }
}