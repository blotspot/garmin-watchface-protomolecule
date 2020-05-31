using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;

class GoalIndicator extends Ui.Drawable {

  private var mFieldId;
  private var mStartDegree;
  private var mTotalDegree;
  private var mWidth;
  private var mHeight;
  private var mRadius;

  function initialize(params) {
    Drawable.initialize(params);
    mFieldId = params[:fieldId];
    mStartDegree = params[:startDegree];
    mTotalDegree = params[:totalDegree];
    mWidth = System.getDeviceSettings().screenWidth;
    mHeight = System.getDeviceSettings().screenHeight;
    mRadius = mWidth / 2.0 * params[:scaling];
  }

  function draw(dc) {
    if (dc has :clearClip) {
      dc.clearClip();
    }
    dc.setPenWidth(mWidth > 390 ? 4 : 2);
    var info = DataFieldInfo.getInfoForField(mFieldId);
    if (info.progress > 1.0) {
      info.progress = 1.0;
    }

    dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    drawProgressArc(dc, info.progress);

//    dc.setColor(Color.INACTIVE, Color.BACKGROUND);
//    drawRemainingArc(dc, fillLevel);
  }

  function drawProgressArc(dc, fillLevel) {
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

  function drawRemainingArc(dc, fillLevel) {
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