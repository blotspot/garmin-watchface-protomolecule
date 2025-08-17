import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

class DateAndTime extends WatchUi.Drawable {
  hidden var mBurnInProtectionMode as Boolean;
  hidden var mBurnInProtectionModeEnteredAt as Number?;

  hidden var DayOfWeek as Array<ResourceId> = [];
  hidden var Months as Array<ResourceId> = [];

  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Number,
        :locY as Number,
        :width as Number,
        :height as Number,
        :visible as Boolean,
      }
  ) {
    Drawable.initialize(params);
    mBurnInProtectionMode = Settings.burnInProtectionMode && !Settings.hasDisplayMode;
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

  function draw(dc as Graphics.Dc) {
    var now = Time.Gregorian.info(Time.now(), Settings.get("useSystemFontForDate") ? Time.FORMAT_MEDIUM : Time.FORMAT_SHORT);
    if (mBurnInProtectionMode && mBurnInProtectionModeEnteredAt == null) {
      mBurnInProtectionModeEnteredAt = now.min;
    }
    var is12Hour = !System.getDeviceSettings().is24Hour;

    var hours = getHours(now, is12Hour);
    var minutes = now.min.format(Format.INT_ZERO);

    var hoursDim = dc.getTextDimensions(hours, Settings.resource(Rez.Fonts.HoursFont));
    var minutesDim = dc.getTextDimensions(minutes, Settings.resource(Rez.Fonts.MinutesFont));

    var offsetY = 0;
    if (mBurnInProtectionMode) {
      offsetY = calculateLegacyBIPModeOffset(dc, now.min, hoursDim[1]);
    }
    var hoursX = dc.getWidth() * 0.485;
    var hoursY = dc.getHeight() * 0.48 /* relative time pos */ - hoursDim[1] / 2.0 + offsetY;

    var minutesX = dc.getWidth() * 0.515;
    var minutesY = dc.getHeight() * 0.48 /* relative time pos */ - minutesDim[1] / 2.0 + offsetY;

    dc.setColor(mBurnInProtectionMode ? Graphics.COLOR_WHITE : themeColor(Color.FOREGROUND), Graphics.COLOR_TRANSPARENT);
    // Date
    drawDate(dc, now, minutesDim[0] + minutesX, offsetY);
    // Hours
    dc.drawText(hoursX, hoursY, Settings.resource(Rez.Fonts.HoursFont), hours, Graphics.TEXT_JUSTIFY_RIGHT);
    // Minutes
    dc.drawText(minutesX, minutesY, Settings.resource(Rez.Fonts.MinutesFont), minutes, Graphics.TEXT_JUSTIFY_LEFT);

    if (is12Hour && Settings.get("showMeridiemText")) {
      drawMeridiem(dc, now.hour, minutesDim[0] + minutesX, offsetY);
    }
    if (!Settings.lowPowerMode && Settings.get("showSeconds")) {
      drawSeconds(dc, now.sec, minutesDim[0] + minutesX);
    }
  }

  hidden function drawDate(dc as Graphics.Dc, now as Time.Gregorian.Info, sleepLayoutX as Numeric, offsetY as Numeric) {
    var font = Settings.get("useSystemFontForDate") ? Graphics.FONT_TINY : Settings.resource(Rez.Fonts.DateFont);
    var date = getDateLine(now);
    var dateDim = dc.getTextDimensions(date, font);
    var dateX = dc.getWidth() * 0.5;
    var dateY = dc.getHeight() * 0.31 /* relative date pos */ - dateDim[1] / 2.0;
    var justify = Graphics.TEXT_JUSTIFY_CENTER;

    if (Settings.useSleepTimeLayout()) {
      dateX = sleepLayoutX;
      justify = Graphics.TEXT_JUSTIFY_RIGHT;
    }

    dc.drawText(dateX, dateY, font, date, justify);
  }

  hidden function drawMeridiem(dc as Graphics.Dc, hour as Number, posX as Numeric, offsetY as Numeric) {
    var meridiem = hour < 12 ? "am" : "pm";
    var meridiemDim = dc.getTextDimensions(meridiem, Settings.resource(Rez.Fonts.MeridiemFont));
    var y = dc.getHeight() * 0.47 - meridiemDim[1] * (Settings.burnInProtectionMode || !Settings.get("showSeconds") ? 0 : 0.5) + offsetY;
    dc.drawText(posX, y, Settings.resource(Rez.Fonts.MeridiemFont), meridiem, Graphics.TEXT_JUSTIFY_LEFT);
  }

  hidden function drawSeconds(dc as Graphics.Dc, seconds as Number, secX as Numeric) {
    var dim = dc.getTextDimensions("99", Settings.resource(Rez.Fonts.MeridiemFont)) as Array<Number>;
    var y = dc.getHeight() * 0.47 + dim[1] * (System.getDeviceSettings().is24Hour || !Settings.get("showMeridiemText") ? 0 : 0.5);

    dc.setColor(themeColor(Color.FOREGROUND), Graphics.COLOR_TRANSPARENT);
    dc.drawText(secX + dim[0], y, Settings.resource(Rez.Fonts.MeridiemFont), seconds.format(Format.INT), Graphics.TEXT_JUSTIFY_RIGHT);
  }

  hidden function getDateLine(now as Gregorian.Info) as String {
    if (Settings.get("useSystemFontForDate")) {
      return format("$1$ $2$ $3$", [now.day_of_week, now.day.format(Format.INT_ZERO), now.month]);
    } else {
      return format("$1$ $2$ $3$", [Settings.resource(DayOfWeek[(now.day_of_week as Number) - 1]), now.day.format(Format.INT_ZERO), Settings.resource(Months[(now.month as Number) - 1])]);
    }
  }

  hidden function getHours(now as Gregorian.Info, is12Hour as Boolean) as String {
    var hours = now.hour;
    if (is12Hour) {
      if (hours == 0) {
        hours = 12;
      }
      if (hours > 12) {
        hours -= 12;
      }
    }
    return hours.format(Format.INT_ZERO);
  }

  hidden function calculateLegacyBIPModeOffset(dc as Graphics.Dc, min as Number, clockHeight as Numeric) as Numeric {
    var timeMod = 2;
    if (min < mBurnInProtectionModeEnteredAt) {
      timeMod = 62;
    }
    var pos = ((min - mBurnInProtectionModeEnteredAt + timeMod) % 5) - 2; // -2, -1, 0, 1, 2, will always start at 0
    var maxY = dc.getHeight() - clockHeight / 2;
    var minY = clockHeight / 2;
    var window = (maxY - minY) / 4.5;
    var offset = window * pos;

    return offset;
  }
}
