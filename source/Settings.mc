import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Toybox.WatchUi;

module Settings {

  function get(key) {
    return _settings[key];
  }

  function set(key, value) {
    _settings[key] = value;
    if (!setDataField(key, value)) {
      Properties.setValue(key, value);

      if (key.equals("layout")) {
        loadDataFields();
      }
      if (key.equals("sleepLayoutActive")) {
        determineSleepTime();
      }
    }
  }

  function setDataField(key, value) {
    if (key.equals("middle1")) {
      Properties.setValue("noProgressDataField1", value); return true;
    }
    if (key.equals("middle2")) {
      Properties.setValue("noProgressDataField2", value); return true;
    }
    if (key.equals("middle3")) {
      Properties.setValue("noProgressDataField3", value); return true;
    }
    if (key.equals("outer")) {
      if (_settings["layout"] == LayoutId.ORBIT) {
        Properties.setValue("outerOrbitDataField", value); return true;
      } else {
        Properties.setValue("outerDataField", value); return true;
      }
    }
    if (key.equals("upper1")) {
      if (_settings["layout"] == LayoutId.ORBIT) {
        Properties.setValue("leftOrbitDataField", value); return true;
      } else {
        Properties.setValue("upperDataField1", value); return true;
      }
    }
    if (key.equals("upper2")) {
      if (_settings["layout"] == LayoutId.ORBIT) {
        Properties.setValue("rightOrbitDataField", value); return true;
      } else {
        Properties.setValue("upperDataField2", value); return true;
      }
    }
    if (key.equals("lower1") && _settings["layout"] == LayoutId.CIRCLES) {
      Properties.setValue("lowerDataField1", value); return true;
    }
    if (key.equals("lower2") && _settings["layout"] == LayoutId.CIRCLES) {
      Properties.setValue("lowerDataField2", value); return true;
    }
    return false;
  }

  function resource(resourceId) {
    if (_resources[resourceId] == null) {
      _resources[resourceId] = WatchUi.loadResource(resourceId);
    }
    return _resources[resourceId];
  }

  function initSettings() {
    var width = System.getDeviceSettings().screenWidth;
    var height = System.getDeviceSettings().screenHeight;
    
    _settings["iconSize"] = Math.round((width + height) / 2 / 12.4);
    _settings["strokeWidth"] = Math.round((width + height) / 2 / 100);
    _settings["centerXPos"] = width / 2.0;
    _settings["centerYPos"] = height / 2.0;
    
    loadProperties();
    determineSleepTime();

    DataFieldRez = [
      Rez.Strings.NoDataField,
      Rez.Strings.DataFieldSteps,
      Rez.Strings.DataFieldBattery,
      Rez.Strings.DataFieldCalories,
      Rez.Strings.DataFieldActiveMinutes,
      Rez.Strings.DataFieldHeartRate,
      Rez.Strings.DataFieldMessages,
      Rez.Strings.DataFieldFloorsUp,
      Rez.Strings.DataFieldFloorsDown,
      Rez.Strings.DataFieldBluetooth,
      Rez.Strings.DataFieldAlarms,
      Rez.Strings.DataFieldBodyBattery,
      Rez.Strings.DataFieldSeconds,
      Rez.Strings.DataFieldStressLevel
    ];
  }

  function setAsBoolean(settingsId, defaultValue as Lang.Boolean) {
    var value = Properties.getValue(settingsId);
    if (value == null || !(value instanceof Lang.Boolean)) {
      value = defaultValue;
    }
    _settings[settingsId] = value;
  }

  function setAsNumber(settingsId, defaultValue as Lang.Number) {
    var value = Properties.getValue(settingsId);
    if (value == null || !(value instanceof Lang.Number)) {
      value = defaultValue;
    }
    _settings[settingsId] = value;
  }

  function loadProperties() {
    setAsNumber("layout", 0);
    setAsNumber("theme", 0);
    setAsNumber("caloriesGoal", 2000);
    setAsNumber("batteryThreshold", 20);
    setAsBoolean("activeHeartrate", false);
    setAsBoolean("showOrbitIndicatorText", false);
    setAsBoolean("showMeridiemText", false);
    setAsBoolean("sleepLayoutActive", false);
    setAsBoolean("useSystemFontForDate", false);
    setAsBoolean("showSeconds", false);
    
    _settings["middle1"] = Properties.getValue("noProgressDataField1");
    _settings["middle2"] = Properties.getValue("noProgressDataField2");
    _settings["middle3"] = Properties.getValue("noProgressDataField3");
    
    loadDataFields();
  }

  function loadDataFields() {
    _settings["outer"] = (_settings["layout"] == LayoutId.ORBIT) ? Properties.getValue("outerOrbitDataField") : Properties.getValue("outerDataField");
    _settings["upper1"] = (_settings["layout"] == LayoutId.ORBIT) ? Properties.getValue("leftOrbitDataField") : Properties.getValue("upperDataField1");
    _settings["upper2"] = (_settings["layout"] == LayoutId.ORBIT) ? Properties.getValue("rightOrbitDataField") : Properties.getValue("upperDataField2");
    
    if (_settings["layout"] == LayoutId.CIRCLES) {
      _settings["lower1"] = Properties.getValue("lowerDataField1");
      _settings["lower2"] = Properties.getValue("lowerDataField2");
    }
  }

  function determineSleepTime() {
    var profile = UserProfile.getProfile();
    var current = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    current = new Time.Duration(current.hour * 3600 + current.min * 60);

    if (profile.wakeTime.lessThan(profile.sleepTime)) {
      Settings.isSleepTime = (get("sleepLayoutActive") && (current.greaterThan(profile.sleepTime) || current.lessThan(profile.wakeTime)));
    } else if (profile.wakeTime.greaterThan(profile.sleepTime)) {
      Settings.isSleepTime = get("sleepLayoutActive") && current.greaterThan(profile.sleepTime) && current.lessThan(profile.wakeTime);
    } else {
      Settings.isSleepTime = false;
    }
  }

  var lowPowerMode = false;
  var isSleepTime = false;

  var _settings as Dictionary<String, Object> = {};
  var _resources as Dictionary<Symbol, Object> = {};
}

var DataFieldRez as Array<ResourceId> = [];