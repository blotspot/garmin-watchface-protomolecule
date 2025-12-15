import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

class AbstractDateAndTime extends WatchUi.Drawable {
  private var mBurnInProtectionMode as Boolean;
  private var mBurnInProtectionModeEnteredAt as Number?;

  hidden var mDateX as Numeric;
  hidden var mDateY as Numeric;
  hidden var mJustifyDate as Number;
  hidden var mDateFont as WatchUi.Resource;

  hidden var mTimeY as Numeric;
  hidden var mHoursX as Numeric;
  hidden var mIs12Hour as Boolean;
  hidden var mMinutesX as Numeric;

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
        :dateY as Numeric,
      }
  ) {
    Drawable.initialize(params);

    mBurnInProtectionMode = Settings.burnInProtectionMode && !Settings.hasDisplayMode;

    mJustifyDate = params[:justifyDate];
    mDateFont = Properties.getValue("useSystemFontForDate") ? Graphics.FONT_TINY : Settings.resource(Rez.Fonts.DateFont);
    mDateX = (mJustifyDate == 0 ? 0.832 : 0.5) * System.getDeviceSettings().screenWidth;
    mDateY = 0.31 * System.getDeviceSettings().screenHeight;

    mIs12Hour = !System.getDeviceSettings().is24Hour;
    mHoursX = 0.485 * System.getDeviceSettings().screenWidth;
    mMinutesX = 0.515 * System.getDeviceSettings().screenWidth;
    mTimeY = 0.48 * System.getDeviceSettings().screenHeight;

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
    var dim = dc.getTextDimensions(date, mDateFont);
    var y = mDateY - dim[1] / 2.0 + offsetY;
    dc.drawText(mDateX, y, mDateFont, date, mJustifyDate);

    // Hours
    dim = dc.getTextDimensions(minutes, Settings.resource(Rez.Fonts.MinutesFont));
    y = mTimeY - dim[1] / 2.0 + offsetY;
    dc.drawText(mHoursX, y, Settings.resource(Rez.Fonts.HoursFont), hours, 0);
    // Minutes
    dc.drawText(mMinutesX, y, Settings.resource(Rez.Fonts.MinutesFont), minutes, 2);

    // Meridiem / Seconds
    if ((mIs12Hour && mShowMeridiem) || (!Settings.lowPowerMode && mShowSeconds)) {
      y += dim[1] / 2 - Settings.strokeWidth;
      var x = mMinutesX + dim[0];
      var addendumHeight = dc.getTextDimensions("00", Settings.resource(Rez.Fonts.MeridiemFont))[1];
      if (mIs12Hour && mShowMeridiem) {
        var meridiem = now.hour < 12 ? "am" : "pm";
        y -= (Settings.strokeWidth / 2 + addendumHeight) * (Settings.burnInProtectionMode || !mShowSeconds ? 0 : 0.5);
        dc.drawText(x, y, Settings.resource(Rez.Fonts.MeridiemFont), meridiem, 2);
      }
      if (!Settings.lowPowerMode && mShowSeconds) {
        y += System.getDeviceSettings().is24Hour || !mShowMeridiem ? 0 : addendumHeight + Settings.strokeWidth;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, Settings.resource(Rez.Fonts.MeridiemFont), now.sec.format(Format.INT), 2);
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

  function initialize(params) {
    AbstractDateAndTime.initialize(params);

    mDateHitbox = getDateHitbox();
    mTimeHitbox = getTimeHitbox();
  }

  function draw(dc) {
    AbstractDateAndTime.draw(dc);
    if (Log.isDebugEnabled) {
      drawHitbox(dc);
    }
  }

  (:debug)
  hidden function drawHitbox(dc) {
    dc.setPenWidth(1);
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawRectangle(mDateHitbox[:x], mDateHitbox[:y], mDateHitbox[:width], mDateHitbox[:height]);
    dc.drawRectangle(mTimeHitbox[:x], mTimeHitbox[:y], mTimeHitbox[:width], mTimeHitbox[:height]);
  }

  private function getDateHitbox() {
    var height = Settings.iconSize * 1.5;
    var width = System.getDeviceSettings().screenWidth * 0.45;
    return {
      :height => height,
      :width => width,
      :x => mDateX - (mJustifyDate == 0 ? width : width / 2),
      :y => mDateY - height / 2,
    };
  }

  private function getTimeHitbox() {
    var height = System.getDeviceSettings().screenHeight * 0.25;
    var width = System.getDeviceSettings().screenWidth * 0.7;
    return {
      :height => height,
      :width => width,
      :y => System.getDeviceSettings().screenHeight / 2 - height / 2,
      :x => System.getDeviceSettings().screenWidth / 2 - width / 2,
    };
  }

  private function isInDateHitbox(x as Number, y as Number) as Boolean {
    if (mDateHitbox != null) {
      return y >= mDateHitbox[:y] && y <= mDateHitbox[:y] + mDateHitbox[:height] && x >= mDateHitbox[:x] && x <= mDateHitbox[:x] + mDateHitbox[:width];
    }
    return false;
  }

  private function isInTimeHitbox(x as Number, y as Number) as Boolean {
    if (mTimeHitbox != null) {
      return y >= mTimeHitbox[:y] && y <= mTimeHitbox[:y] + mTimeHitbox[:height] && x >= mTimeHitbox[:x] && x <= mTimeHitbox[:x] + mTimeHitbox[:width];
    }
    return false;
  }

  public function getComplicationForCoordinates(x as Number, y as Number) {
    if (isInDateHitbox(x, y)) {
      // Calender events for date
      Log.debug("Hit Date");
      return new Complications.Id(Complications.COMPLICATION_TYPE_CALENDAR_EVENTS);
    }
    if (isInTimeHitbox(x, y)) {
      // sunset / sunrise for time
      Log.debug("Hit Time");
      return new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET);
    }
    return null;
  }
}
