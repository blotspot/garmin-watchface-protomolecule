using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DateAndTime extends Ui.Drawable {

  var mLowPowerMode;

  var mDateFont;
  var mHoursFont;
  var mMinFont;

  function initialize(params) {
    Drawable.initialize(params);
    var device = System.getDeviceSettings();

    mLowPowerMode = params[:lowPowerMode] && device.requiresBurnInProtection;

    mDateFont = Ui.loadResource(Rez.Fonts.DateFont);
    mHoursFont = Ui.loadResource(Rez.Fonts.HoursFont);
    mMinFont = Ui.loadResource(Rez.Fonts.MinutesFont);
  }

  function draw(dc) {
    var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    var date = Lang.format("$1$ $2$ $3$", [now.day_of_week, now.day.format("%02d"), now.month]);
    var hours = now.hour.format("%02d");
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

    var offset = 0;
    if (mLowPowerMode) {
      offset = calculateOffset(now.min % 5, dateY, hoursY + hoursDim[1]);
    }

    dc.setColor((mLowPowerMode ? Graphics.COLOR_WHITE : themeColor(Color.FOREGROUND)), Graphics.COLOR_TRANSPARENT);
    
    // Date
    dc.drawText(dateX, dateY + offset, mDateFont, date, Graphics.TEXT_JUSTIFY_CENTER);
    // Hours
    dc.drawText(hoursX, hoursY + offset, mHoursFont, hours, Graphics.TEXT_JUSTIFY_RIGHT);
    // Minutes
    dc.drawText(minutesX, minutesY + offset, mMinFont, minutes, Graphics.TEXT_JUSTIFY_LEFT);
  }

  hidden function calculateOffset(multiplicator, startY, endY) {
    var maxY = dc.getHeight() - endY;
    var minY = startY * -1;
    var window = maxY - minY;
    var offset = (window * 0.2) * multiplicator + window * 0.1;

    return startY * -1 + offset;
  }

}