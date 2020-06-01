using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;

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
    dc.setPenWidth(mWidth > 390 ? 4 : 2);
    var mLastInfo = DataFieldInfo.getInfoForField(mFieldId);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }

    dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    drawProgressArc(dc, mLastInfo.progress);
//    dc.setColor(Color.INACTIVE, Color.BACKGROUND);
//    drawRemainingArc(dc, fillLevel);
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
  }

  hidden function drawProgressArc(dc, fillLevel) {
    if (fillLevel > 0.0) {
      var endDegree = mStartDegree - mTotalDegree * fillLevel;

      var obj = dc.drawArc(
        mWidth / 2.0, // x center of ring
        mHeight / 2.0, // y center of ring
        mRadius,
        Graphics.ARC_CLOCKWISE,
        mStartDegree,
        endDegree
      );
    }
  }

  hidden function drawRemainingArc(dc, fillLevel) {
    if (fillLevel < 1.0) {
      var startDegree = mStartDegree - mTotalDegree * fillLevel;
      var obj = dc.drawArc(
        mWidth / 2.0, // x center of ring
        mHeight / 2.0, // y center of ring
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        mStartDegree - mTotalDegree
      );
    }
  }
}