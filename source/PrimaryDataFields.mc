using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;
using Toybox.ActivityMonitor;

class BottomDataField extends PrimaryDataField {

  function initialize(params) {
    PrimaryDataField.initialize(params, /* x in % */ 0.5, /* y in % */ 0.89);
  }

  function draw(dc) {
    PrimaryDataField.draw(dc);
    var color = Graphics.COLOR_YELLOW;
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);

    var activityInfo = ActivityMonitor.getInfo();
    var text = activityInfo.steps;
    var icon = "6"; // Steps Icon

    PrimaryDataField.drawIcon(dc, icon, mXPos, mYPos);
    PrimaryDataField.drawText(dc, text, mXPos, mYPos - mIconSize - mHeight * SCALE_STROKE_THICKNESS);
    GoalMeter.drawOuterRing(dc, color, activityInfo.steps.toDouble() / activityInfo.stepGoal);
  }
}

class RightDataField extends PrimaryDataField {

  function initialize(params) {
    PrimaryDataField.initialize(params, /* x in % */ 0.63, /* y in % */ 0.094);
  }

  function draw(dc) {
    PrimaryDataField.draw(dc);
    var color = Graphics.COLOR_BLUE;
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);

    var activityInfo = ActivityMonitor.getInfo();
    var text = activityInfo.activeMinutesDay.total;
    var icon = "3"; // Active Minutes Icon

    PrimaryDataField.drawIcon(dc, icon, mXPos, mYPos);
    PrimaryDataField.drawText(dc, text, mXPos, mYPos + mIconSize - mHeight * SCALE_STROKE_THICKNESS * 3);

    GoalMeter.drawRightRing(dc, color, activityInfo.activeMinutesDay.total.toDouble() / activityInfo.activeMinutesWeekGoal);
  }
}

class LeftDataField extends PrimaryDataField {

  function initialize(params) {
    PrimaryDataField.initialize(params, /* x in % */ 0.37, /* y in % */ 0.094);
  }

  function draw(dc) {
    PrimaryDataField.draw(dc);
    var color = Graphics.COLOR_RED;
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);

    var batteryLevel = System.getSystemStats().battery;
    var text = Math.round(batteryLevel).format("%2.0d") + " %";
    var icon = "2"; // Power Icon

    PrimaryDataField.drawIcon(dc, icon, mXPos, mYPos);
    PrimaryDataField.drawText(dc, text, mXPos, mYPos + mIconSize - mHeight * SCALE_STROKE_THICKNESS * 3);

    GoalMeter.drawLeftRing(dc, color, batteryLevel / 100.0);
  }
}

class PrimaryDataField extends Ui.Drawable {

  hidden var mHeight;
  hidden var mXPos;
  hidden var mYPos;
  hidden var mIconSize;

  function initialize(params, x, y) {
    Drawable.initialize(params);
    mHeight = System.getDeviceSettings().screenHeight;
    mXPos = System.getDeviceSettings().screenWidth * x;
    mYPos = System.getDeviceSettings().screenHeight * y;
    mIconSize = App.getApp().gIconSize;
  }

  function draw(dc) { /* override */ }

  function drawIcon(dc, icon, xPos, yPos) {
    dc.drawText(
        xPos,
        yPos,
        Ui.loadResource(Rez.Fonts.IconsFont),
        icon,
        Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  function drawText(dc, text, xPos, yPos) {
    dc.drawText(
        xPos,
        yPos,
        Ui.loadResource(Rez.Fonts.PrimaryIndicatorFont),
        text,
        Graphics.TEXT_JUSTIFY_CENTER
    );
  }
}