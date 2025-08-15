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
    DataFieldDrawable.initialize(params);

    mOffsetMod = params[:offsetModifier];
    //! redefine locX / locY.
    //! Doing it the stupid way because the layout isn't allowing a `dc` call in their definition.
    locX = params[:x];
    locY = params[:y];
  }

  function draw(dc as Graphics.Dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      update(dc);
    }
  }

  function update(dc as Graphics.Dc) {
    var fieldWidth = dc.getTextWidthInPixels(mLastInfo.text, Settings.resource(Rez.Fonts.SecondaryIndicatorFont)) + Settings.get(:iconSize);
    var offset = fieldWidth * mOffsetMod;
    setClippingRegion(dc, offset, Settings.get(:strokeWidth));

    if (mLastInfo.progress == 0) {
      dc.setColor(themeColor(Color.TEXT_INACTIVE), Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(themeColor(Color.TEXT_ACTIVE), Graphics.COLOR_TRANSPARENT);
    }

    mLastInfo.icon.drawAt(dc, locX - offset + Settings.get(:iconSize) / 2.0, locY);
    drawText(dc, mLastInfo.text, Settings.resource(Rez.Fonts.SecondaryIndicatorFont), locX - offset + Settings.get(:iconSize) + Settings.get(:strokeWidth));
  }

  function partialUpdate(dc as Graphics.Dc) {
    DataFieldDrawable.drawPartialUpdate(dc, method(:update));
  }

  function drawText(dc as Graphics.Dc, text as String, font as FontType, xPos as Numeric) {
    dc.drawText(xPos, locY - 1, font, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function setClippingRegion(dc as Graphics.Dc, offset as Numeric, penSize as Numeric) {
    var contentDimensions = getDimensions(dc);
    dc.setColor(themeColor(Color.TEXT_ACTIVE), Graphics.COLOR_TRANSPARENT);
    dc.setClip(locX - offset, locY - contentDimensions[1] / 2 - penSize / 2, contentDimensions[0] + penSize, contentDimensions[1] + penSize);
    dc.clear();
  }

  function getDimensions(dc as Graphics.Dc) as Array<Numeric> {
    var dim = dc.getTextDimensions("000", Settings.resource(Rez.Fonts.SecondaryIndicatorFont)) as Array<Numeric>;
    dim[0] = dim[0] + Settings.get(:iconSize);
    if (dim[1] < Settings.get(:iconSize)) {
      dim[1] = Settings.get(:iconSize);
    }

    return dim;
  }
}
