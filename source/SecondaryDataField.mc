using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Color;

class SecondaryDataField extends DataFieldDrawable {

  hidden var mOffsetMod;

  hidden var mYPos;
  hidden var mXPos;

  hidden var mTextFont;
  hidden var mIconFont;

  function initialize(params) {
    DataFieldDrawable.initialize(params);

    mFieldId = params[:fieldId];
    mOffsetMod = params[:offsetModifier];
    mXPos = params[:relativeXPos] * System.getDeviceSettings().screenWidth;
    mYPos = 0.685 * System.getDeviceSettings().screenHeight;

    mTextFont = Ui.loadResource(Rez.Fonts.SecondaryIndicatorFont);
    mIconFont = Ui.loadResource(Rez.Fonts.IconsFont);
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    update(dc);
  }

  function update(dc) {
    var fieldWidth = dc.getTextWidthInPixels(mLastInfo.text, mTextFont) + Application.getApp().gIconSize;
    var offset = fieldWidth * mOffsetMod;
    setClippingRegion(dc, offset);

    if (mLastInfo.text.equals("0")) {
      dc.setColor(Color.INACTIVE, Color.BACKGROUND);
    } else {
      dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    }

    drawText(dc, mLastInfo.icon, mIconFont, mXPos - offset);
    drawText(dc, mLastInfo.text, mTextFont, mXPos - offset + Application.getApp().gIconSize);
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
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

  function setClippingRegion(dc, offset) {
    var contentDimensions = getDimensions(dc);
    dc.setColor(themeColor(mFieldId), Graphics.COLOR_BLACK);
    dc.setClip(
      mXPos - offset,
      mYPos + 3 - contentDimensions[1] / 2,
      contentDimensions[0],
      contentDimensions[1] - 2
    );
    dc.clear();
  }

  function getDimensions(dc) {
    var dim = dc.getTextDimensions("999", mTextFont);
    dim[0] = dim[0] + Application.getApp().gIconSize;
    if (dim[1] < Application.getApp().gIconSize) {
      dim[1] = Application.getApp().gIconSize;
    }

    return dim;
  }
}