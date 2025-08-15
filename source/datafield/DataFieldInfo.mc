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
    var fieldType as Number;
    var icon as IconDrawable;
    var text as String;
    var progress as Numeric;
    var reverse as Boolean;

    function initialize(_fieldType as Number, _text as String, _progress as Numeric, _reverse as Boolean) {
      fieldType = _fieldType;
      text = _text;
      progress = _progress;
      reverse = _reverse;
      icon = getIconDrawableForType(fieldType, progress);
    }

    function equals(other) as Boolean {
      if (other != null && other instanceof DataFieldProperties) {
        return other.fieldType == fieldType && other.icon.equals(icon) && other.text.equals(text) && other.progress == progress;
      }
      return false;
    }
  }

  function getInfoForField(fieldId as Number) as DataFieldProperties? {
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
    } else {
      return null;
    }
  }

  function getInfoForType(fieldType as Number) as DataFieldProperties? {
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

  function getIconDrawableForType(fieldType as Number, status as Numeric?) as IconDrawable {
    var icon = null;
    if (fieldType == FieldType.HEART_RATE) {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => status == null || status > 0 ? "p" : "P",
      });
    } else if (fieldType == FieldType.CALORIES || fieldType == FieldType.ACTIVE_CALORIES) {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => "c",
      });
    } else if (fieldType == FieldType.NOTIFICATION) {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => status == null || status > 0 ? "n" : "N",
        :offsetY => true,
      });
    } else if (fieldType == FieldType.STEPS) {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => "s",
      });
    } else if (fieldType == FieldType.FLOORS_UP) {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => "F",
      });
    } else if (fieldType == FieldType.FLOORS_DOWN) {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => "f",
      });
    } else if (fieldType == FieldType.ACTIVE_MINUTES) {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => "t",
      });
    } else if (fieldType == FieldType.BATTERY) {
      var iconText = "m";
      if (status != null && status >= 0.9) {
        iconText = "h";
      }
      if (status != null && status < Settings.get("batteryThreshold") / 100d) {
        iconText = "k";
      }
      var stats = System.getSystemStats();
      if (status != null && stats.charging) {
        iconText = "l";
      }
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => iconText,
        :offsetY => true,
      });
    } else if (fieldType == FieldType.BLUETOOTH) {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => status == null || status > 0 ? "b" : "B",
      });
    } else if (fieldType == FieldType.ALARMS) {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => status == null || status > 0 ? "a" : "A",
      });
    } else if (fieldType == FieldType.BODY_BATTERY) {
      var iconText = "o";
      if (status != null && status <= 0.05) {
        iconText = "z";
      } else if (status != null && status < Settings.get("bodyBatteryThreshold") / 100d) {
        iconText = "y";
      }
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => iconText,
      });
    } else if (fieldType == FieldType.STRESS_LEVEL) {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => "x",
      });
    } else {
      icon = new IconDrawable({
        :identifier => fieldType,
        :icon => "",
      });
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
      return new DataFieldProperties(FieldType.HEART_RATE, heartRate.format(Format.INT), 1, false);
    }

    return new DataFieldProperties(FieldType.HEART_RATE, "0", 0, false);
  }

  function getCalorieInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.calories;

    return new DataFieldProperties(FieldType.CALORIES, current.format(Format.INT), current / Settings.get("caloriesGoal"), false);
  }

  function getActiveCalorieInfo() as DataFieldProperties {
    var profile = UserProfile.getProfile();
    if (profile.birthYear == null && profile.height == null && profile.weight == null) {
      Log.debug("User profile not set, cannot calculate active calories");
      return getCalorieInfo();
    }
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
    var relResting = Math.round(((today.hour * 60 + today.min) * resting) / 1440);
    var active = activityInfo.calories - relResting;

    return new DataFieldProperties(FieldType.ACTIVE_CALORIES, active.format(Format.INT), active / Settings.get("caloriesGoal"), false);
  }

  function getNotificationInfo() as DataFieldProperties {
    var notifications = System.getDeviceSettings().notificationCount;

    if (notifications > 0) {
      return new DataFieldProperties(FieldType.NOTIFICATION, notifications.format(Format.INT), 1, false);
    }

    return new DataFieldProperties(FieldType.NOTIFICATION, "0", 0, false);
  }

  function getBatteryInfo() as DataFieldProperties {
    var stats = System.getSystemStats();
    var current = stats.battery;

    return new DataFieldProperties(FieldType.BATTERY, current.format(Format.FLOAT), current / 100, true);
  }

  function getStepInfo() as DataFieldProperties {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.steps != null ? activityInfo.steps.toDouble() : 0;
    var goal = activityInfo.stepGoal != null ? activityInfo.stepGoal : 10000;

    return new DataFieldProperties(FieldType.STEPS, current.format(Format.INT), current / goal, false);
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
    return new DataFieldProperties(FieldType.FLOORS_UP, current.format(Format.INT), current / goal, false);
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
    return new DataFieldProperties(FieldType.FLOORS_DOWN, current.format(Format.INT), current / goal, false);
  }

  function getActiveMinuteInfo() as DataFieldProperties {
    if (ActivityMonitor.Info has :activeMinutesWeek) {
      var activityInfo = ActivityMonitor.getInfo();
      var current = activityInfo.activeMinutesWeek.total.toDouble();

      return new DataFieldProperties(FieldType.ACTIVE_MINUTES, current.format(Format.INT), current / activityInfo.activeMinutesWeekGoal, false);
    }

    Log.debug("active minutes not supported");
    return new DataFieldProperties(FieldType.ACTIVE_MINUTES, "0", 0, false);
  }

  function getBluetoothInfo() as DataFieldProperties {
    if (System.getDeviceSettings().phoneConnected) {
      return new DataFieldProperties(FieldType.BLUETOOTH, " ", 1, false);
    } else {
      return new DataFieldProperties(FieldType.BLUETOOTH, " ", 0, false);
    }
  }

  function getAlarmsInfo() as DataFieldProperties {
    var alarmCount = 0;
    alarmCount = System.getDeviceSettings().alarmCount;
    if (alarmCount > 0) {
      return new DataFieldProperties(FieldType.ALARMS, alarmCount.format(Format.INT), 1, false);
    }
    return new DataFieldProperties(FieldType.ALARMS, "0", 0, false);
  }

  function getBodyBattery() as Number {
    if (Toybox has :SensorHistory && SensorHistory has :getBodyBatteryHistory) {
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
    }
    return 0;
  }

  function getBodyBatteryInfo() as DataFieldProperties {
    var bodyBattery = getBodyBattery();
    return new DataFieldProperties(FieldType.BODY_BATTERY, bodyBattery.format(Format.INT), bodyBattery / 100.0, true);
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
    if (stressLevel == null && Toybox has :SensorHistory && Toybox.SensorHistory has :getStressHistory) {
      Log.debug("Using stress level info");
      stressLevel = getLatestStressLevelFromSensorHistory();
    } else if (stressLevel == null) {
      Log.debug("Stress level not supported.");
      stressLevel = 0;
    }

    return new DataFieldProperties(FieldType.STRESS_LEVEL, stressLevel.format(Format.INT), stressLevel / 100.0, true);
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
