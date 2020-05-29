using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;
using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.SensorHistory;

enum {
  DF_HEARTRATE = 1,
  DF_BATTERY,
  DF_INTENSITY,
  DF_CALORIES,
  DF_MESSAGES,
  DF_STEPS
}

class SecondaryDataField extends Ui.Drawable {

  hidden var mField;
  hidden var mIconSize;
  hidden var mYPos;
  hidden var mX1Pos;
  hidden var mX2Pos;
  hidden var mX3Pos;

  function initialize(params) {
      Drawable.initialize(params);
    mField = params.get(:field);
    
    mYPos = App.getApp().gSecondaryDataFieldYPos;
    mX1Pos = App.getApp().gSecondaryDataFieldXPos1;
    mX2Pos = App.getApp().gSecondaryDataFieldXPos1;
    mX3Pos = App.getApp().gSecondaryDataFieldXPos1;
    }
    
    function draw(dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    switch(mField) {
       case 1:
         drawDataField1(dc);
            break;
          
        case 2:
          drawDataField2(dc);
          break;
        
        case 3:
          drawDataField3(dc);
          break;
}
    }
    
    function drawDataField1(dc) {
      var text = "78"; // TODO
      var icon = "1"; // Heartbeat
      var iconWidth = dc.getTextWidthInPixels(icon, Ui.loadResource(Rez.Fonts.IconsFont));
      drawIcon(dc, icon, mX1Pos);
      drawText(dc, text, mX1Pos + iconWidth);
    }
    
    function drawDataField2(dc) {
      var text = "3"; // TODO
      var icon = "5"; // Messages
    }
    
    function drawDataField3(dc) {
    }
    
    function drawIcon(dc, icon, xPos) {
      dc.drawText(
        xPos, 
        App.getApp().gSecondaryDataFieldYPos,
        Ui.loadResource(Rez.Fonts.IconsFont),
        icon, 
        Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
    
    function drawText(dc, text, xPos) {
      dc.drawText(
        xPos, 
        App.getApp().gSecondaryDataFieldYPos, 
        Ui.loadResource(Rez.Fonts.SecondaryIndicatorFont),
        text, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
}