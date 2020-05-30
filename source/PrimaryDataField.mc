using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;
using Toybox.ActivityMonitor;

class BottomDataField extends PrimaryDataField {

  function initialize(params) {
   PrimaryDataField.initialize(params);
  }

  function draw(dc) {
    PrimaryDataField.draw(dc);
    var color = themeColor(mFieldId);
    dc.setColor(color, Color.BACKGROUND);

    var info = DataFieldInfo.getInfoForField(mFieldId);

    PrimaryDataField.drawIcon(dc, info.icon, mYPos);
    PrimaryDataField.drawText(dc, info.text, mYPos - mIconSize - mHeight * SCALE_STROKE_THICKNESS);

    GoalIndicator.drawOuterRing(dc, color, info.progress);
  }
}

class RightDataField extends PrimaryDataField {

  function initialize(params) {
    PrimaryDataField.initialize(params);
  }

  function draw(dc) {
    PrimaryDataField.draw(dc);
    var color = themeColor(mFieldId);
    dc.setColor(color, Color.BACKGROUND);

    var info = DataFieldInfo.getInfoForField(mFieldId);

    PrimaryDataField.drawIcon(dc, info.icon, mYPos);
    PrimaryDataField.drawText(dc, info.text, mYPos + mIconSize - mHeight * SCALE_STROKE_THICKNESS * 3);

    GoalIndicator.drawRightRing(dc, color, info.progress);
  }
}

class LeftDataField extends PrimaryDataField {

  function initialize(params) {
    PrimaryDataField.initialize(params);
  }

  function draw(dc) {
    PrimaryDataField.draw(dc);
    var color = themeColor(mFieldId);
    dc.setColor(color, Color.BACKGROUND);

    var info = DataFieldInfo.getInfoForField(mFieldId);

    PrimaryDataField.drawIcon(dc, info.icon, mYPos);
    PrimaryDataField.drawText(dc, info.text, mYPos + mIconSize - mHeight * SCALE_STROKE_THICKNESS * 3);

    GoalIndicator.drawLeftRing(dc, color, info.progress);
  }
}

class PrimaryDataField extends Ui.Drawable {

  hidden var mFieldId;

  hidden var mHeight;
  hidden var mXPos;
  hidden var mYPos;
  hidden var mIconSize;

  function initialize(params) {
    Drawable.initialize(params);
    var device = System.getDeviceSettings();
    mFieldId = params[:fieldId];
    mHeight = device.screenHeight;
    mXPos = params[:relativeXPos] * device.screenWidth;
    mYPos = params[:relativeYPos] * device.screenHeight;
    mIconSize = App.getApp().gIconSize;
  }

  function draw(dc) { /* override */ }

  function drawIcon(dc, icon, yPos) {
    dc.drawText(
        mXPos,
        yPos,
        Ui.loadResource(Rez.Fonts.IconsFont),
        icon,
        Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  function drawText(dc, text, yPos) {
    dc.drawText(
        mXPos,
        yPos,
        Ui.loadResource(Rez.Fonts.PrimaryIndicatorFont),
        text,
        Graphics.TEXT_JUSTIFY_CENTER
    );
  }
}