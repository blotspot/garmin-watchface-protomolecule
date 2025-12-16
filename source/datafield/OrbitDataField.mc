import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.Lang;
import Enums;

class AbastractOrbitDataField extends DataFieldDrawable {
  protected var mStartDegree as Numeric;
  protected var mTotalDegree as Numeric;
  protected var mRadius as Numeric;

  protected var mArcStartX as Numeric;
  protected var mArcStartY as Numeric;

  private var mShowText as Boolean;

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
        :x as Numeric,
        :y as Numeric,
        :startDegree as Numeric,
        :totalDegree as Numeric,
        :radius as Numeric,
      }
  ) {
    params[:locX] = params.hasKey(:x) ? params[:x] : System.getDeviceSettings().screenWidth * 0.5;
    params[:locY] = params.hasKey(:y) ? params[:y] : System.getDeviceSettings().screenHeight * 0.5;
    DataFieldDrawable.initialize(params);

    mStartDegree = params[:startDegree];
    mTotalDegree = params[:totalDegree];
    mRadius = params[:radius];
    mShowText = Properties.getValue("showOrbitIndicatorText") as Boolean;

    mArcStartX = locX;
    mArcStartY = locY;
    Log.debug("locX:" + locX + ", locY: " + locY);
    if (mFieldId == Enums.FIELD_ORBIT_LEFT) {
      mArcStartX = getX(mStartDegree - mTotalDegree) - Settings.iconSize / 2;
      mArcStartY = getY(System.getDeviceSettings().screenHeight, mStartDegree - mTotalDegree) + Settings.iconSize;
    } else if (mFieldId == Enums.FIELD_ORBIT_RIGHT) {
      mArcStartX = getX(mStartDegree) + Settings.iconSize / 2;
      mArcStartY = getY(System.getDeviceSettings().screenHeight, mStartDegree) + Settings.iconSize;
    } else if (mFieldId == Enums.FIELD_ORBIT_OUTER) {
      mArcStartY = locY + mRadius - Settings.iconSize * (mShowText ? 2 : 1);
    }
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      drawDataField(dc, false);
    }
  }

  protected function drawDataField(dc, partial as Boolean) {
    setClippingRegion(dc);
    dc.setPenWidth(Settings.strokeWidth);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }
    // draw remaining arc first so it wont overdraw our endpoint
    drawRemainingArc(dc, mLastInfo.progress, mLastInfo.reverse);
    drawProgressArc(dc, mLastInfo.progress, mLastInfo.reverse);
    drawIcon(dc);
  }

  private function drawProgressArc(dc, fillLevel as Numeric, reverse as Boolean) {
    dc.setColor(getForeground(), -1);
    if (fillLevel > 0.0) {
      var startDegree = reverse ? mStartDegree - mTotalDegree + getFillDegree(fillLevel) : mStartDegree;
      var endDegree = reverse ? mStartDegree - mTotalDegree : mStartDegree - getFillDegree(fillLevel);

      dc.drawArc(locX, locY, mRadius, Graphics.ARC_CLOCKWISE, startDegree, endDegree);
      if (fillLevel < 1.0) {
        drawEndpoint(dc, reverse ? startDegree : endDegree);
      }
    }
  }

  private function drawRemainingArc(dc, fillLevel as Numeric, reverse as Boolean) {
    if (fillLevel < 1.0) {
      dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
      var startDegree = reverse ? mStartDegree : mStartDegree - getFillDegree(fillLevel);
      var endDegree = mStartDegree - mTotalDegree;
      if (reverse) {
        endDegree += getFillDegree(fillLevel);
      }

      dc.drawArc(locX, locY, mRadius, Graphics.ARC_CLOCKWISE, startDegree, endDegree);
    }
  }

  private function drawEndpoint(dc, degree as Numeric) {
    var x = getX(degree);
    var y = getY(dc.getHeight(), degree);
    // draw outer colored circle
    dc.fillCircle(x, y, Settings.strokeWidth * 1.75);
    // draw inner white circle
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(x, y, Settings.strokeWidth * 1.25);
  }

  private function drawIcon(dc) {
    if (mLastInfo.progress == 0) {
      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    }
    var x = mArcStartX;
    var y = mArcStartY;

    mLastInfo.icon.drawAt(dc, x, y);

    if (mShowText && mLastInfo.text != null) {
      y += Settings.iconSize;
      dc.drawText(x, y - 1, Settings.resource(Rez.Fonts.SecondaryIndicatorFont), mLastInfo.text, 1 | 4);
    }
  }

  private function getX(degree as Numeric) as Numeric {
    degree = Math.toRadians(degree);
    return locX + mRadius * Math.cos(degree);
  }

  private function getY(height as Number, degree as Numeric) as Numeric {
    degree = Math.toRadians(degree);
    return height - (locY + mRadius * Math.sin(degree));
  }

  private function getFillDegree(fillLevel as Numeric) as Numeric {
    return mTotalDegree * fillLevel;
  }

  private function setClippingRegion(dc) {
    switch (mFieldId) {
      case Enums.FIELD_ORBIT_LEFT:
        dc.setClip(0, 0, dc.getWidth(), dc.getHeight());
      case Enums.FIELD_ORBIT_RIGHT:
        dc.setClip(locX, 0, dc.getWidth(), dc.getHeight());
      default:
        $.saveClearClip(dc);
    }
  }

  private function getForeground() as ColorType {
    if (mFieldId == Enums.FIELD_ORBIT_OUTER) {
      return $.themeColor(Enums.COLOR_PRIMARY);
    } else if (mFieldId == Enums.FIELD_ORBIT_LEFT) {
      return $.themeColor(Enums.COLOR_SECONDARY_1);
    } else if (mFieldId == Enums.FIELD_ORBIT_RIGHT) {
      return $.themeColor(Enums.COLOR_SECONDARY_2);
    }
    return Graphics.COLOR_WHITE;
  }
}
(:apiBelow420)
class OrbitDataField extends AbastractOrbitDataField {
  function initialize(params) {
    AbastractOrbitDataField.initialize(params);
  }
}

(:api420AndAbove)
class OrbitDataField extends AbastractOrbitDataField {
  function initialize(params) {
    AbastractOrbitDataField.initialize(params);
    mHitbox = getHitbox();
  }

  (:debug)
  function draw(dc) {
    AbastractOrbitDataField.draw(dc);
    DataFieldDrawable.drawHitbox(dc, Graphics.COLOR_BLUE);
  }

  private function getHitbox() {
    var width = Settings.iconSize * 4;
    var height = Settings.iconSize * 3;

    if (mFieldId == Enums.FIELD_ORBIT_LEFT) {
      return {
        :width => width,
        :height => height,
        :x => mArcStartX + Settings.iconSize - width,
        :y => mArcStartY - Settings.iconSize,
      };
    } else if (mFieldId == Enums.FIELD_ORBIT_RIGHT) {
      return {
        :width => width,
        :height => height,
        :x => mArcStartX - Settings.iconSize,
        :y => mArcStartY - Settings.iconSize,
      };
    } else if (mFieldId == Enums.FIELD_ORBIT_OUTER) {
      return {
        :width => width,
        :height => height,
        :x => mArcStartX - width / 2,
        :y => mArcStartY - Settings.iconSize / 2,
      };
    }
    return null;
  }
}
