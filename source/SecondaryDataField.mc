using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Color;

class SecondaryDataField extends Ui.Drawable {

  private var mFieldId;
  private var mOffsetMod;

  private var mIconSize;
  private var mYPos;
  private var mXPos;

  private var mTextFont;
  private var mIconFont;

  function initialize(params) {
    Drawable.initialize(params);

    mIconSize = Application.getApp().gIconSize;
    mFieldId = params[:fieldId];
    mOffsetMod = params[:offsetModifier];
    mXPos = params[:relativeXPos] * System.getDeviceSettings().screenWidth;
    mYPos = 0.685 * System.getDeviceSettings().screenHeight;

    mTextFont = Ui.loadResource(Rez.Fonts.SecondaryIndicatorFont);
    mIconFont = Ui.loadResource(Rez.Fonts.IconsFont);
  }

  function draw(dc) {
    setClippingRegion(dc);
    var info = DataFieldInfo.getInfoForField(mFieldId);

    if (info.text.equals("0")) {
      dc.setColor(Color.INACTIVE, Color.BACKGROUND);
    } else {
      dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    }
    var fieldWidth = dc.getTextWidthInPixels(info.text, mTextFont) + mIconSize;
    var offset = fieldWidth * mOffsetMod;

    drawText(dc, info.icon, mIconFont, mXPos - offset);
    drawText(dc, info.text, mTextFont, mXPos - offset + mIconSize);
  }

  function drawText(dc, text, font, xPos) {
    dc.drawText(
      xPos,
      mYPos,
      font,
      text,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function setClippingRegion(dc) {
    var contentDimensions = getDimensions(dc);
    dc.setColor(themeColor(mFieldId), Graphics.COLOR_BLACK);
    dc.setClip(
      mXPos - 1 - contentDimensions[0] * mOffsetMod,
      mYPos - 1 - contentDimensions[1] / 2,
      contentDimensions[0] + 1,
      contentDimensions[1] + 1
    );
    dc.clear();
  }

  function getDimensions(dc) {
    var dim = dc.getTextDimensions("9999", mTextFont);
    dim[0] = dim[0] + mIconSize;
    if (dim[1] < mIconSize) {
      dim[1] = mIconSize;
    }

    return dim;
  }
}