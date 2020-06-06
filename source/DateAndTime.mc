using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DateAndTime extends Ui.Drawable {

  var mBurnInProtection;

  var mWidth;
  var mHeight;

  var mDateFont;
  var mHoursFont;
  var mMinFont;

  function initialize(params) {
    Drawable.initialize(params);
    var device = System.getDeviceSettings();

    mBurnInProtection = params[:burnInProtection] && device.requiresBurnInProtection;

    mWidth = device.screenWidth;
    mHeight = device.screenHeight;

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
    var dateX = mWidth * 0.5;
    var dateY = mHeight * 0.31 - dateDim[1] / 2.0;

    var hoursDim = dc.getTextDimensions(hours, mHoursFont);
    var hoursX = mWidth * 0.485;
    var hoursY = mWidth * 0.48 - hoursDim[1] / 2.0;

    var minutesDim = dc.getTextDimensions(minutes, mMinFont);
    var minutesX = mWidth * 0.515;
    var minutesY = mWidth * 0.48 - hoursDim[1] / 2.0;

    var offset = 0;
    if (mBurnInProtection) {
      offset = calculateOffset(now.min % 5, dateY, hoursY + hoursDim[1]);
    }

    dc.setColor(Graphics.COLOR_WHITE, Color.BACKGROUND);
    // Date
    dc.drawText(dateX, dateY + offset, mDateFont, date, Graphics.TEXT_JUSTIFY_CENTER);

    // Hours
    dc.drawText(hoursX, hoursY + offset, mHoursFont, hours, Graphics.TEXT_JUSTIFY_RIGHT);

    // Minutes
    dc.drawText(minutesX, minutesY + offset, mMinFont, minutes, Graphics.TEXT_JUSTIFY_LEFT);
  }

  function calculateOffset(multiplicator, startY, endY) {
    var maxY = mHeight - endY;
    var minY = startY * -1;
    var window = maxY - minY;
    var offset = (window * 0.2) * multiplicator + window * 0.1;

    return startY * -1 + offset;
  }

}