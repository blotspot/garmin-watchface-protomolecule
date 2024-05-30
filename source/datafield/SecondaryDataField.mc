import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;
import Color;

class SecondaryDataField extends DataFieldDrawable {
  hidden var mOffsetMod;

  (:typecheck(false))
  function initialize(params) {
    DataFieldDrawable.initialize(params);

    mFieldId = params[:fieldId];
    mOffsetMod = params[:offsetModifier];
    locX = params[:x];
    locY = params[:y];
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      update(dc);
    }
  }

  function update(dc) {
    var fieldWidth = dc.getTextWidthInPixels(mLastInfo.text, Settings.resource(Rez.Fonts.SecondaryIndicatorFont)) + Settings.get("iconSize");
    var offset = fieldWidth * mOffsetMod;
    setClippingRegion(dc, offset, Settings.get("strokeWidth"));

    if (mLastInfo.text.equals("0")) {
      dc.setColor(themeColor(Color.TEXT_INACTIVE), Graphics.COLOR_TRANSPARENT);
    }

    mLastInfo.icon.invoke(dc, locX - offset + Settings.get("iconSize") / 2.0, locY, Settings.get("iconSize"), Settings.get("strokeWidth"), mLastInfo.text);
    drawText(dc, mLastInfo.text, Settings.resource(Rez.Fonts.SecondaryIndicatorFont), locX - offset + Settings.get("iconSize") + Settings.get("strokeWidth"));
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
  }

  function drawText(dc, text, font, xPos) {
    dc.drawText(xPos, locY - 1, font, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function setClippingRegion(dc, offset, penSize) {
    var contentDimensions = getDimensions(dc);
    dc.setColor(themeColor(Color.TEXT_ACTIVE), themeColor(Color.BACKGROUND));
    dc.setClip(locX - offset, locY - contentDimensions[1] / 2 - penSize / 2, contentDimensions[0] + penSize, contentDimensions[1] + penSize);
    dc.clear();
  }

  function getDimensions(dc) as Array<Number> {
    var dim = dc.getTextDimensions("000", Settings.resource(Rez.Fonts.SecondaryIndicatorFont)) as Array<Number>;
    dim[0] = dim[0] + Settings.get("iconSize");
    if (dim[1] < Settings.get("iconSize")) {
      dim[1] = Settings.get("iconSize");
    }

    return dim;
  }
}
