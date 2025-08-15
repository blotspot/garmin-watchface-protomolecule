import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;

class IconDrawable extends WatchUi.Drawable {
  hidden var mIcon as String;
  hidden var mOffestY as Boolean;

  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Numeric,
        :locY as Numeric,
        :width as Numeric,
        :height as Numeric,
        :visible as Boolean,
        :icon as String,
        :offsetY as Boolean,
      }
  ) {
    mIcon = params[:icon];
    mOffestY = params.get(:offsetY) != null ? params[:offsetY] : false;

    var options = {
      :identifier => params.get(:identifier) != null ? params[:identifier] : "icon_" + mIcon,
      :locX => params.get(:locX) != null ? params[:locX] : Settings.get(:iconSize) / 2,
      :locY => params.get(:locY) != null ? params[:locY] : Settings.get(:iconSize),
      :width => params.get(:width) != null ? params[:width] : Settings.get(:iconSize),
      :height => params.get(:height) != null ? params[:height] : Settings.get(:iconSize),
      :visible => params.get(:visible) != null ? params[:visible] : true,
    };

    Drawable.initialize(options);
  }

  function drawAt(dc as Graphics.Dc, atLocX as Numeric, atLocY as Numeric) {
    //! DataField call
    locX = atLocX;
    locY = mOffestY ? atLocY + height * 0.1 : atLocY;
    drawInternal(dc);
  }

  function draw(dc as Graphics.Dc) {
    //! system call for menu options, for example
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    locX = dc.getWidth() / 2;
    locY = dc.getHeight() / 2 + (mOffestY ? Settings.get(:iconSize) * 0.1 : 0);
    drawInternal(dc);
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
