using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math;

class GoalIndicator extends DataFieldDrawable {

  hidden var mStartDegree;
  hidden var mTotalDegree;
  hidden var mWidth;
  hidden var mHeight;
  hidden var mRadius;

  function initialize(params) {
    DataFieldDrawable.initialize(params);
    mStartDegree = params[:startDegree];
    mTotalDegree = params[:totalDegree];
    mWidth = System.getDeviceSettings().screenWidth;
    mHeight = System.getDeviceSettings().screenHeight;
    mRadius = mWidth / 2.0 * params[:scaling];
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    update(dc);
  }

  function update(dc) {
    if (dc has :clearClip) {
      dc.clearClip();
    }
    dc.setPenWidth(mWidth >= AMOLED_DISPLAY_SIZE ? 4 : 2);
    var mLastInfo = DataFieldInfo.getInfoForField(mFieldId);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }

    if (Application.getApp().gDrawRemainingIndicator) {
      dc.setColor(Graphics.COLOR_DK_GRAY, Color.BACKGROUND);
      drawRemainingArc(dc, mLastInfo.progress, mLastInfo.fieldType == FieldType.BATTERY);
    }

    dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    drawProgressArc(dc, mLastInfo.progress, mLastInfo.fieldType == FieldType.BATTERY);
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
  }

  hidden function drawProgressArc(dc, fillLevel, reverse) {
    if (fillLevel > 0.0) {
      var startDegree = reverse ? mStartDegree - mTotalDegree + getFillDegree(fillLevel) : mStartDegree;
      var endDegree = reverse ? mStartDegree - mTotalDegree : mStartDegree - getFillDegree(fillLevel);

      dc.drawArc(
        mWidth / 2.0, // x center of ring
        mHeight / 2.0, // y center of ring
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        endDegree
      );
      if (fillLevel < 1.0) {
        drawEndpoint(dc, reverse ? startDegree : endDegree);
      }
    }
  }

  hidden function drawRemainingArc(dc, fillLevel, reverse) {
    if (fillLevel < 1.0) {
      var startDegree = reverse ? mStartDegree : mStartDegree - getFillDegree(fillLevel);
      var endDegree =  mStartDegree - mTotalDegree;
      if (reverse) {
        endDegree += getFillDegree(fillLevel);
      }

      dc.drawArc(
        mWidth / 2.0, // x center of ring
        mHeight / 2.0, // y center of ring
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        endDegree
      );
    }
  }

  hidden function drawEndpoint(dc, degree) {
    degree = Math.toRadians(degree);
    var x = mWidth / 2.0 + mRadius * Math.cos(degree);
    var y = mHeight - (mHeight / 2.0 + mRadius * Math.sin(degree));
    dc.fillCircle(x, y, mWidth >= AMOLED_DISPLAY_SIZE ? 5 : 3);

    dc.setColor(Graphics.COLOR_WHITE, Color.BACKGROUND);
    dc.fillCircle(x, y, mWidth >= AMOLED_DISPLAY_SIZE ? 3 : 2);
  }

  hidden function getFillDegree(fillLevel) {
    return mTotalDegree * fillLevel;
  }
}