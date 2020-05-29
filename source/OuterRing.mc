using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application as App;


var gOuterStartDegree = 90;
var gOuterArcDegree = 360; 
  
class OuterRing extends Ui.Drawable {

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
    dc.setPenWidth(mWidth * 0.006);
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    drawArc(dc, 1);
        
    var fillLevel = 0.5;
    dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
    drawArc(dc, fillLevel);
  }
  
  function drawArc(dc, fillLevel) {
    var endDegree = gOuterStartDegree - gOuterArcDegree * fillLevel;
    dc.drawArc(
      mWidth / 2.0, 
      mHeight / 2.0, 
      mRadius, 
      Graphics.ARC_CLOCKWISE, 
      gOuterStartDegree, 
      endDegree
    );
  }
}