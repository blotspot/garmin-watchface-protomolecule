using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;
using Toybox.ActivityMonitor;

class BottomDataField extends PrimaryDataFieldDrawable {

  function initialize(params) {
    PrimaryDataFieldDrawable.initialize(params, /* x in % */ 0.5, /* y in % */ 0.89);
  }

  function draw(dc) {
    PrimaryDataFieldDrawable.draw(dc);
    var color = themeColor(FieldId.PRIMARY_BOTTOM);
    dc.setColor(color, Color.BACKGROUND);

    var info = DataFieldInfo.getInfoForField(FieldId.PRIMARY_BOTTOM);

    PrimaryDataFieldDrawable.drawIcon(dc, info.icon, mXPos, mYPos);
    PrimaryDataFieldDrawable.drawText(dc, info.text, mXPos, mYPos - mIconSize - mHeight * SCALE_STROKE_THICKNESS);
    GoalIndicator.drawOuterRing(dc, color, info.progress);
  }
}

class RightDataField extends PrimaryDataFieldDrawable {

  function initialize(params) {
    PrimaryDataFieldDrawable.initialize(params, /* x in % */ 0.63, /* y in % */ 0.094);
  }

  function draw(dc) {
    PrimaryDataFieldDrawable.draw(dc);
    var color = themeColor(FieldId.PRIMARY_RIGHT);
    dc.setColor(color, Color.BACKGROUND);

    var info = DataFieldInfo.getInfoForField(FieldId.PRIMARY_RIGHT);

    PrimaryDataFieldDrawable.drawIcon(dc, info.icon, mXPos, mYPos);
    PrimaryDataFieldDrawable.drawText(dc, info.text, mXPos, mYPos + mIconSize - mHeight * SCALE_STROKE_THICKNESS * 3);

    GoalIndicator.drawRightRing(dc, color, info.progress);
  }
}

class LeftDataField extends PrimaryDataFieldDrawable {

  function initialize(params) {
    PrimaryDataFieldDrawable.initialize(params, /* x in % */ 0.37, /* y in % */ 0.094);
  }

  function draw(dc) {
    PrimaryDataFieldDrawable.draw(dc);
    var color = themeColor(FieldId.PRIMARY_LEFT);
    dc.setColor(color, Color.BACKGROUND);

    var info = DataFieldInfo.getInfoForField(FieldId.PRIMARY_LEFT);

    PrimaryDataFieldDrawable.drawIcon(dc, info.icon, mXPos, mYPos);
    PrimaryDataFieldDrawable.drawText(dc, info.text, mXPos, mYPos + mIconSize - mHeight * SCALE_STROKE_THICKNESS * 3);

    GoalIndicator.drawLeftRing(dc, color, info.progress);
  }
}

class PrimaryDataFieldDrawable extends Ui.Drawable {

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