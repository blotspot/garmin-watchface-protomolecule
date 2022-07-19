using Toybox.Graphics;
using Toybox.Application;

module Color {
  const TEXT_ACTIVE = 0;
  const TEXT_INACTIVE = 1;
  const PRIMARY = 2;
  const SECONDARY_1 = 3;
  const SECONDARY_2 = 4;
  const BACKGROUND = 5;
  const FOREGROUND = 6;
  const INACTIVE = 7;

  const _COLORS = [
    /* EXPANSE */
    [
      Graphics.COLOR_WHITE,  // TEXT_ACTIVE
      Graphics.COLOR_LT_GRAY,// TEXT_INACTIVE
      Graphics.COLOR_YELLOW, // PRIMARY
      Graphics.COLOR_BLUE,   // SECONDARY_1
      Graphics.COLOR_RED,    // SECONDARY_2
      Graphics.COLOR_BLACK,  // BACKGROUND
      Graphics.COLOR_WHITE,  // FOREGROUND
      Graphics.COLOR_DK_GRAY // INACTIVE
    ],
    /* EARTH */
    [
      Graphics.COLOR_WHITE,   // TEXT_ACTIVE
      Graphics.COLOR_LT_GRAY, // TEXT_INACTIVE
      0x0055aa,               // PRIMARY
      Graphics.COLOR_BLUE,    // SECONDARY_1
      Graphics.COLOR_BLUE,    // SECONDARY_2
      Graphics.COLOR_BLACK,   // BACKGROUND
      Graphics.COLOR_WHITE,   // FOREGROUND
      Graphics.COLOR_DK_GRAY  // INACTIVE
    ],
    /* MARS */
    [
      Graphics.COLOR_WHITE,  // TEXT_ACTIVE
      Graphics.COLOR_LT_GRAY,// TEXT_INACTIVE
      Graphics.COLOR_RED,    // PRIMARY
      Graphics.COLOR_ORANGE, // SECONDARY_1
      Graphics.COLOR_ORANGE, // SECONDARY_2
      Graphics.COLOR_BLACK,  // BACKGROUND
      Graphics.COLOR_WHITE,  // FOREGROUND
      Graphics.COLOR_DK_GRAY // INACTIVE
    ],
    /* BELT */
    [
      Graphics.COLOR_WHITE,  // TEXT_ACTIVE
      Graphics.COLOR_LT_GRAY,// TEXT_INACTIVE
      Graphics.COLOR_YELLOW, // PRIMARY
      0xffff00,              // SECONDARY_1
      0xffff00,              // SECONDARY_2
      Graphics.COLOR_BLACK,  // BACKGROUND
      Graphics.COLOR_WHITE,  // FOREGROUND
      Graphics.COLOR_DK_GRAY // INACTIVE
    ],
    /* EXPANSE (Light) */
    [
      Graphics.COLOR_BLACK,   // TEXT_ACTIVE
      Graphics.COLOR_DK_GRAY, // TEXT_INACTIVE
      Graphics.COLOR_YELLOW,  // PRIMARY
      Graphics.COLOR_BLUE,    // SECONDARY_1
      Graphics.COLOR_BLUE,    // SECONDARY_2
      Graphics.COLOR_WHITE,   // BACKGROUND
      Graphics.COLOR_BLACK,   // FOREGROUND
      Graphics.COLOR_LT_GRAY  // INACTIVE
    ],
    /* EARTH (Light) */
    [
      Graphics.COLOR_BLACK,   // TEXT_ACTIVE
      Graphics.COLOR_DK_GRAY, // TEXT_INACTIVE
      Graphics.COLOR_DK_BLUE, // PRIMARY
      Graphics.COLOR_BLUE,    // SECONDARY_1
      Graphics.COLOR_BLUE,    // SECONDARY_2
      Graphics.COLOR_WHITE,   // BACKGROUND
      Graphics.COLOR_BLACK,   // FOREGROUND
      Graphics.COLOR_LT_GRAY  // INACTIVE
    ]
  ];
}

function themeColor(sectionId) {
  return Color._COLORS[Settings.get("theme")][sectionId];
}

function setAntiAlias(dc, enabled) {
  if (dc has :setAntiAlias) {
    dc.setAntiAlias(true);
  }
}

function clearClip(dc) {
  if (dc has :clearClip) {
    dc.clearClip();
  }
}