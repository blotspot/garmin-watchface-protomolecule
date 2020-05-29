using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;

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
	  mX2Pos = App.getApp().gSecondaryDataFieldXPos2;
	  mX3Pos = App.getApp().gSecondaryDataFieldXPos3;
	  
	  mIconSize = App.getApp().gIconSize;
  }
  
  function draw(dc) {
	  dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
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
    var icon = "0"; // Heartbeat
    
    drawIcon(dc, icon, mX1Pos);
    drawText(dc, text, mX1Pos + mIconSize);
  }
  
  function drawDataField2(dc) {
    var text = "3"; // TODO
    var icon = "5"; // Messages
    var offset = (mIconSize + dc.getTextWidthInPixels(text, Ui.loadResource(Rez.Fonts.SecondaryIndicatorFont))) / 2.0;
    
    drawIcon(dc, icon, mX2Pos - offset);
    drawText(dc, text, mX2Pos - offset + mIconSize);
  }
  
  function drawDataField3(dc) {
    var text = "150"; // TODO
    var icon = "3"; // Workout
    var offset = (mIconSize + dc.getTextWidthInPixels(text, Ui.loadResource(Rez.Fonts.SecondaryIndicatorFont)));
    
    drawIcon(dc, icon, mX3Pos - offset);
    drawText(dc, text, mX3Pos - offset + mIconSize);
  }
  
  function drawIcon(dc, icon, xPos) {
    dc.drawText(
	    xPos, 
	    mYPos,
	    Ui.loadResource(Rez.Fonts.IconsFont),
	    icon, 
	    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
  
  function drawText(dc, text, xPos) {
    dc.drawText(
	    xPos, 
	    mYPos, 
	    Ui.loadResource(Rez.Fonts.SecondaryIndicatorFont),
	    text, 
	    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
}