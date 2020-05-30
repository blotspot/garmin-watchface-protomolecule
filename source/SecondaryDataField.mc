using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;
using Color;

class SecondaryDataField extends Ui.Drawable {

  hidden var mFieldId;
  hidden var mOffsetMod;

  hidden var mIconSize;
  hidden var mYPos;
  hidden var mXPos;

  function initialize(params) {
    Drawable.initialize(params);

    mIconSize = App.getApp().gIconSize;
    mFieldId = params[:fieldId];
    mOffsetMod = params[:offsetModifier];
    mXPos = params[:relativeXPos] * System.getDeviceSettings().screenWidth;
    mYPos = 0.726 * System.getDeviceSettings().screenHeight;
  }

  function draw(dc) {
    var info = DataFieldInfo.getInfoForField(mFieldId);
    var dimensions = getDimensions(dc, info);
//    setClippingRegion(dc, dimensions);

    if (info.text.equals("0")) {
      dc.setColor(Color.INACTIVE, Color.BACKGROUND);
    } else {
      dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    }
    var offset = dimensions[0] * mOffsetMod;

    drawText(dc, info.icon, Rez.Fonts.IconsFont, mXPos - offset);
    drawText(dc, info.text, Rez.Fonts.SecondaryIndicatorFont, mXPos - offset + mIconSize);
  }

  function drawText(dc, text, font, xPos) {
    dc.drawText(
      xPos,
      mYPos,
      Ui.loadResource(font),
      text,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function setClippingRegion(dc, contentDimensions) {
    dc.setClip(
      mXPos - 1 - contentDimensions[0] * mOffsetMod,
      mYPos - 1 - contentDimensions[1] / 2,
      contentDimensions[0] + 1,
      contentDimensions[1] + 1
    );
  }

  function getDimensions(dc, info) {
    var dim = dc.getTextDimensions(info.text, Ui.loadResource(Rez.Fonts.SecondaryIndicatorFont));
    dim[0] = dim[0] + mIconSize;
    if (dim[1] < mIconSize) {
      dim[1] = mIconSize;
    }

    return dim;
  }
}