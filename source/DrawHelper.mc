using Toybox.Graphics;
using Toybox.Application;

module Color {
  enum {
    SECONDARY_ACTIVE,
    SECONDARY_INACTIVE,
    OUTER,
    UPPER_1,
    UPPER_2,
    LOWER_1,
    LOWER_2,
    BACKGROUND,
    FOREGROUND,
    INACTIVE
  }

  const _COLORS = [
    /* EXPANSE */
    [
      Graphics.COLOR_WHITE,  // SECONDARY_ACTIVE
      Graphics.COLOR_LT_GRAY,// SECONDARY_INACTIVE
      Graphics.COLOR_YELLOW, // OUTER
      Graphics.COLOR_BLUE,    // UPPER_1
      Graphics.COLOR_BLUE, // UPPER_2
      Graphics.COLOR_RED,     // LOWER_1
      Graphics.COLOR_RED,  // LOWER_2
      Graphics.COLOR_BLACK,  // BACKGROUND
      Graphics.COLOR_WHITE,  // FOREGROUND
      Graphics.COLOR_DK_GRAY // INACTIVE
    ],
    /* EARTH */
    [
      Graphics.COLOR_WHITE,   // SECONDARY_ACTIVE
      Graphics.COLOR_LT_GRAY, // SECONDARY_INACTIVE
      Graphics.COLOR_DK_BLUE, // OUTER
      Graphics.COLOR_BLUE, // UPPER_1
      Graphics.COLOR_BLUE, // UPPER_2
      Graphics.COLOR_BLUE, // LOWER_1
      Graphics.COLOR_BLUE, // LOWER_2
      Graphics.COLOR_BLACK,   // BACKGROUND
      Graphics.COLOR_WHITE,   // FOREGROUND
      Graphics.COLOR_DK_GRAY  // INACTIVE
    ],
    /* MARS */
    [
      Graphics.COLOR_WHITE,  // SECONDARY_ACTIVE
      Graphics.COLOR_LT_GRAY,// SECONDARY_INACTIVE
      Graphics.COLOR_RED, // OUTER
      Graphics.COLOR_ORANGE, // UPPER_1
      Graphics.COLOR_ORANGE, // UPPER_2
      Graphics.COLOR_ORANGE, // LOWER_1
      Graphics.COLOR_ORANGE,    // LOWER_2
      Graphics.COLOR_BLACK,  // BACKGROUND
      Graphics.COLOR_WHITE,  // FOREGROUND
      Graphics.COLOR_DK_GRAY // INACTIVE
    ],
    /* BELT */
    [
      Graphics.COLOR_WHITE,  // SECONDARY_ACTIVE
      Graphics.COLOR_LT_GRAY,// SECONDARY_INACTIVE
      Graphics.COLOR_ORANGE, // OUTER
      Graphics.COLOR_YELLOW, // UPPER_1
      Graphics.COLOR_YELLOW, // UPPER_2
      Graphics.COLOR_YELLOW, // LOWER_1
      Graphics.COLOR_YELLOW, // LOWER_2
      Graphics.COLOR_BLACK,  // BACKGROUND
      Graphics.COLOR_WHITE,  // FOREGROUND
      Graphics.COLOR_DK_GRAY // INACTIVE
    ],
    /* EXPANSE (Light) */
    [
      Graphics.COLOR_BLACK,  // SECONDARY_ACTIVE
      Graphics.COLOR_TRANSPARENT,  // SECONDARY_INACTIVE
      Graphics.COLOR_YELLOW, // OUTER
      Graphics.COLOR_BLUE,    // UPPER_1
      Graphics.COLOR_BLUE, // UPPER_2
      Graphics.COLOR_RED,     // LOWER_1
      Graphics.COLOR_RED,  // LOWER_2
      Graphics.COLOR_WHITE,   // BACKGROUND
      Graphics.COLOR_BLACK,   // FOREGROUND
      Graphics.COLOR_LT_GRAY  // INACTIVE
    ],
    /* EARTH (Light) */
    [
      Graphics.COLOR_BLACK, // SECONDARY_ACTIVE
      Graphics.COLOR_TRANSPARENT, // SECONDARY_INACTIVE
      Graphics.COLOR_DK_BLUE, // OUTER
      Graphics.COLOR_BLUE, // UPPER_1
      Graphics.COLOR_BLUE, // UPPER_2
      Graphics.COLOR_BLUE, // LOWER_1
      Graphics.COLOR_BLUE, // LOWER_2
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