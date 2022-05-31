using Toybox.WatchUi;
using Toybox.Graphics;

class Background extends WatchUi.Drawable {

  function initialize(params) {
		Drawable.initialize(params);
	}

  function draw(dc) {
    dc.setColor(Graphics.COLOR_TRANSPARENT, themeColor(Color.BACKGROUND));
    dc.clear();
  }
}