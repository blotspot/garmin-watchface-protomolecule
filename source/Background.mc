using Toybox.WatchUi as Ui;
using Toybox.Graphics;

class Background extends Ui.Drawable {

  function initialize(params) {
		Drawable.initialize(params);
	}

  function draw(dc) {
    dc.setColor(Graphics.COLOR_TRANSPARENT, themeColor(Color.BACKGROUND));
    dc.clear();
  }
}