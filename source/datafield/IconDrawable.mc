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
  function drawAt(dc, atLocX as Numeric, atLocY as Numeric) {
    if (mIcon != null) {
      saveSetAntiAlias(dc, true);
      locX = atLocX;
      locY = mOffestY ? atLocY + Settings.iconSize * 0.1 : atLocY;
      drawInternal(dc);
      saveSetAntiAlias(dc, false);
    }
  }

  //! system call
  function draw(dc) {
    if (mIcon != null) {
      locX = dc.getWidth() / 2;
      locY = dc.getHeight() / 2;
      saveSetAntiAlias(dc, true);
      dc.setColor(0xff5500 /* orange */, -1);
      dc.fillCircle(locX, locY, Math.floor(Settings.iconSize) - 1);
      dc.setColor(0xffffff, -1);
      drawInternal(dc);
      saveSetAntiAlias(dc, false);
    }
  }

  function resetOffset() {
    mOffestY = false;
  }

  hidden function drawInternal(dc) {
    var font = Settings.resource(Rez.Fonts.IconsFont);
    dc.drawText(locX, locY, font, mIcon, 1 | 4);
  }

  function equals(other) as Boolean {
    if (other != null && other instanceof IconDrawable) {
      return other.mIcon == mIcon && other.identifier == identifier;
    }
    return false;
  }
}
