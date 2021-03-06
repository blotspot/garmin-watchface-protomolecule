using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi as Ui;

class RingDataField extends DataFieldDrawable {

  hidden var mCenterXPos;
  hidden var mCenterYPos;
  hidden var mShowIcon;
  hidden var mRadius;

  function initialize(params) {
    DataFieldDrawable.initialize(params);
    
    mCenterXPos = params[:centerXPos];
    mCenterYPos = params[:centerYPos];
    mShowIcon = params[:showIcon];
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
    dc.setPenWidth(app.gStrokeWidth * 1.5);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }
    drawProgressArc(dc, mLastInfo.progress);

    if (mShowIcon) {
      if (mLastInfo.progress == 0) {
        dc.setColor(themeColor(Color.SECONDARY_INACTIVE), Graphics.COLOR_TRANSPARENT);
      } else {
        dc.setColor(themeColor(Color.SECONDARY_ACTIVE), Graphics.COLOR_TRANSPARENT);
      }
      mLastInfo.icon.invoke(
        dc,
        mCenterXPos,
        mCenterYPos, 
        app.gIconSize, 
        app.gStrokeWidth,
        mLastInfo.text
      );
    }

    setAntiAlias(dc, false);
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
  }

  hidden function drawProgressArc(dc, fillLevel) {
    if (fillLevel > 0.0) {
      var startDegree = 90;
      var endDegree = startDegree - 360 * fillLevel;

      dc.drawArc(
        mCenterXPos, // x center of ring
        mCenterYPos, // y center of ring
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        endDegree
      );
    }
  }

  hidden function setClippingRegion(dc, penSize) {
    dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    
    dc.setClip(
      mCenterXPos - (mRadius + penSize),
      mCenterYPos - (mRadius + penSize),
      (mRadius + penSize * 2) * 2,
      (mRadius + penSize * 2) * 2
    );
    dc.clear();
  }

  hidden function getForeground() {
    if (mFieldId == FieldId.OUTER || mFieldId == FieldId.SLEEP_BATTERY) {
      return themeColor(Color.OUTER);
    } else if (mFieldId == FieldId.UPPER_1) {
      return themeColor(Color.UPPER_1);
    } else if (mFieldId == FieldId.UPPER_2) {
      return themeColor(Color.UPPER_2);
    } else if (mFieldId == FieldId.LOWER_1) {
      return themeColor(Color.LOWER_1);
    } else if (mFieldId == FieldId.LOWER_2) {
      return themeColor(Color.LOWER_2);
    }
    return themeColor(Color.FOREGROUND);
  }
}