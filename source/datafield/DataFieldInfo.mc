using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Application;
using Toybox.BluetoothLowEnergy;
using Toybox.Lang;
using Toybox.SensorHistory;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

module Format {
  const INT = "%i";
  const FLOAT = "%2.0d";
}

module LayoutId {
  enum {
    ORBIT,
    CIRCLES
  }
}

module FieldId {
  enum {
    NO_PROGRESS_1,
    NO_PROGRESS_2,
    NO_PROGRESS_3,
    ORBIT_OUTER,
    ORBIT_LEFT,
    ORBIT_RIGHT,
    OUTER,
    UPPER_1,
    UPPER_2,
    LOWER_1,
    LOWER_2,
    SLEEP_BATTERY,
    SLEEP_HR,
    SLEEP_ALARMS,
    SLEEP_NOTIFY,
    DATE_AND_TIME
  }
}

module FieldType {
  enum {
    NOTHING, STEPS, BATTERY, CALORIES, ACTIVE_MINUTES, HEART_RATE, NOTIFICATION, FLOORS_UP, FLOORS_DOWN, BLUETOOTH, ALARMS, BODY_BATTERY, SECONDS
  }
}

module DataFieldInfo {

  class DataFieldProperties {
    var fieldType;
    var icon;
    var text;
    var progress;

    function initialize(_fieldType, _icon, _text, _progress) {
      fieldType = _fieldType;
      icon = _icon;
      text = _text;
      progress = _progress;
    }

    function equals(other) {
      if (other != null && other instanceof DataFieldProperties) {
        return other.fieldType.equals(fieldType) && other.text.equals(text) && other.progress == progress;
      }
      return false;
    }

  }

  function getInfoForField(fieldId) as DataFieldProperties {
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
    }

    return null;
  }

  function getInfoForType(fieldType) as DataFieldProperties {
    if (fieldType == FieldType.HEART_RATE) {
      return getHeartRateInfo();
    } else if (fieldType == FieldType.CALORIES) {
      return getCalorieInfo();
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
    }
    return null;
  }

  function getHeartRateInfo() as DataFieldProperties {
    var heartRate = Activity.getActivityInfo().currentHeartRate;
    var icon = new Lang.Method(DataFieldIcons, :drawHeartRate);
    if (heartRate == null && ActivityMonitor has :getHeartRateInfoHistory) {
      var hrHistory = ActivityMonitor.getHeartRateInfoHistory(new Time.Duration(60), true).next(); // Try to get latest entry from the last minute
      if (hrHistory != null) {
        heartRate = hrHistory.heartRate;
      }
    }
    if (heartRate == null || heartRate == ActivityMonitor.INVALID_HR_SAMPLE) {
      heartRate = 0;
      icon = new Lang.Method(DataFieldIcons, :drawNoHeartRate);
    }

    return new DataFieldProperties(FieldType.HEART_RATE, icon, heartRate.format(Format.INT), 0);
  }

  function getCalorieInfo() {
    var current = ActivityMonitor.getInfo().calories.toDouble();

    return new DataFieldProperties(FieldType.CALORIES, new Lang.Method(DataFieldIcons, :drawCalories), current.format(Format.INT), current / Settings.get("caloriesGoal"));
  }

  function getNotificationInfo() as DataFieldProperties {
    var notifications = System.getDeviceSettings().notificationCount;

    var iconFunc = new Lang.Method(DataFieldIcons, :drawNotificationActive);
    if (notifications == 0) { iconFunc = new Lang.Method(DataFieldIcons, :drawNotificationInactive); }

    return new DataFieldProperties(FieldType.NOTIFICATION, iconFunc, notifications.format(Format.INT), 0);
  }

  function getBatteryInfo() as DataFieldProperties {
    var stats = System.getSystemStats();
    var current = stats.battery;
    var iconFunc = new Lang.Method(DataFieldIcons, :drawBattery);
    if (current >= 90) { iconFunc = new Lang.Method(DataFieldIcons, :drawBatteryFull); }
    if (current < Settings.get("batteryThreshold")) { iconFunc = new Lang.Method(DataFieldIcons, :drawBatteryLow); }
    if (stats.charging) { iconFunc = new Lang.Method(DataFieldIcons, :drawBatteryLoading); }


    return new DataFieldProperties(FieldType.BATTERY, iconFunc, current.format(Format.FLOAT), current / 100);
  }

  function getStepInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.steps.toDouble();

    return new DataFieldProperties(FieldType.STEPS, new Lang.Method(DataFieldIcons, :drawSteps), current.format(Format.INT), current / activityInfo.stepGoal);
  }

  function getFloorsClimbedInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.floorsClimbed.toDouble();

    return new DataFieldProperties(FieldType.FLOORS_UP, new Lang.Method(DataFieldIcons, :drawFloorsUp), current.format(Format.INT), current / activityInfo.floorsClimbedGoal);
  }

  function getFloorsDescentInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.floorsDescended.toDouble();

    return new DataFieldProperties(FieldType.FLOORS_DOWN, new Lang.Method(DataFieldIcons, :drawFloorsDown), current.format(Format.INT), current / activityInfo.floorsClimbedGoal);
  }

  function getActiveMinuteInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.activeMinutesWeek.total.toDouble();

    return new DataFieldProperties(FieldType.ACTIVE_MINUTES, new Lang.Method(DataFieldIcons, :drawActiveMinutes), current.format(Format.INT), current / activityInfo.activeMinutesWeekGoal);
  }

  function getBluetoothInfo() as DataFieldProperties {
    var iconFunc;
    if (System.getDeviceSettings().phoneConnected) {
      iconFunc = new Lang.Method(DataFieldIcons, :drawBluetoothConnection);
    } else {
      iconFunc = new Lang.Method(DataFieldIcons, :drawNoBluetoothConnection);
    }

    return new DataFieldProperties(FieldType.BLUETOOTH, iconFunc, " ", 0);
  }

  function getAlarmsInfo() as DataFieldProperties {
    var alarmCount = System.getDeviceSettings().alarmCount;
    var iconFunc = new Lang.Method(DataFieldIcons, :drawAlarms);
    if (alarmCount == 0) {
      iconFunc = new Lang.Method(DataFieldIcons, :drawNoAlarms);
    }

    return new DataFieldProperties(FieldType.ALARMS, iconFunc, alarmCount.format(Format.INT), 0);
  }

  function getSecondsInfo() as DataFieldProperties {
    if (!Settings.lowPowerMode) {
      var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
      var seconds = now.sec;
      return new DataFieldProperties(FieldType.SECONDS, null, seconds.format(Format.INT), seconds / 60.0);
    } else {
      return new DataFieldProperties(FieldType.SECONDS, null, "", 0);
    }
  }

  function getBodyBatteryInfo() as DataFieldProperties {
    var bodyBattery = null;
    
    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
      var iter = SensorHistory.getBodyBatteryHistory({:period => 1});
      if (iter != null) {
        bodyBattery = iter.next();
      }
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
    
    return new DataFieldProperties(fId, iconCallback, bbFmt, progress);
  }
}