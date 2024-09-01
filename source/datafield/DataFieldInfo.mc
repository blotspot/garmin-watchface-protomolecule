import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.Math;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;

module Format {
  const INT_ZERO = "%02d";
  const INT = "%i";
  const FLOAT = "%2.0d";
}

module LayoutId {
  const ORBIT = 0;
  const CIRCLES = 1;
}

module FieldId {
  const NO_PROGRESS_1 = 0;
  const NO_PROGRESS_2 = 1;
  const NO_PROGRESS_3 = 2;
  const ORBIT_OUTER = 3;
  const ORBIT_LEFT = 4;
  const ORBIT_RIGHT = 5;
  const OUTER = 6;
  const UPPER_1 = 7;
  const UPPER_2 = 8;
  const LOWER_1 = 9;
  const LOWER_2 = 10;
  const SLEEP_BATTERY = 11;
  const SLEEP_HR = 12;
  const SLEEP_ALARMS = 13;
  const SLEEP_NOTIFY = 14;
  const DATE_AND_TIME = 15;
}

module FieldType {
  const NOTHING = 0;
  const STEPS = 1;
  const BATTERY = 2;
  const CALORIES = 3;
  const ACTIVE_MINUTES = 4;
  const HEART_RATE = 5;
  const NOTIFICATION = 6;
  const FLOORS_UP = 7;
  const FLOORS_DOWN = 8;
  const BLUETOOTH = 9;
  const ALARMS = 10;
  const BODY_BATTERY = 11;
  const SECONDS = 12;
  const STRESS_LEVEL = 13;
  const ACTIVE_CALORIES = 14;
}

module DataFieldInfo {
  class DataFieldProperties {
    var fieldType;
    var icon;
    var text;
    var progress;
    var reverse;

    function initialize(_fieldType, _icon, _text, _progress, _reverse) {
      fieldType = _fieldType;
      icon = _icon;
      text = _text;
      progress = _progress;
      reverse = _reverse;
    }

    function equals(other) {
      if (other != null && other instanceof DataFieldProperties) {
        return other.fieldType == fieldType && other.text.equals(text) && other.progress == progress;
      }
      return false;
    }
  }

  function getInfoForField(fieldId) as DataFieldProperties? {
    if (fieldId == FieldId.NO_PROGRESS_1) {
      return getInfoForType(Settings.get("middle1"));
    } else if (fieldId == FieldId.NO_PROGRESS_2) {
      return getInfoForType(Settings.get("middle2"));
    } else if (fieldId == FieldId.NO_PROGRESS_3) {
      return getInfoForType(Settings.get("middle3"));
    } else if (fieldId == FieldId.OUTER || fieldId == FieldId.ORBIT_OUTER) {
      return getInfoForType(Settings.get("outer"));
    } else if (fieldId == FieldId.UPPER_1 || fieldId == FieldId.ORBIT_LEFT) {
      return getInfoForType(Settings.get("upper1"));
    } else if (fieldId == FieldId.UPPER_2 || fieldId == FieldId.ORBIT_RIGHT) {
      return getInfoForType(Settings.get("upper2"));
    } else if (fieldId == FieldId.LOWER_1) {
      return getInfoForType(Settings.get("lower1"));
    } else if (fieldId == FieldId.LOWER_2) {
      return getInfoForType(Settings.get("lower2"));
    } else if (fieldId == FieldId.SLEEP_HR) {
      return getHeartRateInfo();
    } else if (fieldId == FieldId.SLEEP_NOTIFY) {
      return getNotificationInfo();
    } else if (fieldId == FieldId.SLEEP_ALARMS) {
      return getAlarmsInfo();
    } else if (fieldId == FieldId.SLEEP_BATTERY) {
      return getBatteryInfo();
    } else if (fieldId == FieldId.DATE_AND_TIME) {
      return getSecondsInfo();
    } else {
      return null;
    }
  }

  function getInfoForType(fieldType) as DataFieldProperties? {
    if (fieldType == FieldType.HEART_RATE) {
      return getHeartRateInfo();
    } else if (fieldType == FieldType.CALORIES) {
      return getCalorieInfo();
    } else if (fieldType == FieldType.ACTIVE_CALORIES) {
      return getActiveCalorieInfo();
    } else if (fieldType == FieldType.NOTIFICATION) {
      return getNotificationInfo();
    } else if (fieldType == FieldType.STEPS) {
      return getStepInfo();
    } else if (fieldType == FieldType.FLOORS_UP) {
      return getFloorsClimbedInfo();
    } else if (fieldType == FieldType.FLOORS_DOWN) {
      return getFloorsDescentInfo();
    } else if (fieldType == FieldType.ACTIVE_MINUTES) {
      return getActiveMinuteInfo();
    } else if (fieldType == FieldType.BATTERY) {
      return getBatteryInfo();
    } else if (fieldType == FieldType.BLUETOOTH) {
      return getBluetoothInfo();
    } else if (fieldType == FieldType.ALARMS) {
      return getAlarmsInfo();
    } else if (fieldType == FieldType.BODY_BATTERY) {
      return getBodyBatteryInfo();
    } else if (fieldType == FieldType.STRESS_LEVEL) {
      return getStressLevel();
    } else {
      return null;
    }
  }

  function getHeartRateInfo() as DataFieldProperties {
    var heartRate = Activity.getActivityInfo().currentHeartRate;
    var icon = new Lang.Method(DataFieldIcons, :drawHeartRate);
    if (heartRate == null && ActivityMonitor has :getHeartRateHistory) {
      var hrHistory = ActivityMonitor.getHeartRateHistory(new Time.Duration(60), true).next(); // Try to get latest entry from the last minute
      if (hrHistory != null) {
        heartRate = hrHistory.heartRate;
      }
    }
    if (heartRate == null || heartRate == ActivityMonitor.INVALID_HR_SAMPLE) {
      heartRate = 0;
      icon = new Lang.Method(DataFieldIcons, :drawNoHeartRate);
    }

    return new DataFieldProperties(FieldType.HEART_RATE, icon, heartRate.format(Format.INT), 0, false);
  }

  function getCalorieInfo() {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.calories.toDouble();

    return new DataFieldProperties(FieldType.CALORIES, new Lang.Method(DataFieldIcons, :drawCalories), current.format(Format.INT), current / Settings.get("caloriesGoal"), false);
  }

  function getActiveCalorieInfo() {
    var profile = UserProfile.getProfile();
    var activityInfo = ActivityMonitor.getInfo();
    var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    var ageFactor = 6.116 * (today.year - profile.birthYear);
    var heightFactor = 7.628 * profile.height;
    var weightFactor = 12.2 * (profile.weight / 1000.0);
    var genderFactor = -197.6;

    if (profile.gender == UserProfile.GENDER_MALE) {
      genderFactor = 5.2;
    }
    var resting = genderFactor - ageFactor + heightFactor + weightFactor;
    var relResting = Math.round(((today.hour * 60 + today.min) * resting) / 1440).toNumber();
    var active = activityInfo.calories.toDouble() - relResting;

    return new DataFieldProperties(FieldType.ACTIVE_CALORIES, new Lang.Method(DataFieldIcons, :drawCalories), active.format(Format.INT), active / Settings.get("caloriesGoal"), false);
  }

  function getNotificationInfo() as DataFieldProperties {
    var notifications = System.getDeviceSettings().notificationCount;

    var iconFunc = new Lang.Method(DataFieldIcons, :drawNotificationActive);
    if (notifications == 0) {
      iconFunc = new Lang.Method(DataFieldIcons, :drawNotificationInactive);
    }

    return new DataFieldProperties(FieldType.NOTIFICATION, iconFunc, notifications.format(Format.INT), 0, false);
  }

  function getBatteryInfo() as DataFieldProperties {
    var stats = System.getSystemStats();
    var current = stats.battery;
    var iconFunc = new Lang.Method(DataFieldIcons, :drawBattery);
    if (current >= 90) {
      iconFunc = new Lang.Method(DataFieldIcons, :drawBatteryFull);
    }
    if (current < Settings.get("batteryThreshold")) {
      iconFunc = new Lang.Method(DataFieldIcons, :drawBatteryLow);
    }
    if (stats.charging) {
      iconFunc = new Lang.Method(DataFieldIcons, :drawBatteryLoading);
    }

    return new DataFieldProperties(FieldType.BATTERY, iconFunc, current.format(Format.FLOAT), current / 100, true);
  }

  function getStepInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.steps.toDouble();

    return new DataFieldProperties(FieldType.STEPS, new Lang.Method(DataFieldIcons, :drawSteps), current.format(Format.INT), current / activityInfo.stepGoal, false);
  }

  function getFloorsClimbedInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.floorsClimbed.toDouble();

    return new DataFieldProperties(FieldType.FLOORS_UP, new Lang.Method(DataFieldIcons, :drawFloorsUp), current.format(Format.INT), current / activityInfo.floorsClimbedGoal, false);
  }

  function getFloorsDescentInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.floorsDescended.toDouble();

    return new DataFieldProperties(FieldType.FLOORS_DOWN, new Lang.Method(DataFieldIcons, :drawFloorsDown), current.format(Format.INT), current / activityInfo.floorsClimbedGoal, false);
  }

  function getActiveMinuteInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.activeMinutesWeek.total.toDouble();

    return new DataFieldProperties(FieldType.ACTIVE_MINUTES, new Lang.Method(DataFieldIcons, :drawActiveMinutes), current.format(Format.INT), current / activityInfo.activeMinutesWeekGoal, false);
  }

  function getBluetoothInfo() as DataFieldProperties {
    var iconFunc;
    if (System.getDeviceSettings().phoneConnected) {
      iconFunc = new Lang.Method(DataFieldIcons, :drawBluetoothConnection);
    } else {
      iconFunc = new Lang.Method(DataFieldIcons, :drawNoBluetoothConnection);
    }

    return new DataFieldProperties(FieldType.BLUETOOTH, iconFunc, " ", 0, false);
  }

  function getAlarmsInfo() as DataFieldProperties {
    var alarmCount = System.getDeviceSettings().alarmCount;
    var iconFunc = new Lang.Method(DataFieldIcons, :drawAlarms);
    if (alarmCount == 0) {
      iconFunc = new Lang.Method(DataFieldIcons, :drawNoAlarms);
    }

    return new DataFieldProperties(FieldType.ALARMS, iconFunc, alarmCount.format(Format.INT), 0, false);
  }

  function getSecondsInfo() as DataFieldProperties {
    if (!Settings.lowPowerMode) {
      var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
      var seconds = now.sec;
      return new DataFieldProperties(FieldType.SECONDS, null, seconds.format(Format.INT), seconds / 60.0, false);
    } else {
      return new DataFieldProperties(FieldType.SECONDS, null, "", 0, false);
    }
  }

  function getBodyBatteryInfo() as DataFieldProperties {
    var bodyBattery = null;

    if (Toybox has :SensorHistory && Toybox.SensorHistory has :getBodyBatteryHistory) {
      var iter = SensorHistory.getBodyBatteryHistory({ :period => 1 });
      bodyBattery = iter.next();
    }
    if (bodyBattery == null) {
      bodyBattery = 0;
    } else {
      bodyBattery = bodyBattery.data;
    }
    var fId = FieldType.BODY_BATTERY;
    var iconCallback = new Lang.Method(DataFieldIcons, :drawBodyBattery);
    var bbFmt = bodyBattery.format(Format.INT);
    var progress = bodyBattery / 100.0;

    return new DataFieldProperties(fId, iconCallback, bbFmt, progress, true);
  }

  function getStressLevel() as DataFieldProperties {
    var stressLevel = null;
    if (ActivityMonitor.Info has :stressScore) {
      Log.debug("Using stress score");
      var activityInfo = ActivityMonitor.getInfo();
      if (activityInfo.stressScore != null) {
        stressLevel = activityInfo.stressScore.toDouble();
      }
    }
    if (stressLevel == null) {
      Log.debug("Using stress level info");
      stressLevel = getLatestStressLevelFromSensorHistory();
    }

    var fId = FieldType.STRESS_LEVEL;
    var iconCallback = new Lang.Method(DataFieldIcons, :drawStressLevel);
    var slFmt = stressLevel.format(Format.INT);
    var progress = stressLevel / 100.0;

    return new DataFieldProperties(fId, iconCallback, slFmt, progress, true);
  }

  function getLatestStressLevelFromSensorHistory() as Number {
    var stressLevel = null;

    if (Toybox has :SensorHistory && Toybox.SensorHistory has :getStressHistory) {
      var iter = SensorHistory.getStressHistory({ :period => 1 });
      stressLevel = iter.next();
    }
    if (stressLevel == null) {
      stressLevel = 0;
    } else {
      stressLevel = stressLevel.data;
    }
    return stressLevel;
  }
}
