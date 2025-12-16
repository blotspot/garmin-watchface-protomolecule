import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application.Properties;
import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.Math;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Enums;

module DataFieldInfo {
  class DataFieldProperties {
    var fieldType as FieldType;
    var icon as IconDrawable;
    var text as String?;
    var progress as Numeric;
    var reverse as Boolean;

    function initialize(_fieldType as FieldType, _text as String?, _progress as Numeric, _reverse as Boolean) {
      fieldType = _fieldType;
      text = _text;
      progress = _progress;
      reverse = _reverse;
      icon = getIconDrawableForType(fieldType, progress);
    }

    (:api420AndAbove)
    function getComplicationType() as Toybox.Complications.Type? {
      return getComplicationsTypeForField(fieldType);
    }

    function equals(other) as Boolean {
      if (other != null && other instanceof DataFieldProperties) {
        return other.fieldType == fieldType && other.icon.equals(icon) && (other.text == null ? other.text == text : other.text.equals(text)) && other.progress == progress;
      }
      return false;
    }
  }

  function getInfoForField(fieldId as FieldId) as DataFieldProperties? {
    if (fieldId == Enums.FIELD_NO_PROGRESS_1) {
      return getInfoForType(Properties.getValue("noProgressDataField1") as FieldType);
    } else if (fieldId == Enums.FIELD_NO_PROGRESS_2) {
      return getInfoForType(Properties.getValue("noProgressDataField2") as FieldType);
    } else if (fieldId == Enums.FIELD_NO_PROGRESS_3) {
      return getInfoForType(Properties.getValue("noProgressDataField3") as FieldType);
    } else if (fieldId == Enums.FIELD_ORBIT_OUTER) {
      return getInfoForType(Properties.getValue("outerOrbitDataField") as FieldType);
    } else if (fieldId == Enums.FIELD_ORBIT_LEFT) {
      return getInfoForType(Properties.getValue("leftOrbitDataField") as FieldType);
    } else if (fieldId == Enums.FIELD_ORBIT_RIGHT) {
      return getInfoForType(Properties.getValue("rightOrbitDataField") as FieldType);
    } else if (fieldId == Enums.FIELD_CIRCLES_OUTER) {
      return getInfoForType(Properties.getValue("outerDataField") as FieldType);
    } else if (fieldId == Enums.FIELD_CIRCLES_UPPER_1) {
      return getInfoForType(Properties.getValue("upperDataField1") as FieldType);
    } else if (fieldId == Enums.FIELD_CIRCLES_UPPER_2) {
      return getInfoForType(Properties.getValue("upperDataField2") as FieldType);
    } else if (fieldId == Enums.FIELD_CIRCLES_LOWER_1) {
      return getInfoForType(Properties.getValue("lowerDataField1") as FieldType);
    } else if (fieldId == Enums.FIELD_CIRCLES_LOWER_2) {
      return getInfoForType(Properties.getValue("lowerDataField2") as FieldType);
    } else if (fieldId == Enums.FIELD_SLEEP_LEFT) {
      return getInfoForType(Properties.getValue("sleepModeDataField1") as FieldType);
    } else if (fieldId == Enums.FIELD_SLEEP_MIDDLE) {
      return getInfoForType(Properties.getValue("sleepModeDataField2") as FieldType);
    } else if (fieldId == Enums.FIELD_SLEEP_RIGHT) {
      return getInfoForType(Properties.getValue("sleepModeDataField3") as FieldType);
    } else if (fieldId == Enums.FIELD_SLEEP_UP) {
      return getInfoForType(Properties.getValue("sleepModeDataFieldUp") as FieldType);
    } else {
      return null;
    }
  }

  function getInfoForType(fieldType as FieldType) as DataFieldProperties? {
    if (fieldType == Enums.DATA_HEART_RATE) {
      return getHeartRateInfo();
    } else if (fieldType == Enums.DATA_CALORIES) {
      return getCalorieInfo();
    } else if (fieldType == Enums.DATA_ACTIVE_CALORIES) {
      return getActiveCalorieInfo();
    } else if (fieldType == Enums.DATA_NOTIFICATION) {
      return getNotificationInfo();
    } else if (fieldType == Enums.DATA_STEPS) {
      return getStepInfo();
    } else if (fieldType == Enums.DATA_FLOORS_UP) {
      return getFloorsClimbedInfo();
    } else if (fieldType == Enums.DATA_FLOORS_DOWN) {
      return getFloorsDescentInfo();
    } else if (fieldType == Enums.DATA_ACTIVE_MINUTES) {
      return getActiveMinuteInfo();
    } else if (fieldType == Enums.DATA_BATTERY) {
      return getBatteryInfo();
    } else if (fieldType == Enums.DATA_BLUETOOTH) {
      return getBluetoothInfo();
    } else if (fieldType == Enums.DATA_ALARMS) {
      return getAlarmsInfo();
    } else if (fieldType == Enums.DATA_BODY_BATTERY) {
      return getBodyBatteryInfo();
    } else if (fieldType == Enums.DATA_STRESS_LEVEL) {
      return getStressLevel();
    } else {
      return null;
    }
  }

  (:api420AndAbove)
  function getComplicationsTypeForField(fieldType as FieldType) as Toybox.Complications.Type? {
    switch (fieldType) {
      case Enums.DATA_STEPS:
        return Toybox.Complications.COMPLICATION_TYPE_STEPS;
      case Enums.DATA_BATTERY:
        return Toybox.Complications.COMPLICATION_TYPE_BATTERY; // does nothing
      case Enums.DATA_CALORIES:
      case Enums.DATA_ACTIVE_CALORIES:
        return Toybox.Complications.COMPLICATION_TYPE_CALORIES;
      case Enums.DATA_ACTIVE_MINUTES:
        return Toybox.Complications.COMPLICATION_TYPE_INTENSITY_MINUTES;
      case Enums.DATA_HEART_RATE:
        return Toybox.Complications.COMPLICATION_TYPE_HEART_RATE;
      case Enums.DATA_NOTIFICATION:
        return Toybox.Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT;
      case Enums.DATA_FLOORS_UP:
      case Enums.DATA_FLOORS_DOWN:
        return Toybox.Complications.COMPLICATION_TYPE_FLOORS_CLIMBED;
      case Enums.DATA_BLUETOOTH:
        return Toybox.Complications.COMPLICATION_TYPE_INVALID;
      case Enums.DATA_ALARMS:
        return Toybox.Complications.COMPLICATION_TYPE_INVALID;
      case Enums.DATA_BODY_BATTERY:
        return Toybox.Complications.COMPLICATION_TYPE_BODY_BATTERY;
      case Enums.DATA_STRESS_LEVEL:
        return Toybox.Complications.COMPLICATION_TYPE_STRESS;
      default:
        return null;
    }
  }

  //! status should be `null` when getting icons for settings
  function getIconDrawableForType(fieldType as FieldType, status as Numeric?) as IconDrawable {
    var icon = null;
    if (fieldType == Enums.DATA_HEART_RATE) {
      icon = new IconDrawable(fieldType, status == null || status > 0 ? "p" : "P", false);
    } else if (fieldType == Enums.DATA_CALORIES || fieldType == Enums.DATA_ACTIVE_CALORIES) {
      icon = new IconDrawable(fieldType, "c", false);
    } else if (fieldType == Enums.DATA_NOTIFICATION) {
      icon = new IconDrawable(fieldType, status == null || status > 0 ? "n" : "N", true);
    } else if (fieldType == Enums.DATA_STEPS) {
      icon = new IconDrawable(fieldType, "s", false);
    } else if (fieldType == Enums.DATA_FLOORS_UP) {
      icon = new IconDrawable(fieldType, "F", false);
    } else if (fieldType == Enums.DATA_FLOORS_DOWN) {
      icon = new IconDrawable(fieldType, "f", false);
    } else if (fieldType == Enums.DATA_ACTIVE_MINUTES) {
      icon = new IconDrawable(fieldType, "t", false);
    } else if (fieldType == Enums.DATA_BATTERY) {
      var iconText = "m";
      if (status != null && status >= 0.9) {
        iconText = "h";
      }
      if (status != null && status < Properties.getValue("batteryThreshold") / 100d) {
        iconText = "k";
      }
      var stats = System.getSystemStats();
      if (status != null && stats.charging) {
        iconText = "l";
      }
      icon = new IconDrawable(fieldType, iconText, status != null);
    } else if (fieldType == Enums.DATA_BLUETOOTH) {
      icon = new IconDrawable(fieldType, status == null || status > 0 ? "b" : "B", false);
    } else if (fieldType == Enums.DATA_ALARMS) {
      icon = new IconDrawable(fieldType, status == null || status > 0 ? "a" : "A", false);
    } else if (fieldType == Enums.DATA_BODY_BATTERY) {
      var iconText = "o";
      if (Properties.getValue("dynamicBodyBattery")) {
        if (status != null && status <= 0.05) {
          iconText = "z";
        } else if (status != null && status < Properties.getValue("bodyBatteryThreshold") / 100d) {
          iconText = "y";
        }
      }
      icon = new IconDrawable(fieldType, iconText, false);
    } else if (fieldType == Enums.DATA_STRESS_LEVEL) {
      icon = new IconDrawable(fieldType, "x", false);
    } else {
      icon = new IconDrawable(fieldType, null, false);
    }

    return icon;
  }

  function getHeartRateInfo() as DataFieldProperties {
    var heartRate = null;
    if (Activity.Info has :currentHeartRate) {
      heartRate = Activity.getActivityInfo().currentHeartRate;
    }
    if (heartRate == null && ActivityMonitor has :getHeartRateHistory) {
      var hrHistory = ActivityMonitor.getHeartRateHistory(new Time.Duration(60), true).next(); // Try to get latest entry from the last minute
      if (hrHistory != null) {
        heartRate = hrHistory.heartRate;
      }
    }
    if (heartRate != null && heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
      return new DataFieldProperties(Enums.DATA_HEART_RATE, heartRate.format(Format.INT), 1, false);
    }

    return new DataFieldProperties(Enums.DATA_HEART_RATE, null, 0, false);
  }

  function getCalorieInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.calories.toDouble(); // turn to double for division

    return new DataFieldProperties(Enums.DATA_CALORIES, current.format(Format.INT), current / Properties.getValue("caloriesGoal"), false);
  }

  function getActiveCalorieInfo() as DataFieldProperties {
    var profile = UserProfile.getProfile();
    if (profile.birthYear == null && profile.height == null && profile.weight == null) {
      return new DataFieldProperties(Enums.DATA_ACTIVE_CALORIES, null, 0, false);
    }
    var activityInfo = ActivityMonitor.getInfo();
    var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    var ageFactor = 6.116 * (now.year - profile.birthYear);
    var heightFactor = 7.628 * profile.height;
    var weightFactor = 12.2 * (profile.weight / 1000.0);
    var genderFactor = -197.6;

    if (profile.gender == UserProfile.GENDER_MALE) {
      genderFactor = 5.2;
    }
    var resting = genderFactor - ageFactor + heightFactor + weightFactor;
    var relResting = Math.round(((now.hour * 60 + now.min) * resting) / 1440);
    var active = activityInfo.calories.toDouble() - relResting;

    return new DataFieldProperties(Enums.DATA_ACTIVE_CALORIES, active.format(Format.INT), active / Properties.getValue("caloriesGoal"), false);
  }

  function getNotificationInfo() as DataFieldProperties {
    var notifications = System.getDeviceSettings().notificationCount;

    if (notifications > 0) {
      return new DataFieldProperties(Enums.DATA_NOTIFICATION, notifications.format(Format.INT), 1, false);
    }

    return new DataFieldProperties(Enums.DATA_NOTIFICATION, "0", 0, false);
  }

  function getBatteryInfo() as DataFieldProperties {
    var stats = System.getSystemStats();
    var current = stats.battery;

    return new DataFieldProperties(Enums.DATA_BATTERY, current.format("%2.0d"), current / 100, true);
  }

  function getStepInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.steps != null ? activityInfo.steps.toDouble() : 0;
    var goal = activityInfo.stepGoal != null ? activityInfo.stepGoal : 10000;

    return new DataFieldProperties(Enums.DATA_STEPS, current.format(Format.INT), current / goal, false);
  }

  function getFloorsClimbedInfo() as DataFieldProperties {
    var current = 0;
    var goal = 10;
    if (ActivityMonitor.Info has :floorsClimbed) {
      var activityInfo = ActivityMonitor.getInfo();
      current = activityInfo.floorsClimbed.toDouble();
      if (ActivityMonitor.Info has :floorsClimbedGoal) {
        goal = activityInfo.floorsClimbedGoal;
      }
    }
    return new DataFieldProperties(Enums.DATA_FLOORS_UP, current.format(Format.INT), current / goal, false);
  }

  function getFloorsDescentInfo() as DataFieldProperties {
    var current = 0;
    var goal = 10;

    if (ActivityMonitor.Info has :floorsDescended) {
      var activityInfo = ActivityMonitor.getInfo();
      current = activityInfo.floorsDescended.toDouble();
      if (ActivityMonitor.Info has :floorsClimbedGoal) {
        goal = activityInfo.floorsClimbedGoal;
      }
    }
    return new DataFieldProperties(Enums.DATA_FLOORS_DOWN, current.format(Format.INT), current / goal, false);
  }

  function getActiveMinuteInfo() as DataFieldProperties {
    if (ActivityMonitor.Info has :activeMinutesWeek) {
      var activityInfo = ActivityMonitor.getInfo();
      var current = activityInfo.activeMinutesWeek.total.toDouble();

      return new DataFieldProperties(Enums.DATA_ACTIVE_MINUTES, current.format(Format.INT), current / activityInfo.activeMinutesWeekGoal, false);
    }

    return new DataFieldProperties(Enums.DATA_ACTIVE_MINUTES, null, 0, false);
  }

  function getBluetoothInfo() as DataFieldProperties {
    if (System.getDeviceSettings().phoneConnected) {
      return new DataFieldProperties(Enums.DATA_BLUETOOTH, null, 1, false);
    } else {
      return new DataFieldProperties(Enums.DATA_BLUETOOTH, null, 0, false);
    }
  }

  function getAlarmsInfo() as DataFieldProperties {
    var alarmCount = 0;
    alarmCount = System.getDeviceSettings().alarmCount;
    if (alarmCount > 0) {
      return new DataFieldProperties(Enums.DATA_ALARMS, alarmCount.format(Format.INT), 1, false);
    }
    return new DataFieldProperties(Enums.DATA_ALARMS, "0", 0, false);
  }

  function getBodyBattery() as Number {
    // crashed on descentmk2s between 12h/24h, OOM
    var durations = [
      new Time.Duration(60 * 30), // 30 minutes
      new Time.Duration(60 * 60), // 1 hour
      new Time.Duration(60 * 60 * 6), // 6 hours
      // it seems to me as after 6h the old body battery value lost its meaning completely
    ];

    for (var i = 0; i < durations.size(); i++) {
      var duration = durations[i];
      var bbIterator = SensorHistory.getBodyBatteryHistory({
        :period => duration,
        :order => SensorHistory.ORDER_NEWEST_FIRST,
      });

      var sample = bbIterator.next();
      while (sample != null) {
        if (sample.data != null && sample.data.toNumber() != null) {
          return sample.data.toNumber();
        }
        sample = bbIterator.next();
      }
    }
    return 0;
  }

  function getBodyBatteryInfo() as DataFieldProperties {
    if (Toybox has :SensorHistory && SensorHistory has :getBodyBatteryHistory) {
      var bodyBattery = getBodyBattery();
      return new DataFieldProperties(Enums.DATA_BODY_BATTERY, bodyBattery.format(Format.INT), bodyBattery / 100.0, true);
    }
    return new DataFieldProperties(Enums.DATA_BODY_BATTERY, null, 0, true);
  }

  function getStressLevel() as DataFieldProperties {
    var stressLevel = null;
    if (ActivityMonitor.Info has :stressScore) {
      var activityInfo = ActivityMonitor.getInfo();
      if (activityInfo.stressScore != null) {
        stressLevel = activityInfo.stressScore.toDouble();
      }
    }
    if (stressLevel == null && Toybox has :SensorHistory && Toybox.SensorHistory has :getStressHistory) {
      stressLevel = getLatestStressLevelFromSensorHistory();
    } else if (stressLevel == null) {
      return new DataFieldProperties(Enums.DATA_STRESS_LEVEL, null, 0, true);
    }

    return new DataFieldProperties(Enums.DATA_STRESS_LEVEL, stressLevel.format(Format.INT), stressLevel / 100.0, true);
  }

  function getLatestStressLevelFromSensorHistory() as Number {
    var iter = SensorHistory.getStressHistory({ :period => 1 });
    var stressLevel = iter.next();
    if (stressLevel != null) {
      return stressLevel.data;
    }
    return 0;
  }
}
