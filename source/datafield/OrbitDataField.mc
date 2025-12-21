import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.Lang;
import Config;

class OrbitDataField extends DataFieldDrawable {
  private var _startDegree as Numeric;
  private var _totalDegree as Numeric;
  private var _radius as Numeric;

  private var _arcStartX as Numeric;
  private var _arcStartY as Numeric;

  private var _showText as Boolean;

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
        :drawHeight as Number,
        :drawWidth as Number,
      }
  ) {
    //! redefine locX / locY.
    //! Doing it the stupid way because the layout isn't allowing a `dc` call in their definition.
    params[:locX] = params[:x] * params[:drawWidth];
    params[:locY] = params[:y] * params[:drawHeight];
    DataFieldDrawable.initialize(params);

    _startDegree = params[:startDegree];
    _totalDegree = params[:totalDegree];
    _radius = params[:radius] * params[:drawWidth];
    _showText = Properties.getValue("showOrbitIndicatorText") as Boolean;

    _arcStartX = locX;
    _arcStartY = locY;

    if (mFieldId == Config.FIELD_ORBIT_LEFT) {
      _arcStartX = getX(_startDegree - _totalDegree) - Settings.ICON_SIZE / 2;
      _arcStartY = getY(params[:drawHeight], _startDegree - _totalDegree) + Settings.ICON_SIZE;
    } else if (mFieldId == Config.FIELD_ORBIT_RIGHT) {
      _arcStartX = getX(_startDegree) + Settings.ICON_SIZE / 2;
      _arcStartY = getY(params[:drawHeight], _startDegree) + Settings.ICON_SIZE;
    } else if (mFieldId == Config.FIELD_ORBIT_OUTER) {
      _arcStartY = locY + _radius - Settings.ICON_SIZE * (_showText ? 2 : 1);
    }

    if (self has :setHitbox && !Settings.useSleepTimeLayout() && !Settings.lowPowerMode) {
      setHitbox();
    }
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      DataFieldDrawable.drawDataField(dc, false);
    }
  }

  protected function drawDataField(dc, partial as Boolean) {
    setClippingRegion(dc);
    dc.setPenWidth(Settings.PEN_WIDTH);
    if (mLastInfo.progress > 1.0) {
      mLastInfo.progress = 1.0;
    }
    // draw remaining arc first so it wont overdraw our endpoint
    drawRemainingArc(dc, mLastInfo.progress, mLastInfo.reverse);
    drawProgressArc(dc, mLastInfo.progress, mLastInfo.reverse);
    drawIcon(dc);
  }

  private function drawProgressArc(dc, fillLevel as Numeric, reverse as Boolean) {
    dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    if (fillLevel > 0.0) {
      var startDegree = reverse ? _startDegree - _totalDegree + getFillDegree(fillLevel) : _startDegree;
      var endDegree = reverse ? _startDegree - _totalDegree : _startDegree - getFillDegree(fillLevel);

      dc.drawArc(locX, locY, _radius, Graphics.ARC_CLOCKWISE, startDegree, endDegree);
      if (fillLevel < 1.0) {
        drawEndpoint(dc, reverse ? startDegree : endDegree);
      }
    }
  }

  private function drawRemainingArc(dc, fillLevel as Numeric, reverse as Boolean) {
    if (fillLevel < 1.0) {
      dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
      var startDegree = reverse ? _startDegree : _startDegree - getFillDegree(fillLevel);
      var endDegree = _startDegree - _totalDegree;
      if (reverse) {
        endDegree += getFillDegree(fillLevel);
      }

      dc.drawArc(locX, locY, _radius, Graphics.ARC_CLOCKWISE, startDegree, endDegree);
    }
  }

  private function drawEndpoint(dc, degree as Numeric) {
    var x = getX(degree);
    var y = getY(dc.getHeight(), degree);
    // draw outer colored circle
    dc.fillCircle(x, y, Settings.PEN_WIDTH * 1.75);
    // draw inner white circle
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(x, y, Settings.PEN_WIDTH * 1.25);
  }

  private function drawIcon(dc) {
    if (mLastInfo.progress == 0) {
      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(getForeground(), Graphics.COLOR_TRANSPARENT);
    }
    var x = _arcStartX;
    var y = _arcStartY;

    mLastInfo.icon.drawAt(dc, x, y);

    if (_showText && mLastInfo.text != null) {
      y += Settings.ICON_SIZE;
      dc.drawText(x, y - 1, Settings.resource(Rez.Fonts.SecondaryIndicatorFont), mLastInfo.text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
  }

  private function getX(degree as Numeric) as Numeric {
    degree = Math.toRadians(degree);
    return locX + _radius * Math.cos(degree);
  }

  private function getY(height as Number, degree as Numeric) as Numeric {
    degree = Math.toRadians(degree);
    return height - (locY + _radius * Math.sin(degree));
  }

  private function getFillDegree(fillLevel as Numeric) as Numeric {
    return _totalDegree * fillLevel;
  }

  private function setClippingRegion(dc) {
    switch (mFieldId) {
      case Config.FIELD_ORBIT_LEFT:
        dc.setClip(0, 0, dc.getWidth(), dc.getHeight());
      case Config.FIELD_ORBIT_RIGHT:
        dc.setClip(locX, 0, dc.getWidth(), dc.getHeight());
      default:
        $.saveClearClip(dc);
    }
  }

  private function getForeground() as ColorType {
    if (mFieldId == Config.FIELD_ORBIT_OUTER) {
      return $.themeColor(Config.COLOR_PRIMARY);
    } else if (mFieldId == Config.FIELD_ORBIT_LEFT) {
      return $.themeColor(Config.COLOR_SECONDARY_1);
    } else if (mFieldId == Config.FIELD_ORBIT_RIGHT) {
      return $.themeColor(Config.COLOR_SECONDARY_2);
    }
    return Graphics.COLOR_WHITE;
  }

  (:onPressComplication)
  protected function setHitbox() {
    var width = Settings.ICON_SIZE * 3.2;
    var height = Settings.ICON_SIZE * 2;
    switch (mFieldId) {
      case Config.FIELD_ORBIT_LEFT:
        mHitbox = {
          :width => width,
          :height => height,
          :x => _arcStartX + Settings.ICON_SIZE - width,
          :y => _arcStartY - Settings.ICON_SIZE / 2,
        };
        break;
      case Config.FIELD_ORBIT_RIGHT:
        mHitbox = {
          :width => width,
          :height => height,
          :x => _arcStartX - Settings.ICON_SIZE,
          :y => _arcStartY - Settings.ICON_SIZE / 2,
        };
        break;
      case Config.FIELD_ORBIT_OUTER:
        mHitbox = {
          :width => width,
          :height => height,
          :x => _arcStartX - width / 2,
          :y => _arcStartY - Settings.ICON_SIZE / 2,
        };
        break;
      default:
        break;
    }
  }
}
