import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class Background extends WatchUi.Drawable {
  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Numeric,
        :locY as Numeric,
        :width as Numeric,
        :height as Numeric,
        :visible as Boolean,
      }
  ) {
    Drawable.initialize(params);
  }

  function draw(dc) {
    dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
    dc.clear();
  }
}
