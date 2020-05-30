using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;

class GoalIndicator {

  static function drawOuterRing(dc, color, fillLevel) {
    var ring = new GoalIndicator(
      /* scaling */ 0.965,
      /* startDegree */ 90,
      /* totalOrbitDegree */ 360
    );

    ring.draw(dc, color, fillLevel);
  }

  static function drawRightRing(dc, color, fillLevel) {
    var ring = new GoalIndicator(
      /* scaling */ 0.9,
      /* startDegree */ 82,
      /* totalOrbitDegree */ 150
    );

    ring.draw(dc, color, fillLevel);
  }

  static function drawLeftRing(dc, color, fillLevel) {
    var ring = new GoalIndicator(
      /* scaling */ 0.9,
      /* startDegree */ 248,
      /* totalOrbitDegree */ 150
    );

    ring.draw(dc, color, fillLevel);
  }

  private var mStartDegree;
  private var mTotalOrbitDegree;
  private var mWidth;
  private var mHeight;
  private var mRadius;

  function initialize(orbitScaling, startDegree, totalOrbitDegree) {
    mStartDegree = startDegree;
    mTotalOrbitDegree = totalOrbitDegree;
    mWidth = System.getDeviceSettings().screenWidth;
    mHeight = System.getDeviceSettings().screenHeight;
    mRadius = mWidth / 2.0 * orbitScaling;
  }

  function draw(dc, color, fillLevel) {
    dc.setPenWidth(mWidth * SCALE_STROKE_THICKNESS);
    if (fillLevel > 1.0) {
      fillLevel = 1.0;
    }

    dc.setColor(color, Color.BACKGROUND);
    drawProgressArc(dc, fillLevel);

    dc.setColor(Color.INACTIVE, Color.BACKGROUND);
    drawRemainingArc(dc, fillLevel);
  }

  function drawProgressArc(dc, fillLevel) {
    if (fillLevel > 0.0) {
      var endDegree = mStartDegree - mTotalOrbitDegree * fillLevel;

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
      var startDegree = mStartDegree - mTotalOrbitDegree * fillLevel;
      var obj = dc.drawArc(
        mWidth / 2.0, // x center of ring
        mHeight / 2.0, // y center of ring
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        mStartDegree - mTotalOrbitDegree
      );
    }
  }
}