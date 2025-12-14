import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.Lang;
import Enums;

class OrbitDataField extends DataFieldDrawable {
  private var mStartDegree as Numeric;
  private var mTotalDegree as Numeric;
  private var mRadius as Numeric;

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
    dc.setPenWidth(Settings.strokeWidth);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }
    // draw remaining arc first so it wont overdraw our endpoint
    drawRemainingArc(dc, mLastInfo.progress, mLastInfo.reverse);
    drawProgressArc(dc, mLastInfo.progress, mLastInfo.reverse);
    drawIcon(dc);

    $.saveSetAntiAlias(dc, false);
  }

  function partialUpdate(dc) {
    DataFieldDrawable.drawPartialUpdate(dc, method(:update));
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
    var x = getX(dc, degree);
    var y = getY(dc, degree);
    // draw outer colored circle
    dc.fillCircle(x, y, Settings.strokeWidth + Settings.strokeWidth * 0.75);
    // draw inner white circle
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(x, y, Settings.strokeWidth + Settings.strokeWidth * 0.25);
  }

  private function drawIcon(dc) {
    if (mLastInfo.progress == 0) {
      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    }
    var x = locX;
    var y = locY;
    var showT = Properties.getValue("showOrbitIndicatorText");
    if (mFieldId == Enums.FIELD_ORBIT_LEFT) {
      x = getX(dc, mStartDegree - mTotalDegree) - Settings.iconSize / 2;
      y = getY(dc, mStartDegree - mTotalDegree) + Settings.iconSize;
    } else if (mFieldId == Enums.FIELD_ORBIT_RIGHT) {
      x = getX(dc, mStartDegree) + Settings.iconSize / 2;
      y = getY(dc, mStartDegree) + Settings.iconSize;
    } else if (mFieldId == Enums.FIELD_ORBIT_OUTER) {
      y = locY + mRadius - Settings.iconSize * (showT ? 2 : 1);
    }
    mLastInfo.icon.drawAt(dc, x, y);

    mClipX = x - Settings.iconSize / 2;
    mClipY = y - Settings.iconSize / 2;
    mClipWidth = Settings.iconSize;
    mClipHeight = Settings.iconSize;

    if (showT && mLastInfo.text != null) {
      var textDim = dc.getTextDimensions(mLastInfo.text, Settings.resource(Rez.Fonts.SecondaryIndicatorFont)) as Array<Number>;
      if (Settings.iconSize < textDim[0]) {
        mClipWidth = textDim[0];
        mClipX = x - Settings.iconSize / 2;
      }
      mClipHeight = Settings.iconSize + textDim[1];
      y += Settings.iconSize;
      dc.drawText(x, y - 1, Settings.resource(Rez.Fonts.SecondaryIndicatorFont), mLastInfo.text, 1 | 4);
    }
  }

  private function getX(dc, degree as Numeric) as Numeric {
    degree = Math.toRadians(degree);
    return locX + mRadius * Math.cos(degree);
  }

  private function getY(dc, degree as Numeric) as Numeric {
    degree = Math.toRadians(degree);
    return dc.getHeight() - (locY + mRadius * Math.sin(degree));
  }

  private function getFillDegree(fillLevel as Numeric) as Numeric {
    return mTotalDegree * fillLevel;
  }

  private function setClippingRegion(dc) {
    $.saveClearClip(dc);
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
