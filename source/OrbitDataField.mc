using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi as Ui;

class OrbitDataField extends DataFieldDrawable {

  hidden var mStartDegree;
  hidden var mTotalDegree;
  hidden var mRadius;

  function initialize(params) {
    DataFieldDrawable.initialize(params);

    mStartDegree = params[:startDegree];
    mTotalDegree = params[:totalDegree];
    mRadius = params[:radius];
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      update(dc);
    }
  }

  function update(dc) {
    setClippingRegion(dc, app.gStrokeWidth);
    setAntiAlias(dc, true);
    dc.setPenWidth(app.gStrokeWidth);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }
    // draw remaining arc first so it wont overdraw our endpoint
    drawRemainingArc(dc, mLastInfo.progress, mLastInfo.fieldType == FieldType.BATTERY);
    drawProgressArc(dc, mLastInfo.progress, mLastInfo.fieldType == FieldType.BATTERY);
    drawIcon(dc);

    setAntiAlias(dc, false);
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
  }

  hidden function drawProgressArc(dc, fillLevel, reverse) {
    dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    if (fillLevel > 0.0) {
      var startDegree = reverse ? mStartDegree - mTotalDegree + getFillDegree(fillLevel) : mStartDegree;
      var endDegree = reverse ? mStartDegree - mTotalDegree : mStartDegree - getFillDegree(fillLevel);

      dc.drawArc(
        app.gCenterXPos,
        app.gCenterYPos,
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        endDegree
      );
      if (fillLevel < 1.0) {
        drawEndpoint(dc, reverse ? startDegree : endDegree);
      }
    }
  }

  hidden function drawRemainingArc(dc, fillLevel, reverse) {
    if (fillLevel < 1.0) {
      dc.setColor(themeColor(Color.INACTIVE), Graphics.COLOR_TRANSPARENT);
      var startDegree = reverse ? mStartDegree : mStartDegree - getFillDegree(fillLevel);
      var endDegree = mStartDegree - mTotalDegree;
      if (reverse) {
        endDegree += getFillDegree(fillLevel);
      }

      dc.drawArc(
        app.gCenterXPos,
        app.gCenterYPos,
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        endDegree
      );
    }
  }

  hidden function drawEndpoint(dc, degree) {
    var x = getX(dc, degree);
    var y = getY(dc, degree);
    // draw outer colored circle
    dc.fillCircle(x, y, app.gStrokeWidth + app.gStrokeWidth * 0.75);
    // draw inner white circle
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(x, y, app.gStrokeWidth + app.gStrokeWidth * 0.25);
  }

  hidden function drawIcon(dc) {
    if (mLastInfo.progress == 0) {
      dc.setColor(themeColor(Color.TEXT_INACTIVE), Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    }
    var xPos = (mFieldId == FieldId.ORBIT_LEFT) ? getX(dc, mStartDegree - mTotalDegree) - (app.gIconSize / 2) : getX(dc, mStartDegree) + (app.gIconSize / 2);
    var yPos = ((mFieldId == FieldId.ORBIT_LEFT) ? getY(dc, mStartDegree - mTotalDegree) : getY(dc, mStartDegree)) + app.gIconSize;

    if (mFieldId == FieldId.ORBIT_OUTER) {
      xPos = app.gCenterXPos;
      yPos = app.gCenterYPos + mRadius - app.gIconSize * (app.gShowOrbitIndicatorText ? 2 : 1); 
    }

    mLastInfo.icon.invoke(
      dc,
      xPos,
      yPos, 
      app.gIconSize, 
      app.gStrokeWidth,
      mLastInfo.text
    );
    if (app.gShowOrbitIndicatorText) {
      yPos += app.gIconSize;
      dc.drawText(
        xPos,
        yPos - 1,
        app.getTextFont(),
        mLastInfo.text,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  hidden function getX(dc, degree) {
    degree = Math.toRadians(degree);
    return app.gCenterXPos + mRadius * Math.cos(degree);
  }

  hidden function getY(dc, degree) {
    degree = Math.toRadians(degree);
    return dc.getHeight() - (app.gCenterYPos + mRadius * Math.sin(degree));
  }

  hidden function getFillDegree(fillLevel) {
    return mTotalDegree * fillLevel;
  }

  hidden function setClippingRegion(dc, penSize) {
    dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    
    clearClip(dc);
  }

  hidden function getForeground() {
    if (mFieldId == FieldId.ORBIT_OUTER) {
      return themeColor(Color.PRIMARY);
    } else if (mFieldId == FieldId.ORBIT_LEFT) {
      return themeColor(Color.SECONDARY_1);
    } else if (mFieldId == FieldId.ORBIT_RIGHT) {
      return themeColor(Color.SECONDARY_2);
    }
    return themeColor(Color.FOREGROUND);
  }
} 