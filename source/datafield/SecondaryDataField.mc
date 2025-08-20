import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;
import Color;

class SecondaryDataField extends DataFieldDrawable {
  hidden var mOffsetMod as Numeric;
  hidden var mColor as Number;

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
        :position as Number,
        :x as Numeric,
        :y as Numeric,
        :color as Number,
      }
  ) {
    //! redefine locX / locY.
    //! Doing it the stupid way because the layout isn't allowing a `dc` call in their definition.
    params[:locX] = params[:x];
    params[:locY] = params[:y];
    DataFieldDrawable.initialize(params);

    var pos = params[:position];
    mOffsetMod = pos == 2 ? 0 : pos == 1 ? 0.5 : 1;
    mColor = params.hasKey(:color) ? themeColor(params[:color]) : 0xffffff;
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      update(dc, false);
    }
  }

  function update(dc, partial as Boolean) {
    //! stroke width acts as buffer used in the clipping region and between icon and text
    var dim = getDimensions(dc);
    setClippingRegion(dc, dim);
    if (partial) {
      clearForPartialUpdate(dc);
    }
    if (mLastInfo.progress == 0) {
      dc.setColor(0xaaaaaa, -1);
    } else {
      dc.setColor(mColor, -1);
    }

    var offsetX = dim[0] * mOffsetMod + Settings.strokeWidth / 2d;
    mLastInfo.icon.drawAt(dc, locX - offsetX + Settings.iconSize / 2d /* icon will be centered at x, so add half icon size */, locY);
    if (mLastInfo.text != null) {
      dc.drawText(
        locX - offsetX + Settings.iconSize + Settings.strokeWidth,
        locY - 1, // just txt font things :shrug:
        Settings.resource(Rez.Fonts.SecondaryIndicatorFont),
        mLastInfo.text,
        2 | 4
      );
    }
  }

  function partialUpdate(dc) {
    DataFieldDrawable.drawPartialUpdate(dc, method(:update));
  }

  hidden function setClippingRegion(dc, dim as Array<Numeric>) {
    var offsetX = dim[0] * mOffsetMod;
    dc.setClip(locX - offsetX, locY - dim[1] / 2, dim[0], dim[1]);
  }

  hidden function clearForPartialUpdate(dc) {
    // clear with background color so we don't draw over existing text
    dc.setColor(0xffffff, 0);
    dc.clear();
  }

  hidden function getDimensions(dc) as Array<Numeric> {
    var textWidth = 0;
    if (mLastInfo.text != null) {
      textWidth = dc.getTextWidthInPixels(mLastInfo.text, Settings.resource(Rez.Fonts.SecondaryIndicatorFont));
    }
    var fieldWidth = textWidth + Settings.iconSize + Settings.strokeWidth * 2;
    // NOTE: +1 makes me less nervous about the bounds on 218x218 size displays and that's a good thing
    return [fieldWidth, Settings.iconSize + Settings.strokeWidth * 2 + 1];
  }
}
