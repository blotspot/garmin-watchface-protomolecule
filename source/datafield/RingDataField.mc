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

  (:debug)
  function draw(dc) {
    AbstractRingDataField.draw(dc);
    drawHitbox(dc, Graphics.COLOR_BLUE);
  }

  protected function getHitbox() {
    if (mFieldId == Enums.FIELD_CIRCLES_OUTER) {
      var height = Settings.iconSize * 1.5;
      return {
        :width => Settings.iconSize * 2,
        :height => height,
        :x => System.getDeviceSettings().screenWidth / 2 - Settings.iconSize,
        :y => System.getDeviceSettings().screenHeight - height,
      };
    } else {
      return {
        :width => mRadius * 2,
        :height => mRadius * 2,
        :x => locX - mRadius,
        :y => locY - mRadius,
      };
    }
  }
}

class AbstractRingDataField extends DataFieldDrawable {
  private var mShowIcon as Boolean;
  protected var mRadius as Numeric;

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
      drawDataField(dc, false);
    }
  }

  protected function drawDataField(dc, partial as Boolean) {
    setClippingRegion(dc);
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
    dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    dc.setClip(locX - (mRadius + Settings.strokeWidth), locY - (mRadius + Settings.strokeWidth), (mRadius + Settings.strokeWidth) * 2, (mRadius + Settings.strokeWidth) * 2);
  }

  private function getForeground() as ColorType {
    switch (mFieldId) {
      case Enums.FIELD_CIRCLES_OUTER:
        return $.themeColor(Enums.COLOR_PRIMARY);
      case Enums.FIELD_CIRCLES_UPPER_1:
      case Enums.FIELD_CIRCLES_UPPER_2:
        return $.themeColor(Enums.COLOR_SECONDARY_1);
      case Enums.FIELD_CIRCLES_LOWER_1:
      case Enums.FIELD_CIRCLES_LOWER_2:
        return $.themeColor(Enums.COLOR_SECONDARY_2);
      default:
        return Graphics.COLOR_WHITE;
    }
  }
}
