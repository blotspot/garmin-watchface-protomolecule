import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

class AbstractDateAndTime extends WatchUi.Drawable {
  private var mBurnInProtectionMode as Boolean;
  private var mBurnInProtectionModeEnteredAt as Number?;

  protected var mDateX as Number;
  protected var mDateY as Number;
  protected var mJustifyDate as Number;
  protected var mDateFont as WatchUi.Resource;

  protected var mTimeY as Number;
  protected var mHoursX as Number;
  protected var mIs12Hour as Boolean;
  protected var mMinutesX as Number;

  protected var mSecondsX as Number;
  protected var mSecondsY as Number;
  protected var mSecondsDim as [Number, Number]?;

  private var mShowSeconds as Boolean;
  private var mShowMeridiem as Boolean;

  private var DayOfWeek as Array<ResourceId>;
  private var Months as Array<ResourceId>;

  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Number,
        :locY as Number,
        :width as Number,
        :height as Number,
        :visible as Boolean,
        :justifyDate as Number,
      }
  ) {
    Drawable.initialize(params);

    mBurnInProtectionMode = Settings.burnInProtectionMode && !Settings.hasDisplayMode;

    mJustifyDate = params[:justifyDate];
    mDateX = ((mJustifyDate == 0 ? 0.832 : 0.5) * System.getDeviceSettings().screenWidth).toNumber();
    mDateY = (0.31 * System.getDeviceSettings().screenHeight).toNumber();

    mHoursX = (0.485 * System.getDeviceSettings().screenWidth).toNumber();
    mMinutesX = (0.515 * System.getDeviceSettings().screenWidth).toNumber();
    mTimeY = (0.48 * System.getDeviceSettings().screenHeight).toNumber();

    mSecondsX = (0.85 * System.getDeviceSettings().screenWidth).toNumber();
    mSecondsY = (0.49 * System.getDeviceSettings().screenHeight).toNumber();

    mIs12Hour = !System.getDeviceSettings().is24Hour;
    mDateFont = Properties.getValue("useSystemFontForDate") ? Graphics.FONT_TINY : Settings.resource(Rez.Fonts.DateFont);
    mShowSeconds = Properties.getValue("showSeconds") as Boolean;
    mShowMeridiem = Properties.getValue("showMeridiemText") as Boolean;

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
  }

  function draw(dc) {
    var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    if (mBurnInProtectionMode && mBurnInProtectionModeEnteredAt == null) {
      mBurnInProtectionModeEnteredAt = now.min;
    }

    var hours = getHours(now);
    var minutes = now.min.format(Format.INT_ZERO);

    var offsetY = 0;
    if (mBurnInProtectionMode) {
      offsetY = calculateLegacyBIPModeOffset(dc, now.min);
    }
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    // Date
    var date = getDateLine(now);
    var y = mDateY + offsetY;
    dc.drawText(mDateX, y, mDateFont, date, mJustifyDate | Graphics.TEXT_JUSTIFY_VCENTER);

    // Hours
    y = mTimeY + offsetY;
    dc.drawText(mHoursX, y, Settings.resource(Rez.Fonts.HoursFont), hours, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    // Minutes
    dc.drawText(mMinutesX, y, Settings.resource(Rez.Fonts.MinutesFont), minutes, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // Meridiem / Seconds
    if ((mIs12Hour && mShowMeridiem) || (!Settings.lowPowerMode && mShowSeconds)) {
      if (mSecondsDim == null) {
        mSecondsDim = dc.getTextDimensions("00", Settings.resource(Rez.Fonts.MeridiemFont));
      }
      if (mIs12Hour && mShowMeridiem) {
        var meridiem = now.hour < 12 ? "am" : "pm";
        y = mSecondsY - (Settings.burnInProtectionMode || !mShowSeconds ? 0 : mSecondsDim[1] / 2);
        dc.drawText(mSecondsX, y, Settings.resource(Rez.Fonts.MeridiemFont), meridiem, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
      }
      if (!Settings.lowPowerMode && mShowSeconds) {
        y = mSecondsY + (!mIs12Hour || !mShowMeridiem ? 0 : mSecondsDim[1] / 2);
        dc.drawText(mSecondsX, y, Settings.resource(Rez.Fonts.MeridiemFont), now.sec.format(Format.INT), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
      }
    }
  }

  private function getDateLine(now as Gregorian.Info) as String {
    return format("$1$ $2$ $3$", [Settings.resource(DayOfWeek[(now.day_of_week as Number) - 1]), now.day.format(Format.INT_ZERO), Settings.resource(Months[(now.month as Number) - 1])]);
  }

  private function getHours(now as Gregorian.Info) as String {
    var hours = now.hour;
    if (mIs12Hour) {
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
    if (min < mBurnInProtectionModeEnteredAt) {
      timeMod = 62;
    }
    var pos = ((min - mBurnInProtectionModeEnteredAt + timeMod) % 5) - 2; // -2, -1, 0, 1, 2, will always start at 0
    var window = dc.getHeight() / 8;
    var offset = window * pos;

    return offset;
  }
}
(:apiBelow420)
class DateAndTime extends AbstractDateAndTime {
  function initialize(params) {
    AbstractDateAndTime.initialize(params);
  }
}

(:api420AndAbove)
class DateAndTime extends AbstractDateAndTime {
  private var mDateHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;
  private var mTimeHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;
  private var mLeftHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;
  private var mRightHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;

  function initialize(params) {
    AbstractDateAndTime.initialize(params);

    mDateHitbox = getDateHitbox();
    mTimeHitbox = getTimeHitbox();
    mLeftHitbox = getLeftHitbox();
    mRightHitbox = getRightHitbox();
  }

  (:debug)
  function draw(dc) {
    AbstractDateAndTime.draw(dc);
    drawHitbox(dc);
  }

  (:debug)
  protected function drawHitbox(dc) {
    dc.setPenWidth(1);
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawRoundedRectangle(mDateHitbox[:x], mDateHitbox[:y], mDateHitbox[:width], mDateHitbox[:height], Settings.iconSize * 0.5);
    dc.drawRoundedRectangle(mTimeHitbox[:x], mTimeHitbox[:y], mTimeHitbox[:width], mTimeHitbox[:height], Settings.iconSize * 0.5);
    dc.drawRoundedRectangle(mLeftHitbox[:x], mLeftHitbox[:y], mLeftHitbox[:width], mLeftHitbox[:height], Settings.iconSize * 0.5);
    dc.drawRoundedRectangle(mRightHitbox[:x], mRightHitbox[:y], mRightHitbox[:width], mRightHitbox[:height], Settings.iconSize * 0.5);
  }

  private function getDateHitbox() {
    var width = System.getDeviceSettings().screenWidth * 0.45;
    var height = Settings.iconSize * 1.5;
    return {
      :x => mDateX - (mJustifyDate == 0 ? width : width / 2),
      :y => mDateY - height / 2,
      :width => width,
      :height => height,
    };
  }

  private function getTimeHitbox() {
    var width = System.getDeviceSettings().screenWidth * 0.6;
    var height = Settings.iconSize * 2.7;
    return {
      :x => System.getDeviceSettings().screenWidth / 2 - width / 2,
      :y => System.getDeviceSettings().screenHeight / 2 - height / 2,
      :width => width,
      :height => height,
    };
  }

  private function getLeftHitbox() {
    var width = Settings.iconSize * 2.5;
    var height = Settings.iconSize * 2.7;
    return {
      :x => 0,
      :y => System.getDeviceSettings().screenHeight / 2 - height / 2,
      :width => width,
      :height => height,
    };
  }

  private function getRightHitbox() {
    var width = Settings.iconSize * 2.5;
    var height = Settings.iconSize * 2.7;
    return {
      :x => System.getDeviceSettings().screenWidth - width,
      :y => System.getDeviceSettings().screenHeight / 2 - height / 2,
      :width => width,
      :height => height,
    };
  }

  private function isInHitbox(hitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?, x as Number, y as Number) as Boolean {
    return hitbox != null && y >= hitbox[:y] && y <= hitbox[:y] + hitbox[:height] && x >= hitbox[:x] && x <= hitbox[:x] + hitbox[:width];
  }

  public function getComplicationForCoordinates(x as Number, y as Number) {
    if (isInHitbox(mLeftHitbox, x, y)) {
      // sunset / sunrise for time
      Log.debug("Hit Left");
      return new Complications.Id(Complications.COMPLICATION_TYPE_CURRENT_WEATHER);
    }
    if (isInHitbox(mRightHitbox, x, y)) {
      // sunset / sunrise for time
      Log.debug("Hit Right");
      return new Complications.Id(Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE);
    }
    if (isInHitbox(mDateHitbox, x, y)) {
      // Calender events for date
      Log.debug("Hit Date");
      return new Complications.Id(Complications.COMPLICATION_TYPE_CALENDAR_EVENTS);
    }
    if (isInHitbox(mTimeHitbox, x, y)) {
      // sunset / sunrise for time
      Log.debug("Hit Time");
      return new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET);
    }
    return null;
  }
}
