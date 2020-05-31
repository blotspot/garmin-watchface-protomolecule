using Toybox.System;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.Application;

module Format {
  const INT = "%i";
  const FLOAT = "%2.0d";
}

module FieldId {
  enum {
    PRIMARY_BOTTOM,
    PRIMARY_RIGHT,
    PRIMARY_LEFT,
    SECONDARY_1,
    SECONDARY_2,
    SECONDARY_3
  }
}

module FieldType {
  enum {
    STEPS, BATTERY, CALORIES, ACTIVE_MINUTES, HEART_RATE, NOTIFICATION, FLOORS_UP
  }
}

module DataFieldInfo {

  class DataFieldProperties {
    var icon;
    var text;
    var progress;

    function initialize(_icon, _text, _progress) {
      icon = _icon;
      text = _text;
      progress = _progress;
    }

  }

  function getInfoForField(fieldId) {
    switch(fieldId) {
      case FieldId.PRIMARY_BOTTOM:
        return getInfoForType(Application.getApp().getProperty("primaryDataFieldBottom"));

      case FieldId.PRIMARY_RIGHT:
        return getInfoForType(Application.getApp().getProperty("primaryDataFieldRight"));

      case FieldId.PRIMARY_LEFT:
        return getInfoForType(Application.getApp().getProperty("primaryDataFieldLeft"));

      case FieldId.SECONDARY_1:
        return getInfoForType(Application.getApp().getProperty("secondaryDataField1"));

      case FieldId.SECONDARY_2:
        return getInfoForType(Application.getApp().getProperty("secondaryDataField2"));

      case FieldId.SECONDARY_3:
        return getInfoForType(Application.getApp().getProperty("secondaryDataField3"));
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

      case FieldType.ACTIVE_MINUTES:
        return getActiveMinuteInfo();

      case FieldType.BATTERY:
        return getBatteryInfo();
    }
  }

  function getHeartRateInfo() {
    var activityInfo = Activity.getActivityInfo();
    var heartRate = activityInfo.currentHeartRate;
    var icon = "p";
    if (heartRate == null && ActivityMonitor has :getHeartRateInfoHistory) {
      var hrHistory = ActivityMonitor.getHeartRateInfoHistory(1, true).next(); // Try to get latest historic entry
      if (hrHistory != null) {
        icon = "P";
        heartRate = hrHistory.heartRate;
      }
    }
    if (heartRate == null || heartRate == ActivityMonitor.INVALID_HR_SAMPLE) {
      heartRate = 0;
      icon = "P";
    }

    return new DataFieldProperties(icon, heartRate.format(Format.INT), 0);
  }

  function getCalorieInfo() {
    var current = ActivityMonitor.getInfo().calories.toDouble();

    return new DataFieldProperties("C", current.format(Format.INT), current / Application.getApp().getProperty("caloriesGoal"));
  }

  function getNotificationInfo() {
    return new DataFieldProperties("N", System.getDeviceSettings().notificationCount.format(Format.INT), 0);
  }

  function getBatteryInfo() {
    var stats = System.getSystemStats();
    var current = stats.battery;
    var icon = "B";
    if (current < 10) { icon = "b"; }
    if (stats.charging) { icon = "c"; }


    return new DataFieldProperties(icon, current.format(Format.FLOAT) + "%", current / 100);
  }

  function getStepInfo() {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.steps.toDouble();

    return new DataFieldProperties("S", current.format(Format.INT), current / activityInfo.stepGoal);
  }

  function getFloorsClimbedInfo() {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.floorsClimbed.toDouble();

    return new DataFieldProperties("U", current.format(Format.INT), current / activityInfo.floorsClimbedGoal);
  }

  function getActiveMinuteInfo() {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.activeMinutesWeek.total.toDouble();

    return new DataFieldProperties("A", current.format(Format.INT), current / activityInfo.activeMinutesWeekGoal);
  }
}