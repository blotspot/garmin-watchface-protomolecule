using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;


class InnerRing extends Ui.Drawable {

  const gRightStartDegree = 82;
  const gLeftStartDegree = 248;
  const gArcDegree = 150; 

  var mWidth;
  var mHeight;
  var mRadius;
  var mSide;

  function initialize(params) {
    Drawable.initialize(params);
    
    mWidth = System.getDeviceSettings().screenWidth;
    mHeight = System.getDeviceSettings().screenHeight;
    mRadius = mWidth / 2.0 * 0.9;
    
    mSide = params.get(:side);
  }

  function draw(dc) {
    dc.setPenWidth(mWidth * 0.006);
    
    switch(mSide) {
      case "RIGHT":
        drawRightArc(dc);
        break;
        
      case "LEFT":
        drawLeftArc(dc);
        break;
    }
  }
  
  function drawRightArc(dc) {
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    drawArc(dc, gRightStartDegree, 1);
        
    var fillLevel = 0.2;
    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    drawArc(dc, gRightStartDegree, fillLevel);
  }
  
  function drawLeftArc(dc) {
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    drawArc(dc, gLeftStartDegree, 1);
        
    var fillLevel = 0.8;
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    drawArc(dc, gLeftStartDegree, fillLevel);
  }
  
  function drawArc(dc, startDegree, fillLevel) {
    var endDegree = startDegree - gArcDegree * fillLevel;
    var obj = dc.drawArc(
      mWidth / 2.0, 
      mHeight / 2.0, 
      mRadius, 
      Graphics.ARC_CLOCKWISE, 
      startDegree, 
      endDegree
    );
  }
}