using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi as Ui;

class GoalIndicator extends DataFieldDrawable {

  hidden var mStartDegree;
  hidden var mTotalDegree;
  hidden var mRadius;

  function initialize(params) {
    DataFieldDrawable.initialize(params);
    
    mStartDegree = params[:startDegree];
    mTotalDegree = params[:totalDegree];
    mRadius = params[:radius];
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      update(dc);
    }
  }

  function update(dc) {
    clearClip(dc);
    setAntiAlias(dc, true);
    dc.setPenWidth(app.gStrokeWidth);
    var mLastInfo = DataFieldInfo.getInfoForField(mFieldId);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }

    if (app.gDrawRemainingIndicator) {
      dc.setColor(themeColor(Color.INACTIVE), Graphics.COLOR_TRANSPARENT);
      drawRemainingArc(dc, mLastInfo.progress, mLastInfo.fieldType == FieldType.BATTERY);
    }

    dc.setColor(themeColor(mFieldId), Graphics.COLOR_TRANSPARENT);
    drawProgressArc(dc, mLastInfo.progress, mLastInfo.fieldType == FieldType.BATTERY);

    setAntiAlias(dc, false);
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
  }

  hidden function drawProgressArc(dc, fillLevel, reverse) {
    if (fillLevel > 0.0) {
      var startDegree = reverse ? mStartDegree - mTotalDegree + getFillDegree(fillLevel) : mStartDegree;
      var endDegree = reverse ? mStartDegree - mTotalDegree : mStartDegree - getFillDegree(fillLevel);

      dc.drawArc(
        dc.getWidth() / 2.0, // x center of ring
        dc.getHeight() / 2.0, // y center of ring
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
        dc.getWidth() / 2.0, // x center of ring
        dc.getHeight() / 2.0, // y center of ring
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        endDegree
      );
    }
  }

  hidden function drawEndpoint(dc, degree) {
    degree = Math.toRadians(degree);
    var x = dc.getWidth() / 2.0 + mRadius * Math.cos(degree);
    var y = dc.getHeight() - (dc.getHeight() / 2.0 + mRadius * Math.sin(degree));
    dc.fillCircle(x, y, app.gStrokeWidth + app.gStrokeWidth * 0.75);

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(x, y, app.gStrokeWidth + app.gStrokeWidth * 0.25);
  }

  hidden function getFillDegree(fillLevel) {
    return mTotalDegree * fillLevel;
  }
}