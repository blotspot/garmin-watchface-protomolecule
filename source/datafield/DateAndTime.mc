import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

class DateAndTime extends WatchUi.Drawable {
  var mBurnInProtectionMode as Boolean;
  var mBurnInProtectionModeEnteredAt as Number?;

  var DayOfWeek as Array<ResourceId> = [];
  var Months as Array<ResourceId> = [];

  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Number,
        :locY as Number,
        :width as Number,
        :height as Number,
        :visible as Boolean,
        :burnInProtectionMode as Boolean,
      }
  ) {
    Drawable.initialize(params);
    mBurnInProtectionMode = params[:burnInProtectionMode] && System.getDeviceSettings().requiresBurnInProtection;
    if (mBurnInProtectionMode) {
      mBurnInProtectionModeEnteredAt = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).min;
    }
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
    var is12Hour = !System.getDeviceSettings().is24Hour;
    var now = Time.Gregorian.info(Time.now(), Settings.get("useSystemFontForDate") ? Time.FORMAT_MEDIUM : Time.FORMAT_SHORT);
    var date = getDateLine(now);
    var hours = getHours(now, is12Hour);
    var minutes = now.min.format(Format.INT_ZERO);

    var dateDim = dc.getTextDimensions(date, Settings.resource(Rez.Fonts.DateFont));
    var dateX = dc.getWidth() * 0.5;
    var dateY = dc.getHeight() * 0.31 /* relative date pos */ - dateDim[1] / 2.0;

    var hoursDim = dc.getTextDimensions(hours, Settings.resource(Rez.Fonts.HoursFont));
    var hoursX = dc.getWidth() * 0.485;
    var hoursY = dc.getHeight() * 0.48 /* relative time pos */ - hoursDim[1] / 2.0;

    var minutesDim = dc.getTextDimensions(minutes, Settings.resource(Rez.Fonts.MinutesFont));
    var minutesX = dc.getWidth() * 0.515;
    var minutesY = dc.getHeight() * 0.48 /* relative time pos */ - minutesDim[1] / 2.0;

    var offset = 0;
    if (mBurnInProtectionMode) {
      var timeMod = 2;
      if (now.min < mBurnInProtectionModeEnteredAt) {
        timeMod = 62;
      }
      var pos = ((now.min - mBurnInProtectionModeEnteredAt + timeMod) % 5) - 2; // -2, -1, 0, 1, 2, will always start at 0
      offset = calculateOffset(dc, pos, hoursDim[1]);
      dateY += offset;
      hoursY += offset;
      minutesY += offset;
    }

    dc.setColor(mBurnInProtectionMode ? Graphics.COLOR_WHITE : themeColor(Color.FOREGROUND), Graphics.COLOR_TRANSPARENT);

    // Date
    dc.drawText(dateX, dateY, Settings.get("useSystemFontForDate") ? Graphics.FONT_TINY : Settings.resource(Rez.Fonts.DateFont), date, Graphics.TEXT_JUSTIFY_CENTER);
    // Hours
    dc.drawText(hoursX, hoursY, Settings.resource(Rez.Fonts.HoursFont), hours, Graphics.TEXT_JUSTIFY_RIGHT);
    // Minutes
    dc.drawText(minutesX, minutesY, Settings.resource(Rez.Fonts.MinutesFont), minutes, Graphics.TEXT_JUSTIFY_LEFT);

    if (is12Hour && Settings.get("showMeridiemText")) {
      var meridiem = now.hour < 12 ? "am" : "pm";
      var meridiemDim = dc.getTextDimensions(meridiem, Settings.resource(Rez.Fonts.MeridiemFont));
      var x = minutesDim[0] + minutesX;
      var y = dc.getHeight() * 0.47 - meridiemDim[1] * (mBurnInProtectionMode || !Settings.get("showSeconds") ? 0 : 0.5) + offset;
      dc.drawText(x, y, Settings.resource(Rez.Fonts.MeridiemFont), meridiem, Graphics.TEXT_JUSTIFY_LEFT);
    }
    if (!mBurnInProtectionMode && !Settings.lowPowerMode && Settings.get("showSeconds")) {
      updateSeconds(dc, now.sec, minutesDim[0] + minutesX);
    }
  }

  function updateSeconds(dc as Graphics.Dc, seconds as Number, secX as Numeric) {
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

  hidden function calculateOffset(dc as Graphics.Dc, pos as Numeric, clockHeight as Numeric) as Numeric {
    var maxY = dc.getHeight() - clockHeight / 2;
    var minY = clockHeight / 2;
    var window = (maxY - minY) / 4.5;
    var offset = window * pos;

    return offset;
  }
}
