using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.ActivityMonitor;

class PrimaryDataField extends Ui.Drawable {

  hidden var mFieldId;

  hidden var mHeight;
  hidden var mXPos;
  hidden var mYPos;
  hidden var mIconSize;
  hidden var mTextTop;
  hidden var mIconPadding;

  function initialize(params) {
    Drawable.initialize(params);
    var device = System.getDeviceSettings();
    mFieldId = params[:fieldId];
    mHeight = device.screenHeight;
    mXPos = params[:relativeXPos] * device.screenWidth;
    mYPos = params[:relativeYPos] * device.screenHeight;
    mIconSize = Application.getApp().gIconSize;

    mTextTop = params[:textTop];
    mIconPadding = getPadding(params[:iconPadding]);
  }

  function draw(dc) {
    setClippingRegion(dc);
    dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    var info = DataFieldInfo.getInfoForField(mFieldId);

    if (mTextTop) {
      drawText(dc, info.text, mYPos);
      drawIcon(dc, info.icon, mYPos + (mIconSize + mIconPadding));
    } else {
      drawText(dc, info.text, mYPos + (mIconSize - mIconPadding));
      drawIcon(dc, info.icon, mYPos);
    }
  }

  hidden function drawIcon(dc, icon, yPos) {
    dc.drawText(
        mXPos,
        yPos,
        Ui.loadResource(Rez.Fonts.IconsFont),
        icon,
        Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  hidden function drawText(dc, text, yPos) {
    dc.drawText(
        mXPos,
        yPos,
        Ui.loadResource(Rez.Fonts.PrimaryIndicatorFont),
        text,
        Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  hidden function getPadding(size) {
    return (mHeight > AMOLED_DISPLAY_SIZE) ? size * 2 : size;
  }

  hidden function setClippingRegion(dc) {
    dc.setColor(themeColor(mFieldId), Graphics.COLOR_BLACK);
    var contentDimensions = getDimensions(dc);
    dc.setClip(
      mXPos - 1 - contentDimensions[0] / 2,
      mYPos - 1,
      contentDimensions[0] + 1,
      contentDimensions[1] + 1
    );
    dc.clear();
  }

  hidden function getDimensions(dc) {
    var dim = dc.getTextDimensions("00000", Ui.loadResource(Rez.Fonts.PrimaryIndicatorFont));
    dim[1] = dim[1] + mIconPadding + mIconSize;
    if (dim[0] < mIconSize) {
      dim[0] = mIconSize;
    }

    return dim;
  }
}