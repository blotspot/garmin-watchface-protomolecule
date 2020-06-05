using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.ActivityMonitor;

class PrimaryDataField extends DataFieldDrawable {

  hidden var mHeight;
  hidden var mXPos;
  hidden var mYPos;
  hidden var mTextTop;

  hidden var mTextFont;
  hidden var mIconFont;

  function initialize(params) {
    DataFieldDrawable.initialize(params);
    var device = System.getDeviceSettings();
    mHeight = device.screenHeight;
    mXPos = params[:relativeXPos] * device.screenWidth;
    mYPos = params[:relativeYPos] * device.screenHeight;

    mTextTop = params[:textTop];

    mTextFont = Ui.loadResource(Rez.Fonts.PrimaryIndicatorFont);
    mIconFont = Ui.loadResource(Rez.Fonts.IconsFont);
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    update(dc);
  }

  function update(dc) {
    setClippingRegion(dc);
    dc.setColor(themeColor(mFieldId), Color.BACKGROUND);

    if (mTextTop) {
      drawText(dc, mLastInfo.text, mYPos - 1, mTextFont);
      drawText(dc, mLastInfo.icon, mYPos + Application.getApp().gIconSize, mIconFont);
    } else {
      drawText(dc, mLastInfo.text, mYPos + (Application.getApp().gIconSize - 4), mTextFont);
      drawText(dc, mLastInfo.icon, mYPos, mIconFont);
    }
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
  }

  hidden function drawText(dc, text, yPos, font) {
    dc.drawText(mXPos, yPos, font, text, Graphics.TEXT_JUSTIFY_CENTER);
  }

  hidden function setClippingRegion(dc) {
    dc.setColor(themeColor(mFieldId), Graphics.COLOR_BLACK);
    var contentDimensions = getDimensions(dc);
    dc.setClip(
      mXPos - contentDimensions[0] / 2,
      mYPos,
      contentDimensions[0],
      contentDimensions[1] - 2
    );
    dc.clear();
  }

  hidden function getDimensions(dc) {
    var dim = dc.getTextDimensions(mLastInfo.text, mTextFont);
    dim[1] = dim[1] + Application.getApp().gIconSize;
    if (dim[0] < Application.getApp().gIconSize) {
      dim[0] = Application.getApp().gIconSize;
    }

    return dim;
  }
}