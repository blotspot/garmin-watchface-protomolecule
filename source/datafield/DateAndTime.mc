import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

class DateAndTime extends WatchUi.Drawable {
  private var mBurnInProtectionMode as Boolean;
  private var mBurnInProtectionModeEnteredAt as Number?;

  protected var mDateX as Number;
  protected var mDateY as Number;
  protected var mDateFont as WatchUi.Resource;

  protected var mTimeY as Number;
  protected var mHoursX as Number;
  protected var mIs12Hour as Boolean;
  protected var mMinutesX as Number;

  protected var mSecondsX as Number;
  protected var mSecondsY as Number;
  protected var mSecondsHeight as Number?;

  private var mShowSeconds as Boolean;
  private var mShowMeridiem as Boolean;

  private var DayOfWeek as Array<ResourceId>;
  private var Months as Array<ResourceId>;

  (:onPressComplication)
  protected var mDateHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;
  (:onPressComplication)
  protected var mTimeHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;
  (:onPressComplication)
  protected var mLeftHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;
  (:onPressComplication)
  protected var mRightHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;

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

    mBurnInProtectionMode = Settings.burnInProtectionMode && !Settings.HAS_DISPLAY_MODE;

    mDateX = ((Settings.useSleepTimeLayout() ? 0.832 : 0.5) * System.getDeviceSettings().screenWidth).toNumber();
    mDateY = (0.31 * System.getDeviceSettings().screenHeight).toNumber();

    mHoursX = (0.485 * System.getDeviceSettings().screenWidth).toNumber();
    mMinutesX = (0.515 * System.getDeviceSettings().screenWidth).toNumber();
    mTimeY = (0.48 * System.getDeviceSettings().screenHeight).toNumber();

    mSecondsX = (0.85 * System.getDeviceSettings().screenWidth).toNumber();
    mSecondsY = (0.49 * System.getDeviceSettings().screenHeight).toNumber();

    mIs12Hour = !System.getDeviceSettings().is24Hour;
    mDateFont = Properties.getValue("useSystemFontForDate") ? Graphics.FONT_TINY : Settings.resource(Rez.Fonts.DateFont);
    mShowSeconds = !Settings.lowPowerMode && (Properties.getValue("showSeconds") as Boolean);
    mShowMeridiem = mIs12Hour && (Properties.getValue("showMeridiemText") as Boolean);

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
      setHitboxes();
    }
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
    dc.drawText(mDateX, y, mDateFont, date, (Settings.useSleepTimeLayout() ? 0 : 1) | Graphics.TEXT_JUSTIFY_VCENTER);

    // Hours
    y = mTimeY + offsetY;
    dc.drawText(mHoursX, y, Settings.resource(Rez.Fonts.HoursFont), hours, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    // Minutes
    dc.drawText(mMinutesX, y, Settings.resource(Rez.Fonts.MinutesFont), minutes, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // Meridiem / Seconds
    if (mShowMeridiem || mShowSeconds) {
      if (mSecondsHeight == null) {
        mSecondsHeight = dc.getFontHeight(Settings.resource(Rez.Fonts.MeridiemFont));
      }
      if (mShowMeridiem) {
        y = mSecondsY - (!mShowSeconds ? 0 : mSecondsHeight / 2) + offsetY;
        dc.drawText(mSecondsX, y, Settings.resource(Rez.Fonts.MeridiemFont), now.hour < 12 ? "am" : "pm", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
      }
      if (mShowSeconds) {
        y = mSecondsY + (!mShowMeridiem ? 0 : mSecondsHeight / 2);
        dc.drawText(mSecondsX, y, Settings.resource(Rez.Fonts.MeridiemFont), now.sec.format(Format.INT), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
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

  (:debug,:onPressComplication)
  protected function drawHitbox(dc) {
    dc.setPenWidth(1);
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    if (mDateHitbox != null) {
      dc.drawRoundedRectangle(mDateHitbox[:x], mDateHitbox[:y], mDateHitbox[:width], mDateHitbox[:height], Settings.ICON_SIZE * 0.5);
    }
    if (mTimeHitbox != null) {
      dc.drawRoundedRectangle(mTimeHitbox[:x], mTimeHitbox[:y], mTimeHitbox[:width], mTimeHitbox[:height], Settings.ICON_SIZE * 0.5);
    }
    if (mLeftHitbox != null) {
      dc.drawRoundedRectangle(mLeftHitbox[:x], mLeftHitbox[:y], mLeftHitbox[:width], mLeftHitbox[:height], Settings.ICON_SIZE * 0.5);
    }
    if (mRightHitbox != null) {
      dc.drawRoundedRectangle(mRightHitbox[:x], mRightHitbox[:y], mRightHitbox[:width], mRightHitbox[:height], Settings.ICON_SIZE * 0.5);
    }
  }

  (:onPressComplication)
  protected function setHitboxes() {
    mDateHitbox = getDateHitbox();
    mTimeHitbox = getTimeHitbox();
    mLeftHitbox = getLeftHitbox();
    mRightHitbox = getRightHitbox();
  }

  (:onPressComplication)
  private function getDateHitbox() {
    var width = System.getDeviceSettings().screenWidth * 0.45;
    var height = Settings.ICON_SIZE * 1.5;
    return {
      :x => mDateX - width / 2,
      :y => mDateY - height / 2,
      :width => width,
      :height => height,
    };
  }

  (:onPressComplication)
  private function getTimeHitbox() {
    var width = System.getDeviceSettings().screenWidth * 0.6;
    var height = Settings.ICON_SIZE * 2.7;
    return {
      :x => System.getDeviceSettings().screenWidth / 2 - width / 2,
      :y => System.getDeviceSettings().screenHeight / 2 - height / 2,
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
    if (isInHitbox(mLeftHitbox, x, y)) {
      return Settings.getComplicationIdFromFroperty("leftComplicationTrigger");
    }
    if (isInHitbox(mRightHitbox, x, y)) {
      return Settings.getComplicationIdFromFroperty("rightComplicationTrigger");
    }
    if (isInHitbox(mDateHitbox, x, y)) {
      return Settings.getComplicationIdFromFroperty("dateComplicationTrigger");
    }
    if (isInHitbox(mTimeHitbox, x, y)) {
      return Settings.getComplicationIdFromFroperty("timeComplicationTrigger");
    }
    return null;
  }
}
