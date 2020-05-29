using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;


class OuterRing extends Ui.Drawable {

  const START_DEGREE = 90;
  const ARC_DEGREE = 360; 

  var mWidth;
  var mHeight;
  var mRadius;

  function initialize(params) {
    Drawable.initialize(params);
    
    mWidth = System.getDeviceSettings().screenWidth;
    mHeight = System.getDeviceSettings().screenHeight;
    mRadius = mWidth / 2.0 * 0.965;
  }

  function draw(dc) {
    dc.setPenWidth(mWidth * PTS);
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    drawArc(dc, 1);
        
    var fillLevel = 0.5;
    dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
    drawArc(dc, fillLevel);
  }
  
  function drawArc(dc, fillLevel) {
    var endDegree = START_DEGREE - ARC_DEGREE * fillLevel;
    dc.drawArc(
      mWidth / 2.0, 
      mHeight / 2.0, 
      mRadius, 
      Graphics.ARC_CLOCKWISE, 
      START_DEGREE, 
      endDegree
    );
  }
}