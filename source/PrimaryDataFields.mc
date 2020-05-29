using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;

class BottomDataField extends PrimaryDataField {

  function initialize(params) {
    PrimaryDataField.initialize(params, 0.5, 0.89);
  }
  
  function draw(dc) {
    dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
    var text = "22500"; // TODO
    var icon = "6"; // Steps
    
    PrimaryDataField.drawIcon(dc, icon, mXPos, mYPos);
    PrimaryDataField.drawText(dc, text, mXPos, mYPos - mIconSize - mHeight * PTS);
  }
}

class RightDataField extends PrimaryDataField {

  function initialize(params) {
    PrimaryDataField.initialize(params, 0.37, 0.094);
  }
  
  function draw(dc) {
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    var text = "72%"; // TODO
    var icon = "2"; // Power
    
    PrimaryDataField.drawIcon(dc, icon, mXPos, mYPos);
    PrimaryDataField.drawText(dc, text, mXPos, mYPos + mIconSize - mHeight * PTS * 3);
  }
}

class LeftDataField extends PrimaryDataField {

  function initialize(params) {
    PrimaryDataField.initialize(params, 0.63, 0.094);
  }
  
  function draw(dc) {
    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    var text = "1380"; // TODO
    var icon = "4"; // Kcal
    
    PrimaryDataField.drawIcon(dc, icon, mXPos, mYPos);
    PrimaryDataField.drawText(dc, text, mXPos, mYPos + mIconSize - mHeight * PTS * 3);
  }
}

class PrimaryDataField extends Ui.Drawable {

  protected var mHeight; 
  protected var mXPos;
  protected var mYPos;
  protected var mIconSize;
  
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