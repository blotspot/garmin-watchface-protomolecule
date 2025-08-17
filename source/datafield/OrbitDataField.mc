import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.Lang;

class OrbitDataField extends DataFieldDrawable {
  hidden var mStartDegree as Numeric;
  hidden var mTotalDegree as Numeric;
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

  function draw(dc as Graphics.Dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      update(dc);
    }
  }

  function update(dc as Graphics.Dc) {
    setClippingRegion(dc);
    saveSetAntiAlias(dc, true);
    dc.setPenWidth(Settings.get("strokeWidth"));
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }
    // draw remaining arc first so it wont overdraw our endpoint
    drawRemainingArc(dc, mLastInfo.progress, mLastInfo.reverse);
    drawProgressArc(dc, mLastInfo.progress, mLastInfo.reverse);
    drawIcon(dc);

    saveSetAntiAlias(dc, false);
  }

  function partialUpdate(dc as Graphics.Dc) {
    DataFieldDrawable.drawPartialUpdate(dc, method(:update));
  }

  hidden function drawProgressArc(dc as Graphics.Dc, fillLevel as Numeric, reverse as Boolean) {
    dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    if (fillLevel > 0.0) {
      var startDegree = reverse ? mStartDegree - mTotalDegree + getFillDegree(fillLevel) : mStartDegree;
      var endDegree = reverse ? mStartDegree - mTotalDegree : mStartDegree - getFillDegree(fillLevel);

      dc.drawArc(locX, locY, mRadius, Graphics.ARC_CLOCKWISE, startDegree, endDegree);
      if (fillLevel < 1.0) {
        drawEndpoint(dc, reverse ? startDegree : endDegree);
      }
    }
  }

  hidden function drawRemainingArc(dc as Graphics.Dc, fillLevel as Numeric, reverse as Boolean) {
    if (fillLevel < 1.0) {
      dc.setColor(themeColor(Color.INACTIVE), Graphics.COLOR_TRANSPARENT);
      var startDegree = reverse ? mStartDegree : mStartDegree - getFillDegree(fillLevel);
      var endDegree = mStartDegree - mTotalDegree;
      if (reverse) {
        endDegree += getFillDegree(fillLevel);
      }

      dc.drawArc(locX, locY, mRadius, Graphics.ARC_CLOCKWISE, startDegree, endDegree);
    }
  }

  hidden function drawEndpoint(dc as Graphics.Dc, degree as Numeric) {
    var x = getX(dc, degree);
    var y = getY(dc, degree);
    // draw outer colored circle
    dc.fillCircle(x, y, Settings.get("strokeWidth") + Settings.get("strokeWidth") * 0.75);
    // draw inner white circle
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(x, y, Settings.get("strokeWidth") + Settings.get("strokeWidth") * 0.25);
  }

  hidden function drawIcon(dc as Graphics.Dc) {
    if (mLastInfo.progress == 0) {
      dc.setColor(themeColor(Color.TEXT_INACTIVE), Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    }
    var x = locX;
    var y = locY;

    if (mFieldId == FieldId.ORBIT_LEFT) {
      x = getX(dc, mStartDegree - mTotalDegree) - Settings.get("iconSize") / 2;
      y = getY(dc, mStartDegree - mTotalDegree) + Settings.get("iconSize");
    } else if (mFieldId == FieldId.ORBIT_RIGHT) {
      x = getX(dc, mStartDegree) + Settings.get("iconSize") / 2;
      y = getY(dc, mStartDegree) + Settings.get("iconSize");
    } else if (mFieldId == FieldId.ORBIT_OUTER) {
      y = locY + mRadius - Settings.get("iconSize") * (Settings.get("showOrbitIndicatorText") ? 2 : 1);
    }
    mLastInfo.icon.drawAt(dc, x, y);
    drawText(dc, x, y);
  }

  hidden function drawText(dc as Graphics.Dc, x as Numeric, y as Numeric) {
    if (Settings.get("showOrbitIndicatorText") && mLastInfo.text != null) {
      y += Settings.get("iconSize");
      dc.drawText(x, y - 1, Settings.resource(Rez.Fonts.SecondaryIndicatorFont), mLastInfo.text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
  }

  hidden function getX(dc as Graphics.Dc, degree as Numeric) as Numeric {
    degree = Math.toRadians(degree);
    return locX + mRadius * Math.cos(degree);
  }

  hidden function getY(dc as Graphics.Dc, degree as Numeric) as Numeric {
    degree = Math.toRadians(degree);
    return dc.getHeight() - (locY + mRadius * Math.sin(degree));
  }

  hidden function getFillDegree(fillLevel as Numeric) as Numeric {
    return mTotalDegree * fillLevel;
  }

  hidden function setClippingRegion(dc as Graphics.Dc) {
    saveClearClip(dc);
  }

  hidden function getForeground() as ColorType {
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
