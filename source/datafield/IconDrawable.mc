import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;

class IconDrawable extends WatchUi.Drawable {
  hidden var mIcon as String?;
  hidden var mOffestY as Boolean;

  function initialize(identifier as Number, icon as String?, offsetY as Boolean) {
    mIcon = icon;
    mOffestY = offsetY;

    Drawable.initialize({ :identifier => identifier });
  }

  //! manual (DataField) call
  function drawAt(dc as Graphics.Dc, atLocX as Numeric, atLocY as Numeric) {
    if (mIcon != null) {
      saveSetAntiAlias(dc, true);
      locX = atLocX;
      locY = mOffestY ? atLocY + Settings.iconSize * 0.1 : atLocY;
      drawInternal(dc);
      saveSetAntiAlias(dc, false);
    }
  }

  //! system call
  function draw(dc as Graphics.Dc) {
    if (mIcon != null) {
      locX = dc.getWidth() / 2;
      locY = dc.getHeight() / 2;
      saveSetAntiAlias(dc, true);
      dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(locX, locY, Settings.iconSize);
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      drawInternal(dc);
      saveSetAntiAlias(dc, false);
    }
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
