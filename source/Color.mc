using Toybox.Graphics;
using Toybox.Application;

module Color {
  enum {
    PRIMARY_BOTTOM,
    PRIMARY_LEFT,
    PRIMARY_RIGHT,
    SECONDARY_ACTIVE,
    SECONDARY_INACTIVE
  }

  const BACKGROUND = Graphics.COLOR_TRANSPARENT;
  const INACTIVE = Graphics.COLOR_DK_GRAY;

  const _COLORS = [
    /* EXPANSE */
    [
      Graphics.COLOR_YELLOW, // PRIMARY_BOTTOM
      Graphics.COLOR_BLUE,   // PRIMARY_LEFT
      Graphics.COLOR_RED,    // PRIMARY_RIGHT
      Graphics.COLOR_WHITE,  // SECONDARY_1
      Graphics.COLOR_WHITE,  // SECONDARY_2
      Graphics.COLOR_WHITE   // SECONDARY_3
    ],
    /* EARTH */
    [
      Graphics.COLOR_GREEN,  // PRIMARY_BOTTOM
      Graphics.COLOR_BLUE,   // PRIMARY_LEFT
      Graphics.COLOR_BLUE,   // PRIMARY_RIGHT
      Graphics.COLOR_WHITE,  // SECONDARY_1
      Graphics.COLOR_WHITE,  // SECONDARY_2
      Graphics.COLOR_WHITE   // SECONDARY_3
    ],
    /* MARS */
    [
      Graphics.COLOR_ORANGE, // PRIMARY_BOTTOM
      Graphics.COLOR_RED,    // PRIMARY_LEFT
      Graphics.COLOR_RED,    // PRIMARY_RIGHT
      Graphics.COLOR_WHITE,  // SECONDARY_1
      Graphics.COLOR_WHITE,  // SECONDARY_2
      Graphics.COLOR_WHITE   // SECONDARY_3
    ],
    /* BELT */
    [
      Graphics.COLOR_PURPLE, // PRIMARY_BOTTOM
      Graphics.COLOR_YELLOW, // PRIMARY_LEFT
      Graphics.COLOR_YELLOW, // PRIMARY_RIGHT
      Graphics.COLOR_WHITE,  // SECONDARY_1
      Graphics.COLOR_WHITE,  // SECONDARY_2
      Graphics.COLOR_WHITE   // SECONDARY_3
    ]
  ];
}

function themeColor(sectionId) {
  return Color._COLORS[Application.getApp().getProperty("theme")][sectionId];
}