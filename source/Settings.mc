import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Toybox.WatchUi;

module Settings {
  function get(key as Symbol) {
    return _settings[key];
  }

  function set(key as Symbol, value as PropertyValueType) {
    _settings[key] = value;
    if (!setDataField(key, value)) {
      Properties.setValue(key.toString(), value);

      if ((:layout).equals(key)) {
        loadDataFields();
      }
      if ((:sleepLayoutActive).equals(key)) {
        determineSleepTime();
      }
    }
  }

  function setDataField(key as Symbol, value as PropertyValueType) as Boolean {
    if ((:middle1).equals(key)) {
      Properties.setValue("noProgressDataField1", value);
      return true;
    }
    if ((:middle2).equals(key)) {
      Properties.setValue("noProgressDataField2", value);
      return true;
    }
    if ((:middle3).equals(key)) {
      Properties.setValue("noProgressDataField3", value);
      return true;
    }
    if ((:outer).equals(key)) {
      if (_settings[:layout] == LayoutId.ORBIT) {
        Properties.setValue("outerOrbitDataField", value);
        return true;
      } else {
        Properties.setValue("outerDataField", value);
        return true;
      }
    }
    if ((:upper1).equals(key)) {
      if (_settings[:layout] == LayoutId.ORBIT) {
        Properties.setValue("leftOrbitDataField", value);
        return true;
      } else {
        Properties.setValue("upperDataField1", value);
        return true;
      }
    }
    if ((:upper2).equals(key)) {
      if (_settings[:layout] == LayoutId.ORBIT) {
        Properties.setValue("rightOrbitDataField", value);
        return true;
      } else {
        Properties.setValue("upperDataField2", value);
        return true;
      }
    }
    if ((:lower1).equals(key) && _settings[:layout] == LayoutId.CIRCLES) {
      Properties.setValue("lowerDataField1", value);
      return true;
    }
    if ((:lower2).equals(key) && _settings[:layout] == LayoutId.CIRCLES) {
      Properties.setValue("lowerDataField2", value);
      return true;
    }
    return false;
  }

  function resource(resourceId) as Resource {
    if (_resources[resourceId] == null) {
      _resources[resourceId] = WatchUi.loadResource(resourceId);
    }
    return _resources[resourceId];
  }

  function initSettings() {
    var width = System.getDeviceSettings().screenWidth;
    var height = System.getDeviceSettings().screenHeight;

    _settings[:iconSize] = Math.round((width + height) / 2 / 12.4);
    _settings[:strokeWidth] = Math.round((width + height) / 2 / 100);
    _settings[:centerXPos] = width / 2.0;
    _settings[:centerYPos] = height / 2.0;

    loadProperties();
    determineSleepTime();

    DataFieldRez = [
      /*  0 */ Rez.Strings.NoDataField,
      /*  1 */ Rez.Strings.DataFieldSteps,
      /*  2 */ Rez.Strings.DataFieldBattery,
      /*  3 */ Rez.Strings.DataFieldCalories,
      /*  4 */ Rez.Strings.DataFieldActiveMinutes,
      /*  5 */ Rez.Strings.DataFieldHeartRate,
      /*  6 */ Rez.Strings.DataFieldMessages,
      /*  7 */ Rez.Strings.DataFieldFloorsUp,
      /*  8 */ Rez.Strings.DataFieldFloorsDown,
      /*  9 */ Rez.Strings.DataFieldBluetooth,
      /* 10 */ Rez.Strings.DataFieldAlarms,
      /* 11 */ Rez.Strings.DataFieldBodyBattery,
      /* 12 */ Rez.Strings.DataFieldSeconds,
      /* 13 */ Rez.Strings.DataFieldStressLevel,
    ];
  }

  function setAsBoolean(settingsId as Symbol, defaultValue as Lang.Boolean) {
    var value = Properties.getValue(settingsId.toString());
    if (value == null || !(value instanceof Lang.Boolean)) {
      value = defaultValue;
    }
    _settings[settingsId] = value;
  }

  function setAsNumber(settingsId as Symbol, defaultValue as Lang.Number) {
    var value = Properties.getValue(settingsId.toString());
    if (value == null || !(value instanceof Lang.Number)) {
      value = defaultValue;
    }
    _settings[settingsId] = value;
  }

  function loadProperties() {
    setAsNumber(:layout, 0);
    setAsNumber(:theme, 0);
    setAsNumber(:caloriesGoal, 2000);
    setAsNumber(:batteryThreshold, 20);
    setAsNumber(:bodyBatteryThreshold, 30);
    setAsBoolean(:dynamicBodyBattery, false);
    setAsBoolean(:activeHeartrate, false);
    setAsBoolean(:showOrbitIndicatorText, false);
    setAsBoolean(:showMeridiemText, false);
    setAsBoolean(:sleepLayoutActive, false);
    setAsBoolean(:useSystemFontForDate, false);
    setAsBoolean(:showSeconds, false);

    _settings[:middle1] = Properties.getValue("noProgressDataField1");
    _settings[:middle2] = Properties.getValue("noProgressDataField2");
    _settings[:middle3] = Properties.getValue("noProgressDataField3");

    loadDataFields();
  }

  function loadDataFields() {
    _settings[:outer] = _settings[:layout] == LayoutId.ORBIT ? Properties.getValue("outerOrbitDataField") : Properties.getValue("outerDataField");
    _settings[:upper1] = _settings[:layout] == LayoutId.ORBIT ? Properties.getValue("leftOrbitDataField") : Properties.getValue("upperDataField1");
    _settings[:upper2] = _settings[:layout] == LayoutId.ORBIT ? Properties.getValue("rightOrbitDataField") : Properties.getValue("upperDataField2");

    if (_settings[:layout] == LayoutId.CIRCLES) {
      _settings[:lower1] = Properties.getValue("lowerDataField1");
      _settings[:lower2] = Properties.getValue("lowerDataField2");
    }
  }

  function determineSleepTime() {
    var profile = UserProfile.getProfile();
    var current = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    current = new Time.Duration(current.hour * 3600 + current.min * 60);

    if (profile.wakeTime.lessThan(profile.sleepTime)) {
      Settings.isSleepTime = get(:sleepLayoutActive) && (current.greaterThan(profile.sleepTime) || current.lessThan(profile.wakeTime));
    } else if (profile.wakeTime.greaterThan(profile.sleepTime)) {
      Settings.isSleepTime = get(:sleepLayoutActive) && current.greaterThan(profile.sleepTime) && current.lessThan(profile.wakeTime);
    } else {
      Settings.isSleepTime = false;
    }
  }

  var lowPowerMode as Boolean = false;
  var isSleepTime as Boolean = false;

  var _settings as Dictionary<Symbol, PropertyValueType> = {};
  var _resources as Dictionary<Symbol, Resource> = {};
}

var DataFieldRez as Array<ResourceId> = [];
