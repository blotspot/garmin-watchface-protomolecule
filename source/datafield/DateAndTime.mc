import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

class DateAndTime extends WatchUi.Drawable {
  hidden var mBurnInProtectionMode as Boolean;
  hidden var mBurnInProtectionModeEnteredAt as Number?;

  hidden var justifyDate as Number;

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
        :justifyDate as Numeric,
      }
  ) {
    mBurnInProtectionMode = Settings.burnInProtectionMode && !Settings.hasDisplayMode;
    justifyDate = params[:justifyDate];

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
    Drawable.initialize(params);
  }

  function draw(dc) {
    var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    if (mBurnInProtectionMode && mBurnInProtectionModeEnteredAt == null) {
      mBurnInProtectionModeEnteredAt = now.min;
    }
    var is12Hour = !System.getDeviceSettings().is24Hour;

    var hours = getHours(now, is12Hour);
    var minutes = now.min.format(Format.INT_ZERO);

    var offsetY = 0;
    if (mBurnInProtectionMode) {
      offsetY = calculateLegacyBIPModeOffset(dc, now.min);
    }

    var timeY = 0.48 * dc.getHeight();

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    // Date
    var font = Properties.getValue("useSystemFontForDate") ? 1 /* Graphics.FONT_TINY */ : Settings.resource(Rez.Fonts.DateFont);
    var date = getDateLine(now);
    var dim = dc.getTextDimensions(date, font);
    var x = (justifyDate == 0 ? 0.832 : 0.5) * dc.getWidth();
    var y = 0.31 * dc.getHeight() - dim[1] / 2.0 + offsetY;
    dc.drawText(x, y, font, date, justifyDate);
    // Hours
    dim = dc.getTextDimensions(hours, Settings.resource(Rez.Fonts.HoursFont));
    x = 0.485 * dc.getWidth();
    y = timeY - dim[1] / 2.0 + offsetY;
    dc.drawText(x, y, Settings.resource(Rez.Fonts.HoursFont), hours, 0);
    // Minutes
    dim = dc.getTextDimensions(minutes, Settings.resource(Rez.Fonts.MinutesFont));
    x = 0.515 * dc.getWidth();
    y = timeY - dim[1] / 2.0 + offsetY;
    dc.drawText(x, y, Settings.resource(Rez.Fonts.MinutesFont), minutes, 2);
    // Meridiem / Seconds
    x += dim[0];
    y = y + dim[1] / 2 - Settings.strokeWidth;
    var showSec = Properties.getValue("showSeconds") as Boolean;
    var showMeridiem = Properties.getValue("showMeridiemText") as Boolean;
    if (is12Hour && showMeridiem) {
      var meridiem = now.hour < 12 ? "am" : "pm";
      dim = dc.getTextDimensions(meridiem, Settings.resource(Rez.Fonts.MeridiemFont));
      y = y - (Settings.strokeWidth / 2 + dim[1]) * (Settings.burnInProtectionMode || !showSec ? 0 : 0.5);
      dc.drawText(x, y, Settings.resource(Rez.Fonts.MeridiemFont), meridiem, 2);
    }
    if (!Settings.lowPowerMode && showSec) {
      dim = dc.getTextDimensions("99", Settings.resource(Rez.Fonts.MeridiemFont)) as Array<Number>;
      y += System.getDeviceSettings().is24Hour || !showMeridiem ? 0 : dim[1] + Settings.strokeWidth;

      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x, y, Settings.resource(Rez.Fonts.MeridiemFont), now.sec.format(Format.INT), 2);
    }
  }

  hidden function getDateLine(now as Gregorian.Info) as String {
    return format("$1$ $2$ $3$", [Settings.resource(DayOfWeek[(now.day_of_week as Number) - 1]), now.day.format(Format.INT_ZERO), Settings.resource(Months[(now.month as Number) - 1])]);
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

  hidden function calculateLegacyBIPModeOffset(dc, min as Number) as Numeric {
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
