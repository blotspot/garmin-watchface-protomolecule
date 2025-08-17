import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;
import Color;

class SecondaryDataField extends DataFieldDrawable {
  hidden var mOffsetMod as Numeric;

  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Numeric,
        :locY as Numeric,
        :width as Numeric,
        :height as Numeric,
        :visible as Boolean,
        :fieldId as Number,
        :offsetModifier as Numeric,
        :x as Numeric,
        :y as Numeric,
      }
  ) {
    //! redefine locX / locY.
    //! Doing it the stupid way because the layout isn't allowing a `dc` call in their definition.
    params[:locX] = params[:x];
    params[:locY] = params[:y];
    DataFieldDrawable.initialize(params);

    mOffsetMod = params[:offsetModifier];
  }

  function draw(dc as Graphics.Dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      update(dc, false);
    }
  }

  function update(dc as Graphics.Dc, partial as Boolean) {
    //! stroke width acts as buffer used in the clipping region and between icon and text
    var dim = getDimensions(dc);
    setClippingRegion(dc, dim);
    if (partial) {
      clearForPartialUpdate(dc);
    }
    if (mLastInfo.progress == 0) {
      dc.setColor(themeColor(Color.TEXT_INACTIVE), Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(themeColor(Color.TEXT_ACTIVE), Graphics.COLOR_TRANSPARENT);
    }

    var offsetX = dim[0] * mOffsetMod + Settings.get("strokeWidth") / 2d;
    mLastInfo.icon.drawAt(dc, locX - offsetX + Settings.get("iconSize") / 2d /* icon will be centered at x, so add half icon size */, locY);
    if (mLastInfo.text != null) {
      dc.drawText(
        locX - offsetX + Settings.get("iconSize") + Settings.get("strokeWidth"),
        locY - 1, // just txt font things :shrug:
        Settings.resource(Rez.Fonts.SecondaryIndicatorFont),
        mLastInfo.text,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  function partialUpdate(dc as Graphics.Dc) {
    DataFieldDrawable.drawPartialUpdate(dc, method(:update));
  }

  hidden function setClippingRegion(dc as Graphics.Dc, dim as Array<Numeric>) {
    var offsetX = dim[0] * mOffsetMod;
    dc.setClip(locX - offsetX, locY - dim[1] / 2, dim[0], dim[1]);
  }

  hidden function clearForPartialUpdate(dc as Graphics.Dc) {
    // clear with background color so we don't draw over existing text
    dc.setColor(themeColor(Color.TEXT_ACTIVE), themeColor(Color.BACKGROUND));
    dc.clear();
  }

  hidden function getDimensions(dc as Graphics.Dc) as Array<Numeric> {
    var textWidth = 0;
    if (mLastInfo.text != null) {
      textWidth = dc.getTextWidthInPixels(mLastInfo.text, Settings.resource(Rez.Fonts.SecondaryIndicatorFont));
    }
    var fieldWidth = textWidth + Settings.get("iconSize") + Settings.get("strokeWidth") * 2;
    // NOTE: +1 makes me less nervous about the bounds on 218x218 size displays and that's a good thing
    return [fieldWidth, Settings.get("iconSize") + Settings.get("strokeWidth") * 2 + 1];
  }
}
