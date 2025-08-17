import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;

class IconDrawable extends WatchUi.Drawable {
  hidden var mIcon as String;
  hidden var mOffestY as Boolean;

  function initialize(identifier as Number, icon as String, params as { :offsetY as Boolean }?) {
    mIcon = icon;
    if (params == null) {
      params = {};
    }
    mOffestY = params.hasKey(:offsetY) ? params[:offsetY] : false;

    Drawable.initialize({ :identifier => identifier });
  }

  //! manual (DataField) call
  function drawAt(dc as Graphics.Dc, atLocX as Numeric, atLocY as Numeric) {
    locX = atLocX;
    locY = mOffestY ? atLocY + Settings.get("iconSize") * 0.1 : atLocY;
    drawInternal(dc);
  }

  //! system call
  function draw(dc as Graphics.Dc) {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    locX = dc.getWidth() / 2;
    locY = dc.getHeight() / 2;
    drawInternal(dc);
  }

  function resetOffset() {
    mOffestY = false;
  }

  hidden function drawInternal(dc as Graphics.Dc) {
    var font = Settings.resource(Rez.Fonts.IconsFont);
    dc.drawText(locX, locY, font, mIcon, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function equals(other) as Boolean {
    if (other != null && other instanceof IconDrawable) {
      return other.mIcon == mIcon && other.identifier == identifier;
    }
    return false;
  }
}
