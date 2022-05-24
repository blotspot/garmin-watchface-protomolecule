using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DateAndTime extends Ui.Drawable {

  var mLowPowerMode;

  var mMinFont;
  var mDateFont;
  var mHoursFont;
  var mMeridiemFont;

  var DayOfWeek = [];
  var Months = [];

  function initialize(params) {
    Drawable.initialize(params);

    mLowPowerMode = params[:lowPowerMode] && System.getDeviceSettings().requiresBurnInProtection;

    mMinFont = Ui.loadResource(Rez.Fonts.MinutesFont);
    mDateFont = Ui.loadResource(Rez.Fonts.DateFont);
    mHoursFont = Ui.loadResource(Rez.Fonts.HoursFont);
    mMeridiemFont = Ui.loadResource(Rez.Fonts.MeridiemFont);

    Months = [
      Ui.loadResource(Rez.Strings.DateMonth1),
      Ui.loadResource(Rez.Strings.DateMonth2),
      Ui.loadResource(Rez.Strings.DateMonth3),
      Ui.loadResource(Rez.Strings.DateMonth4),
      Ui.loadResource(Rez.Strings.DateMonth5),
      Ui.loadResource(Rez.Strings.DateMonth6),
      Ui.loadResource(Rez.Strings.DateMonth7),
      Ui.loadResource(Rez.Strings.DateMonth8),
      Ui.loadResource(Rez.Strings.DateMonth9),
      Ui.loadResource(Rez.Strings.DateMonth10),
      Ui.loadResource(Rez.Strings.DateMonth11),
      Ui.loadResource(Rez.Strings.DateMonth12)
    ];

    DayOfWeek = [
      Ui.loadResource(Rez.Strings.DateWeek1),
      Ui.loadResource(Rez.Strings.DateWeek2),
      Ui.loadResource(Rez.Strings.DateWeek3),
      Ui.loadResource(Rez.Strings.DateWeek4),
      Ui.loadResource(Rez.Strings.DateWeek5),
      Ui.loadResource(Rez.Strings.DateWeek6),
      Ui.loadResource(Rez.Strings.DateWeek7)
    ];
  }

  function draw(dc) {
    var is12Hour = !System.getDeviceSettings().is24Hour;
    var now = Gregorian.info(Time.now(), Settings.get("useSystemFontForDate") ? Time.FORMAT_MEDIUM : Time.FORMAT_SHORT);
    var date = getDateLine(now);
    var hours = getHours(now, is12Hour);
    var minutes = now.min.format("%02d");

    var dateDim = dc.getTextDimensions(date, mDateFont);
    var dateX = dc.getWidth() * 0.5;
    var dateY = dc.getHeight() * 0.31 - dateDim[1] / 2.0;

    var hoursDim = dc.getTextDimensions(hours, mHoursFont);
    var hoursX = dc.getWidth() * 0.485;
    var hoursY = dc.getHeight() * 0.48 - hoursDim[1] / 2.0;

    var minutesDim = dc.getTextDimensions(minutes, mMinFont);
    var minutesX = dc.getWidth() * 0.515;
    var minutesY = dc.getHeight() * 0.48 - minutesDim[1] / 2.0;

    if (mLowPowerMode) {
      var offset = calculateOffset(dc, now.min % 5, dateY, hoursY + hoursDim[1]);
      dateY += offset;
      hoursY += offset;
      minutesY += offset;
    }

    dc.setColor((mLowPowerMode ? Graphics.COLOR_WHITE : themeColor(Color.FOREGROUND)), Graphics.COLOR_TRANSPARENT);
    
    // Date
    dc.drawText(dateX, dateY, Settings.get("useSystemFontForDate") ? Graphics.FONT_TINY : mDateFont, date, Graphics.TEXT_JUSTIFY_CENTER);
    // Hours
    dc.drawText(hoursX, hoursY, mHoursFont, hours, Graphics.TEXT_JUSTIFY_RIGHT);
    // Minutes
    dc.drawText(minutesX, minutesY, mMinFont, minutes, Graphics.TEXT_JUSTIFY_LEFT);

    if (is12Hour && Settings.get("showMeridiemText")) {
      dc.setColor(themeColor(Color.TEXT_ACTIVE), Graphics.COLOR_TRANSPARENT);
      var meridiem = (now.hour < 12) ? "am" : "pm";
      var meridiemDim = dc.getTextDimensions(meridiem, mMeridiemFont);
      var x = minutesDim[0] + minutesX;
      var y = dc.getHeight() * 0.48 - meridiemDim[1] / 2.0;
      dc.drawText(x, y, mMeridiemFont, meridiem, Graphics.TEXT_JUSTIFY_LEFT);
    }
  }

  hidden function getDateLine(now) {
    if (Settings.get("useSystemFontForDate")) {
      return Lang.format("$1$ $2$ $3$", [now.day_of_week, now.day.format("%02d"), now.month]);
    } else {
      return Lang.format("$1$ $2$ $3$", [DayOfWeek[now.day_of_week - 1], now.day.format("%02d"), Months[now.month - 1]]);
    }
  }

  hidden function getHours(now, is12Hour) {
    var hours = now.hour;
    if (is12Hour) {
      if (hours == 0) {
        hours = 12;
      }
      if (hours > 12) {
        hours -= 12;
      }
    }
    return hours.format("%02d");
  }

  hidden function calculateOffset(dc, multiplicator, startY, endY) {
    var maxY = dc.getHeight() - endY;
    var minY = startY * -1;
    var window = maxY - minY;
    var offset = (window * 0.2) * multiplicator + window * 0.1;

    return startY * -1 + offset;
  }

}