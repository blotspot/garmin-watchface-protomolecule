using Toybox.Application.Properties;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.UserProfile;
using Toybox.WatchUi;

module Settings {
  function get(key) {
    return _settings[key];
  }

  function set(key, value) {
    Properties.setValue(key, value);
    _settings[key] = value;
    if (key.equals("layout")) {
      loadDataFields();
    }
    if (key.equals("sleepLayoutActive")) {
      determineSleepTime();
    }
  }

  function dataField(key) {
    return _dataField[key];
  }

  function setDataField(key, value) {
    if (key.equals("middle1")) {
      Properties.setValue("noProgressDataField1", value);
    }
    if (key.equals("middle2")) {
      Properties.setValue("noProgressDataField2", value);
    }
    if (key.equals("middle3")) {
      Properties.setValue("noProgressDataField3", value);
    }
    if (key.equals("outer")) {
      if (_settings["layout"] == LayoutId.ORBIT) {
        Properties.setValue("outerOrbitDataField", value);
      } else {
        Properties.setValue("outerDataField", value);
      }
    }
    if (key.equals("upper1")) {
      if (_settings["layout"] == LayoutId.ORBIT) {
        Properties.setValue("leftOrbitDataField", value);
      } else {
        Properties.setValue("upperDataField1", value);
      }
    }
    if (key.equals("upper2")) {
      if (_settings["layout"] == LayoutId.ORBIT) {
        Properties.setValue("rightOrbitDataField", value);
      } else {
        Properties.setValue("upperDataField2", value);
      }
    }
    if (key.equals("lower1") && _settings["layout"] == LayoutId.CIRCLES) {
      Properties.setValue("lowerDataField1", value);
    }
    if (key.equals("lower2") && _settings["layout"] == LayoutId.CIRCLES) {
      Properties.setValue("lowerDataField2", value);
    }

    _dataField[key] = value;
  }

  function iconFont() {
    if (_font[:icons] == null) {
      _font[:icons] = WatchUi.loadResource(Rez.Fonts.IconsFont);
    }

    return _font[:icons];
  }

  function textFont() {
    if (_font[:text] == null) {
      _font[:text] = WatchUi.loadResource(Rez.Fonts.SecondaryIndicatorFont);
    }

    return _font[:text];
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
  }

  function loadProperties() {
    _settings["layout"] = Properties.getValue("layout");
    _settings["theme"] = Properties.getValue("theme");
    _settings["caloriesGoal"] = Properties.getValue("caloriesGoal");
    _settings["batteryThreshold"] = Properties.getValue("batteryThreshold");
    _settings["activeHeartrate"] = Properties.getValue("activeHeartrate");
    _settings["showOrbitIndicatorText"] = Properties.getValue("showOrbitIndicatorText");
    _settings["showMeridiemText"] = Properties.getValue("showMeridiemText");
    _settings["sleepLayoutActive"] = Properties.getValue("sleepLayoutActive");
    _settings["useSystemFontForDate"] = Properties.getValue("useSystemFontForDate");
    
    _dataField["middle1"] = Properties.getValue("noProgressDataField1");
    _dataField["middle2"] = Properties.getValue("noProgressDataField2");
    _dataField["middle3"] = Properties.getValue("noProgressDataField3");
    
    loadDataFields();
  }

  function loadDataFields() {
    _dataField["outer"] = (_settings["layout"] == LayoutId.ORBIT) ? Properties.getValue("outerOrbitDataField") : Properties.getValue("outerDataField");
    _dataField["upper1"] = (_settings["layout"] == LayoutId.ORBIT) ? Properties.getValue("leftOrbitDataField") : Properties.getValue("upperDataField1");
    _dataField["upper2"] = (_settings["layout"] == LayoutId.ORBIT) ? Properties.getValue("rightOrbitDataField") : Properties.getValue("upperDataField2");
    _dataField["lower1"] = (_settings["layout"] == LayoutId.ORBIT) ? null : Properties.getValue("lowerDataField1");
    _dataField["lower2"] = (_settings["layout"] == LayoutId.ORBIT) ? null : Properties.getValue("lowerDataField2");
  }

  function determineSleepTime() {
    var profile = UserProfile.getProfile();
    var current = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    current = new Time.Duration(current.hour * 3600 + current.min * 60);

    if (profile.wakeTime.lessThan(profile.sleepTime)) {
      Settings.isSleepTime = (Settings.get("sleepLayoutActive") && (current.greaterThan(profile.sleepTime) || current.lessThan(profile.wakeTime)));
    } else if (profile.wakeTime.greaterThan(profile.sleepTime)) {
      Settings.isSleepTime = Settings.get("sleepLayoutActive") && current.greaterThan(profile.sleepTime) && current.lessThan(profile.wakeTime);
    } else {
      Settings.isSleepTime = false;
    }
    Log.debug("sleepTime " + Settings.isSleepTime);
  }


  var isSleepTime = false;

  var _dataField = {
    "middle1" => null, 
    "middle2" => null,
    "middle3" => null,
    "outer" => null,
    "upper1" => null,
    "upper2" => null,
    "lower1" => null,
    "lower2" => null
  };

  var _settings = {
    "iconSize" => null,
    "strokeWidth" => null,
    "centerXPos" => null,
    "centerYPos" => null,
    "layout" => null,
    "theme" => null,
    "caloriesGoal" => 0,
    "batteryThreshold" => 0,
    "activeHeartrate" => false,
    "showOrbitIndicatorText" => false,
    "showMeridiemText" => false,
    "sleepLayoutActive" => false,
    "useSystemFontForDate" => false
  };

  var _font = {
    :icons => null,
    :text => null
  };
}