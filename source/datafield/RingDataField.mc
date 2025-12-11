import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.Lang;

class RingDataField extends DataFieldDrawable {
  hidden var mShowIcon as Boolean;
  hidden var mRadius as Numeric;

  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Numeric,
        :locY as Numeric,
        :width as Numeric,
        :height as Numeric,
        :visible as Boolean,
        :fieldId as Number,
        :showIcon as Boolean,
        :radius as Numeric,
        :x as Numeric,
        :y as Numeric,
      }
  ) {
    DataFieldDrawable.initialize(params);
    mShowIcon = params[:showIcon];
    mRadius = params[:radius];
    //! redefine locX / locY.
    //! Doing it the stupid way because the layout isn't allowing a `dc` call in their definition.
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
    setClippingRegion(dc, Settings.strokeWidth);
    saveSetAntiAlias(dc, true);
    dc.setPenWidth(Settings.strokeWidth * 1.5);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }
    drawProgressArc(dc, mLastInfo.progress);

    if (mShowIcon) {
      if (mLastInfo.progress == 0) {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
      } else {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      }
      mLastInfo.icon.resetOffset();
      mLastInfo.icon.drawAt(dc, locX, locY);
    }

    saveSetAntiAlias(dc, false);
  }

  function partialUpdate(dc) {
    DataFieldDrawable.drawPartialUpdate(dc, method(:update));
  }

  hidden function drawProgressArc(dc, fillLevel as Numeric) {
    if (fillLevel > 0.0) {
      var startDegree = 90;
      var endDegree = startDegree - 360 * fillLevel;

      dc.drawArc(
        locX, // x center of ring
        locY, // y center of ring
        mRadius,
        1,
        startDegree,
        endDegree
      );
    }
  }

  hidden function setClippingRegion(dc, penSize as Numeric) {
    dc.setColor(getForeground(), -1);

    dc.setClip(locX - (mRadius + penSize), locY - (mRadius + penSize), (mRadius + penSize * 2) * 2, (mRadius + penSize * 2) * 2);
    dc.clear();
  }

  hidden function getForeground() as ColorType {
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
    return Graphics.COLOR_WHITE;
  }
}
