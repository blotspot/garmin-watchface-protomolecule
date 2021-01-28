using Toybox.System;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.Application;
using Toybox.Lang as Lang;
using Toybox.Time;

module Format {
  const INT = "%i";
  const FLOAT = "%2.0d";
}

module FieldId {
  enum {
    PRIMARY_BOTTOM,
    PRIMARY_LEFT,
    PRIMARY_RIGHT,
    SECONDARY_1,
    SECONDARY_2,
    SECONDARY_3,
    SIMPLE_LEFT,
    SIMPLE_RIGHT
  }
}

module FieldType {
  enum {
    STEPS, BATTERY, CALORIES, ACTIVE_MINUTES, HEART_RATE, NOTIFICATION, FLOORS_UP, FLOORS_DOWN
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
    switch(fieldId) {
      case FieldId.PRIMARY_BOTTOM:
        return getInfoForType(Application.getApp().gPrimaryDataFieldBottom);

      case FieldId.PRIMARY_RIGHT:
        return getInfoForType(Application.getApp().gPrimaryDataFieldRight);

      case FieldId.PRIMARY_LEFT:
        return getInfoForType(Application.getApp().gPrimaryDataFieldLeft);

      case FieldId.SECONDARY_1:
        return getInfoForType(Application.getApp().gSecondaryDataField1);

      case FieldId.SECONDARY_2:
        return getInfoForType(Application.getApp().gSecondaryDataField2);

      case FieldId.SECONDARY_3:
        return getInfoForType(Application.getApp().gSecondaryDataField3);

      case FieldId.SIMPLE_LEFT:
        return getInfoForType(Application.getApp().gSimpleLayoutDataFieldLeft);

      case FieldId.SIMPLE_RIGHT:
        return getInfoForType(Application.getApp().gSimpleLayoutDataFieldRight);

      default:
        return null;
    }
  }

  function getInfoForType(fieldType) {
    var info;
    switch(fieldType) {
      case FieldType.HEART_RATE:
        return getHeartRateInfo();

      case FieldType.CALORIES:
        return getCalorieInfo();

      case FieldType.NOTIFICATION:
        return getNotificationInfo();

      case FieldType.STEPS:
        return getStepInfo();

      case FieldType.FLOORS_UP:
        return getFloorsClimbedInfo();

      case FieldType.FLOORS_DOWN:
        return getFloorsDescentInfo();

      case FieldType.ACTIVE_MINUTES:
        return getActiveMinuteInfo();

      case FieldType.BATTERY:
        return getBatteryInfo();
    }
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
      icon = new Lang.Method(DataFieldIcons, :drawHeartRate);
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
}