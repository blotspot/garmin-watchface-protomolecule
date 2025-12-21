import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

class DateAndTime extends WatchUi.Drawable {
  private var _burnInProtectionMode as Boolean;
  private var _burnInProtectionModeEnteredAt as Number?;

  private var _dateX as Number;
  private var _dateY as Number;
  private var _dateFont as WatchUi.Resource;

  private var _timeY as Number;
  private var _hoursX as Number;
  private var _is12Hour as Boolean;
  private var _minutesX as Number;

  private var _secondsX as Number;
  private var _secondsY as Number;
  private var _secondsHeight as Number?;

  private var _showMeridiem as Boolean;

  private var DayOfWeek as Array<ResourceId>;
  private var Months as Array<ResourceId>;

  (:onPressComplication)
  protected var _dateHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;
  (:onPressComplication)
  protected var _timeHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;
  (:onPressComplication)
  protected var _leftHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;
  (:onPressComplication)
  protected var _rightHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;

  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Number,
        :locY as Number,
        :width as Number,
        :height as Number,
        :visible as Boolean,
        :drawHeight as Number,
        :drawWidth as Number,
      }
  ) {
    Drawable.initialize(params);

    _burnInProtectionMode = Settings.burnInProtectionMode && !Settings.HAS_DISPLAY_MODE;

    _dateX = ((Settings.useSleepTimeLayout() ? 0.832 : 0.5) * params[:drawWidth]).toNumber();
    _dateY = (0.31 * params[:drawHeight]).toNumber();

    _hoursX = (0.485 * params[:drawWidth]).toNumber();
    _minutesX = (0.515 * params[:drawWidth]).toNumber();
    _timeY = (0.48 * params[:drawHeight]).toNumber();

    _secondsX = (0.85 * params[:drawWidth]).toNumber();
    _secondsY = (0.49 * params[:drawHeight]).toNumber();

    _is12Hour = !System.getDeviceSettings().is24Hour;
    _dateFont = Properties.getValue("useSystemFontForDate") ? Graphics.FONT_TINY : Settings.resource(Rez.Fonts.DateFont);
    _showMeridiem = _is12Hour && (Properties.getValue("showMeridiemText") as Boolean);

    Months = [
      Rez.Strings.DateMonth1,
      Rez.Strings.DateMonth2,
      Rez.Strings.DateMonth3,
      Rez.Strings.DateMonth4,
      Rez.Strings.DateMonth5,
      Rez.Strings.DateMonth6,
      Rez.Strings.DateMonth7,
      Rez.Strings.DateMonth8,
      Rez.Strings.DateMonth9,
      Rez.Strings.DateMonth10,
      Rez.Strings.DateMonth11,
      Rez.Strings.DateMonth12,
    ];

    DayOfWeek = [Rez.Strings.DateWeek1, Rez.Strings.DateWeek2, Rez.Strings.DateWeek3, Rez.Strings.DateWeek4, Rez.Strings.DateWeek5, Rez.Strings.DateWeek6, Rez.Strings.DateWeek7];

    if (self has :setHitboxes && !Settings.useSleepTimeLayout() && !Settings.lowPowerMode) {
      setHitboxes(params);
    }
  }

  function draw(dc) {
    var showSeconds = !Settings.lowPowerMode && (Properties.getValue("showSeconds") as Boolean);
    var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    if (_burnInProtectionMode && _burnInProtectionModeEnteredAt == null) {
      _burnInProtectionModeEnteredAt = now.min;
    }

    var hours = getHours(now);
    var minutes = now.min.format(Format.INT_ZERO);

    var offsetY = 0;
    if (_burnInProtectionMode) {
      offsetY = calculateLegacyBIPModeOffset(dc, now.min);
    }
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    // Date
    var date = getDateLine(now);
    dc.drawText(_dateX, _dateY + offsetY, _dateFont, date, (Settings.useSleepTimeLayout() ? 0 : 1) | Graphics.TEXT_JUSTIFY_VCENTER);
    // Hours
    dc.drawText(_hoursX, _timeY + offsetY, Settings.resource(Rez.Fonts.HoursFont), hours, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    // Minutes
    dc.drawText(_minutesX, _timeY + offsetY, Settings.resource(Rez.Fonts.MinutesFont), minutes, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    // Meridiem / Seconds
    if (_showMeridiem || showSeconds) {
      if (_secondsHeight == null) {
        _secondsHeight = dc.getFontHeight(Settings.resource(Rez.Fonts.MeridiemFont));
      }
      if (_showMeridiem) {
        dc.drawText(
          _secondsX,
          _secondsY - (!showSeconds ? 0 : _secondsHeight / 2) + offsetY,
          Settings.resource(Rez.Fonts.MeridiemFont),
          now.hour < 12 ? "am" : "pm",
          Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
      }
      if (showSeconds) {
        dc.drawText(
          _secondsX,
          _secondsY + (!_showMeridiem ? 0 : _secondsHeight / 2),
          Settings.resource(Rez.Fonts.MeridiemFont),
          now.sec.format(Format.INT),
          Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
      }
    }
    if (self has :drawHitbox) {
      drawHitbox(dc);
    }
  }

  private function getDateLine(now as Gregorian.Info) as String {
    return format("$1$ $2$ $3$", [Settings.resource(DayOfWeek[(now.day_of_week as Number) - 1]), now.day.format(Format.INT_ZERO), Settings.resource(Months[(now.month as Number) - 1])]);
  }

  private function getHours(now as Gregorian.Info) as String {
    var hours = now.hour;
    if (_is12Hour) {
      if (hours == 0) {
        hours = 12;
      }
      if (hours > 12) {
        hours -= 12;
      }
    }
    return hours.format(Format.INT_ZERO);
  }

  private function calculateLegacyBIPModeOffset(dc, min as Number) as Numeric {
    var timeMod = 2;
    if (min < _burnInProtectionModeEnteredAt) {
      timeMod = 62;
    }
    var pos = ((min - _burnInProtectionModeEnteredAt + timeMod) % 5) - 2; // -2, -1, 0, 1, 2, will always start at 0
    var window = dc.getHeight() / 8;
    var offset = window * pos;

    return offset;
  }

  (:debug,:onPressComplication)
  protected function drawHitbox(dc) {
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(1);
    if (_dateHitbox != null) {
      dc.drawRoundedRectangle(_dateHitbox[:x], _dateHitbox[:y], _dateHitbox[:width], _dateHitbox[:height], Settings.ICON_SIZE * 0.5);
    }
    if (_timeHitbox != null) {
      dc.drawRoundedRectangle(_timeHitbox[:x], _timeHitbox[:y], _timeHitbox[:width], _timeHitbox[:height], Settings.ICON_SIZE * 0.5);
    }
    if (_leftHitbox != null) {
      dc.drawRoundedRectangle(_leftHitbox[:x], _leftHitbox[:y], _leftHitbox[:width], _leftHitbox[:height], Settings.ICON_SIZE * 0.5);
    }
    if (_rightHitbox != null) {
      dc.drawRoundedRectangle(_rightHitbox[:x], _rightHitbox[:y], _rightHitbox[:width], _rightHitbox[:height], Settings.ICON_SIZE * 0.5);
    }
  }

  (:onPressComplication)
  protected function setHitboxes(params as { :drawWidth as Number, :drawHeight as Number }) {
    _dateHitbox = getDateHitbox(params);
    _timeHitbox = getTimeHitbox(params);
    _leftHitbox = getLeftHitbox();
    _rightHitbox = getRightHitbox();
  }

  (:onPressComplication)
  private function getDateHitbox(params as { :drawWidth as Number, :drawHeight as Number }) {
    var width = params[:drawWidth] * 0.4;
    var height = params[:drawHeight] * 0.12;
    return {
      :x => _dateX - width / 2,
      :y => _dateY - height / 2 + Settings.PEN_WIDTH,
      :width => width,
      :height => height,
    };
  }

  (:onPressComplication)
  private function getTimeHitbox(params as { :drawWidth as Number, :drawHeight as Number }) {
    var width = params[:drawWidth] * 0.6;
    var height = params[:drawHeight] * 0.24;
    return {
      :x => _hoursX + (_minutesX - _hoursX) / 2 - width / 2,
      :y => (params[:drawHeight] - height) / 2,
      :width => width,
      :height => height,
    };
  }

  (:onPressComplication)
  private function getLeftHitbox() {
    var width = Settings.ICON_SIZE * 2.5;
    var height = Settings.ICON_SIZE * 2.7;
    return {
      :x => 0,
      :y => System.getDeviceSettings().screenHeight / 2 - height / 2,
      :width => width,
      :height => height,
    };
  }

  (:onPressComplication)
  private function getRightHitbox() {
    var width = Settings.ICON_SIZE * 2.5;
    var height = Settings.ICON_SIZE * 2.7;
    return {
      :x => System.getDeviceSettings().screenWidth - width,
      :y => System.getDeviceSettings().screenHeight / 2 - height / 2,
      :width => width,
      :height => height,
    };
  }

  (:onPressComplication)
  private function isInHitbox(hitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?, x as Number, y as Number) as Boolean {
    return hitbox != null && y >= hitbox[:y] && y <= hitbox[:y] + hitbox[:height] && x >= hitbox[:x] && x <= hitbox[:x] + hitbox[:width];
  }

  (:onPressComplication)
  public function getComplicationForCoordinates(x as Number, y as Number) as Complications.Id? {
    if (isInHitbox(_leftHitbox, x, y)) {
      return Settings.getComplicationIdFromProperty("leftComplicationTrigger");
    }
    if (isInHitbox(_rightHitbox, x, y)) {
      return Settings.getComplicationIdFromProperty("rightComplicationTrigger");
    }
    if (isInHitbox(_dateHitbox, x, y)) {
      return Settings.getComplicationIdFromProperty("dateComplicationTrigger");
    }
    if (isInHitbox(_timeHitbox, x, y)) {
      return Settings.getComplicationIdFromProperty("timeComplicationTrigger");
    }
    return null;
  }
}
