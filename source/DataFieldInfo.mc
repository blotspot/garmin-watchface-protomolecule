using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Application;
using Toybox.BluetoothLowEnergy;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

module Format {
  const INT = "%i";
  const FLOAT = "%2.0d";
}

module FieldId {
  enum {
    NO_PROGRESS_1,
    NO_PROGRESS_2,
    NO_PROGRESS_3,
    OUTER,
    UPPER_1,
    UPPER_2,
    LOWER_1,
    LOWER_2,
    SLEEP_BATTERY,
    SLEEP_HR,
    SLEEP_ALARMS,
    SLEEP_NOTIFY
  }
}

module FieldType {
  enum {
    NOTHING, STEPS, BATTERY, CALORIES, ACTIVE_MINUTES, HEART_RATE, NOTIFICATION, FLOORS_UP, FLOORS_DOWN, BLUETOOTH, ALARMS, SECONDS
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

  function getInfoForField(fieldId) {
    if (fieldId == FieldId.NO_PROGRESS_1) {
      return getInfoForType(Application.getApp().gNoProgressDataField1);
    } else if (fieldId == FieldId.NO_PROGRESS_2) {
      return getInfoForType(Application.getApp().gNoProgressDataField2);
    } else if (fieldId == FieldId.NO_PROGRESS_3) {
      return getInfoForType(Application.getApp().gNoProgressDataField3);
    } else if (fieldId == FieldId.OUTER) {
      return getInfoForType(Application.getApp().gOuterDataField);
    } else if (fieldId == FieldId.UPPER_1) {
      return getInfoForType(Application.getApp().gUpperDataField1);
    } else if (fieldId == FieldId.UPPER_2) {
      return getInfoForType(Application.getApp().gUpperDataField2);
    } else if (fieldId == FieldId.LOWER_1) {
      return getInfoForType(Application.getApp().gLowerDataField1);
    } else if (fieldId == FieldId.LOWER_2) {
      return getInfoForType(Application.getApp().gLowerDataField2);
    } else if (fieldId == FieldId.SLEEP_HR) {
      return getHeartRateInfo();
    } else if (fieldId == FieldId.SLEEP_NOTIFY) {
      return getNotificationInfo();
    } else if (fieldId == FieldId.SLEEP_ALARMS) {
      return getAlarmsInfo();
    } else if (fieldId == FieldId.SLEEP_BATTERY) {
      return getBatteryInfo();
    }

    return null;
  }

  function getInfoForType(fieldType) {
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
    } else if (fieldType == FieldType.SECONDS) {
      return getSecondsInfo();
    }
    return null;
  }

  function getHeartRateInfo() {
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

    return new DataFieldProperties(FieldType.CALORIES, new Lang.Method(DataFieldIcons, :drawCalories), current.format(Format.INT), current / Application.getApp().gCaloriesGoal);
  }

  function getNotificationInfo() {
    var notifications = System.getDeviceSettings().notificationCount;

    var iconFunc = new Lang.Method(DataFieldIcons, :drawNotificationActive);
    if (notifications == 0) { iconFunc = new Lang.Method(DataFieldIcons, :drawNotificationInactive); }

    return new DataFieldProperties(FieldType.NOTIFICATION, iconFunc, notifications.format(Format.INT), 0);
  }

  function getBatteryInfo() {
    var stats = System.getSystemStats();
    var current = stats.battery;
    var iconFunc = new Lang.Method(DataFieldIcons, :drawBattery);
    if (current >= 90) { iconFunc = new Lang.Method(DataFieldIcons, :drawBatteryFull); }
    if (current < Application.getApp().gBatteryThreshold) { iconFunc = new Lang.Method(DataFieldIcons, :drawBatteryLow); }
    if (stats.charging) { iconFunc = new Lang.Method(DataFieldIcons, :drawBatteryLoading); }


    return new DataFieldProperties(FieldType.BATTERY, iconFunc, current.format(Format.FLOAT), current / 100);
  }

  function getStepInfo() {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.steps.toDouble();

    return new DataFieldProperties(FieldType.STEPS, new Lang.Method(DataFieldIcons, :drawSteps), current.format(Format.INT), current / activityInfo.stepGoal);
  }

  function getFloorsClimbedInfo() {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.floorsClimbed.toDouble();

    return new DataFieldProperties(FieldType.FLOORS_UP, new Lang.Method(DataFieldIcons, :drawFloorsUp), current.format(Format.INT), current / activityInfo.floorsClimbedGoal);
  }

  function getFloorsDescentInfo() {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.floorsDescended.toDouble();

    return new DataFieldProperties(FieldType.FLOORS_DOWN, new Lang.Method(DataFieldIcons, :drawFloorsDown), current.format(Format.INT), current / activityInfo.floorsClimbedGoal);
  }

  function getActiveMinuteInfo() {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.activeMinutesWeek.total.toDouble();

    return new DataFieldProperties(FieldType.ACTIVE_MINUTES, new Lang.Method(DataFieldIcons, :drawActiveMinutes), current.format(Format.INT), current / activityInfo.activeMinutesWeekGoal);
  }

  function getBluetoothInfo() {
    var iconFunc;
    if (System.getDeviceSettings().phoneConnected) {
      iconFunc = new Lang.Method(DataFieldIcons, :drawBluetoothConnection);
    } else {
      iconFunc = new Lang.Method(DataFieldIcons, :drawNoBluetoothConnection);
    }

    return new DataFieldProperties(FieldType.BLUETOOTH, iconFunc, " ", 0);
  }

  function getAlarmsInfo() {
    var alarmCount = System.getDeviceSettings().alarmCount;
    var iconFunc = new Lang.Method(DataFieldIcons, :drawAlarms);
    if (alarmCount == 0) {
      iconFunc = new Lang.Method(DataFieldIcons, :drawNoAlarms);
    }

    return new DataFieldProperties(FieldType.ALARMS, iconFunc, alarmCount.format(Format.INT), 0);
  }

  function getSecondsInfo() {
    var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    var seconds = now.sec;
    return new DataFieldProperties(FieldType.SECONDS, new Lang.Method(DataFieldIcons, :drawSeconds), seconds.format(Format.INT), seconds / 60.0);
  }
}