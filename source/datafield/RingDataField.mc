import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.Lang;
import Enums;

(:apiBelow420)
class RingDataField extends AbstractRingDataField {
  function initialize(params) {
    AbstractRingDataField.initialize(params);
  }
}

(:api420AndAbove)
class RingDataField extends AbstractRingDataField {
  function initialize(params) {
    AbstractRingDataField.initialize(params);
    mHitbox = getHitbox();
  }

  function draw(dc) {
    AbstractRingDataField.draw(dc);
    if (Log.isDebugEnabled) {
      drawHitbox(dc, Graphics.COLOR_GREEN);
    }
  }

  hidden function getHitbox() {
    if (mFieldId == Enums.FIELD_OUTER) {
      var height = (Settings.iconSize + Settings.strokeWidth) * 2;
      return {
        :width => Settings.iconSize * 1.75,
        :height => height,
        :x => 0,
        :y => System.getDeviceSettings().screenHeight / 2 - height / 2,
      };
    } else {
      return {
        :width => (mRadius + Settings.strokeWidth) * 2,
        :height => (mRadius + Settings.strokeWidth) * 2,
        :x => locX - (mRadius + Settings.strokeWidth),
        :y => locY - (mRadius + Settings.strokeWidth),
      };
    }
  }
}

class AbstractRingDataField extends DataFieldDrawable {
  private var mShowIcon as Boolean;
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
        :fieldId as FieldId,
        :showIcon as Boolean,
        :radius as Numeric,
        :x as Numeric,
        :y as Numeric,
      }
  ) {
    //! redefine locX / locY.
    //! Doing it the stupid way because the layout isn't allowing a `dc` call in their definition.
    params[:locX] = params[:x];
    params[:locY] = params[:y];
    DataFieldDrawable.initialize(params);
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
    setClippingRegion(dc);
    $.saveSetAntiAlias(dc, true);
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
    $.saveSetAntiAlias(dc, false);
  }

  function partialUpdate(dc) {
    DataFieldDrawable.drawPartialUpdate(dc, method(:update));
  }

  private function drawProgressArc(dc, fillLevel as Numeric) {
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

  private function setClippingRegion(dc) {
    dc.setColor(getForeground(), -1);
    dc.setClip(locX - (mRadius + Settings.strokeWidth), locY - (mRadius + Settings.strokeWidth), (mRadius + Settings.strokeWidth) * 2, (mRadius + Settings.strokeWidth) * 2);
    dc.clear();
  }

  private function getForeground() as ColorType {
    if (mFieldId == Enums.FIELD_OUTER || mFieldId == Enums.FIELD_SLEEP_UP) {
      return $.themeColor(Enums.COLOR_PRIMARY);
    } else if (mFieldId == Enums.FIELD_UPPER_1) {
      return $.themeColor(Enums.COLOR_SECONDARY_1);
    } else if (mFieldId == Enums.FIELD_UPPER_2) {
      return $.themeColor(Enums.COLOR_SECONDARY_1);
    } else if (mFieldId == Enums.FIELD_LOWER_1) {
      return $.themeColor(Enums.COLOR_SECONDARY_2);
    } else if (mFieldId == Enums.FIELD_LOWER_2) {
      return $.themeColor(Enums.COLOR_SECONDARY_2);
    }
    return Graphics.COLOR_WHITE;
  }
}
