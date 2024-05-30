import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.Lang;

class RingDataField extends DataFieldDrawable {
  hidden var mShowIcon;
  hidden var mRadius;

  (:typecheck(false))
  function initialize(params) {
    DataFieldDrawable.initialize(params);
    mShowIcon = params[:showIcon];
    mRadius = params[:radius];
    locX = params[:x];
    locY = params[:y];
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      update(dc);
    }
  }

  function update(dc) {
    setClippingRegion(dc, Settings.get("strokeWidth"));
    setAntiAlias(dc, true);
    dc.setPenWidth(Settings.get("strokeWidth") * 1.5);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }
    drawProgressArc(dc, mLastInfo.progress);

    if (mShowIcon) {
      if (mLastInfo.progress == 0) {
        dc.setColor(themeColor(Color.TEXT_INACTIVE), Graphics.COLOR_TRANSPARENT);
      } else {
        dc.setColor(themeColor(Color.TEXT_ACTIVE), Graphics.COLOR_TRANSPARENT);
      }
      mLastInfo.icon.invoke(dc, locX, locY, Settings.get("iconSize"), Settings.get("strokeWidth"), mLastInfo.text);
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
        locX, // x center of ring
        locY, // y center of ring
        mRadius,
        Graphics.ARC_CLOCKWISE,
        startDegree,
        endDegree
      );
    }
  }

  hidden function setClippingRegion(dc, penSize) {
    dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);

    dc.setClip(locX - (mRadius + penSize), locY - (mRadius + penSize), (mRadius + penSize * 2) * 2, (mRadius + penSize * 2) * 2);
    dc.clear();
  }

  hidden function getForeground() {
    if (mFieldId == FieldId.OUTER || mFieldId == FieldId.SLEEP_BATTERY) {
      return themeColor(Color.PRIMARY);
    } else if (mFieldId == FieldId.UPPER_1) {
      return themeColor(Color.SECONDARY_1);
    } else if (mFieldId == FieldId.UPPER_2) {
      return themeColor(Color.SECONDARY_1);
    } else if (mFieldId == FieldId.LOWER_1) {
      return themeColor(Color.SECONDARY_2);
    } else if (mFieldId == FieldId.LOWER_2) {
      return themeColor(Color.SECONDARY_2);
    }
    return themeColor(Color.FOREGROUND);
  }
}
