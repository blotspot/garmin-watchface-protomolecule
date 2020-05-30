using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;

class GoalMeter {

  static function drawOuterRing(dc, color, fillLevel) {
    var ring = new GoalMeter(
      /* scaling */ 0.965,
      /* startDegree */ 90,
      /* totalOrbitDegree */ 360
    );

    ring.draw(dc, color, fillLevel);
  }

  static function drawRightRing(dc, color, fillLevel) {
    var ring = new GoalMeter(
      /* scaling */ 0.9,
      /* startDegree */ 82,
      /* totalOrbitDegree */ 150
    );

    ring.draw(dc, color, fillLevel);
  }

  static function drawLeftRing(dc, color, fillLevel) {
    var ring = new GoalMeter(
      /* scaling */ 0.9,
      /* startDegree */ 248,
      /* totalOrbitDegree */ 150
    );

    ring.draw(dc, color, fillLevel);
  }

  hidden var mStartDegree;
  hidden var mTotalOrbitDegree;
  hidden var mWidth;
  hidden var mHeight;
  hidden var mRadius;

  function initialize(orbitScaling, startDegree, totalOrbitDegree) {
    mStartDegree = startDegree;
    mTotalOrbitDegree = totalOrbitDegree;
    mWidth = System.getDeviceSettings().screenWidth;
    mHeight = System.getDeviceSettings().screenHeight;
    mRadius = mWidth / 2.0 * orbitScaling;
  }

  function draw(dc, color, fillLevel) {
    dc.setPenWidth(mWidth * SCALE_STROKE_THICKNESS);

    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    drawOrbit(dc, 1);

    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    drawOrbit(dc, fillLevel);
  }

  function drawOrbit(dc, fillLevel) {
    if (fillLevel > 1.0) {
      fillLevel = 1.0;
    }
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
}