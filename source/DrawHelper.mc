using Toybox.Graphics;
using Toybox.Application;

module Color {
  enum {
    PRIMARY_BOTTOM,
    PRIMARY_LEFT,
    PRIMARY_RIGHT,
    SECONDARY_ACTIVE,
    SECONDARY_INACTIVE,
    BACKGROUND,
    FOREGROUND,
    INACTIVE
  }

  const _COLORS = [
    /* EXPANSE */
    [
      0xFFAA55, // PRIMARY_BOTTOM
      0xFF5555,    // PRIMARY_LEFT
      0x55AAFF,   // PRIMARY_RIGHT
      Graphics.COLOR_WHITE,  // SECONDARY_ACTIVE
      Graphics.COLOR_LT_GRAY,// SECONDARY_INACTIVE
      Graphics.COLOR_BLACK,  // BACKGROUND
      Graphics.COLOR_WHITE,  // FOREGROUND
      Graphics.COLOR_DK_GRAY // INACTIVE
    ],
    /* EARTH */
    [
      0x55FFFF, // PRIMARY_BOTTOM
      0x55AAFF,  // PRIMARY_LEFT
      0x55AAFF,  // PRIMARY_RIGHT
      Graphics.COLOR_WHITE, // SECONDARY_ACTIVE
      Graphics.COLOR_LT_GRAY, // SECONDARY_INACTIVE
      Graphics.COLOR_BLACK,   // BACKGROUND
      Graphics.COLOR_WHITE,   // FOREGROUND
      Graphics.COLOR_DK_GRAY  // INACTIVE
    ],
    /* MARS */
    [
      Graphics.COLOR_RED,    // PRIMARY_BOTTOM
      Graphics.COLOR_ORANGE, // PRIMARY_LEFT
      Graphics.COLOR_ORANGE, // PRIMARY_RIGHT
      Graphics.COLOR_WHITE,  // SECONDARY_ACTIVE
      Graphics.COLOR_LT_GRAY,// SECONDARY_INACTIVE
      Graphics.COLOR_BLACK,  // BACKGROUND
      Graphics.COLOR_WHITE,  // FOREGROUND
      Graphics.COLOR_DK_GRAY // INACTIVE
    ],
    /* BELT */
    [
      Graphics.COLOR_YELLOW, // PRIMARY_BOTTOM
      0xFFAA55, // PRIMARY_LEFT
      0xFFAA55, // PRIMARY_RIGHT
      Graphics.COLOR_WHITE,  // SECONDARY_ACTIVE
      Graphics.COLOR_LT_GRAY,// SECONDARY_INACTIVE
      Graphics.COLOR_BLACK,  // BACKGROUND
      Graphics.COLOR_WHITE,  // FOREGROUND
      Graphics.COLOR_DK_GRAY // INACTIVE
    ],
    /* EXPANSE (Light) */
    [
      Graphics.COLOR_ORANGE, // PRIMARY_BOTTOM
      Graphics.COLOR_RED,    // PRIMARY_LEFT
      Graphics.COLOR_BLUE,   // PRIMARY_RIGHT
      Graphics.COLOR_BLACK,  // SECONDARY_ACTIVE
      Graphics.COLOR_TRANSPARENT,  // SECONDARY_INACTIVE
      Graphics.COLOR_WHITE,   // BACKGROUND
      Graphics.COLOR_BLACK,   // FOREGROUND
      Graphics.COLOR_LT_GRAY  // INACTIVE
    ],
    /* EARTH (Light) */
    [
      0x0055AA, // PRIMARY_BOTTOM
      Graphics.COLOR_BLUE,  // PRIMARY_LEFT
      Graphics.COLOR_BLUE,  // PRIMARY_RIGHT
      Graphics.COLOR_BLACK, // SECONDARY_ACTIVE
      Graphics.COLOR_TRANSPARENT, // SECONDARY_INACTIVE
      Graphics.COLOR_WHITE,   // BACKGROUND
      Graphics.COLOR_BLACK,   // FOREGROUND
      Graphics.COLOR_LT_GRAY  // INACTIVE
    ]
  ];
}

function themeColor(sectionId) {
  return Color._COLORS[Application.getApp().gTheme][sectionId];
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