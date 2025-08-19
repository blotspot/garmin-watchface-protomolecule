import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.UserProfile;
import Toybox.WatchUi;

module Settings {
  function set(id as Number, value as PropertyValueType) {
    var k = [
      /*  0 */ "layout",
      /*  1 */ "theme",
      /*  2 */ "caloriesGoal",
      /*  3 */ "batteryThreshold",
      /*  4 */ "bodyBatteryThreshold",
      /*  5 */ "dynamicBodyBattery",
      /*  6 */ "activeHeartrate",
      /*  7 */ "showOrbitIndicatorText",
      /*  8 */ "showMeridiemText",
      /*  9 */ "sleepLayoutActive",
      /* 10 */ "useSystemFontForDate",
      /* 11 */ "showSeconds",
      /* 12 */ "noProgressDataField1",
      /* 13 */ "noProgressDataField2",
      /* 14 */ "noProgressDataField3",
      /* 15 */ "outerOrbitDataField",
      /* 16 */ "leftOrbitDataField",
      /* 17 */ "rightOrbitDataField",
      /* 18 */ "outerDataField",
      /* 19 */ "upperDataField1",
      /* 20 */ "upperDataField2",
      /* 21 */ "lowerDataField1",
      /* 22 */ "lowerDataField2",
    ];
    Properties.setValue(k[id], value);

    if (_set != null) {
      _set[id] = value;
      if (id == 0) {
        // clear saved data fields
        _set[15] = null;
        _set[16] = null;
        _set[17] = null;
        _set[18] = null;
        _set[19] = null;
        _set[20] = null;
        _set[21] = null;
        _set[22] = null;
      }
    }
    if (id == 9) {
      determineSleepTime();
    }
  }

  function setS(id as Number, val as PropertyValueType) {}

  function get(id as Number) as PropertyValueType {
    if (_set == null) {
      _set = new Array<PropertyValueType>[23];
    }
    if (_set[id] == null) {
      var k;
      if (id < 12) {
        k = [
          /*  0 */ "layout",
          /*  1 */ "theme",
          /*  2 */ "caloriesGoal",
          /*  3 */ "batteryThreshold",
          /*  4 */ "bodyBatteryThreshold",
          /*  5 */ "dynamicBodyBattery",
          /*  6 */ "activeHeartrate",
          /*  7 */ "showOrbitIndicatorText",
          /*  8 */ "showMeridiemText",
          /*  9 */ "sleepLayoutActive",
          /* 10 */ "useSystemFontForDate",
          /* 11 */ "showSeconds",
        ];
        _set[id] = Properties.getValue(k[id]);
        if (_set[id] == null) {
          var d = [0, 0, 2000, 20, 30, false, false, false, false, false, false, false];
          _set[id] = d[id];
        }
      }
      // Datafields
      else {
        k = [
          /* 12 */ "noProgressDataField1",
          /* 13 */ "noProgressDataField2",
          /* 14 */ "noProgressDataField3",
          /* 15 */ "outerOrbitDataField",
          /* 16 */ "leftOrbitDataField",
          /* 17 */ "rightOrbitDataField",
          /* 18 */ "outerDataField",
          /* 19 */ "upperDataField1",
          /* 20 */ "upperDataField2",
          /* 21 */ "lowerDataField1",
          /* 22 */ "lowerDataField2",
        ];
        _set[id] = Properties.getValue(k[id - 12]);
      }
    }
    return _set[id];
  }

  function resource(resourceId as ResourceId) as Resource {
    if (_res == null || _resLookup == null) {
      _res = [];
      _resLookup = [];
    }
    var res = _resLookup.indexOf(resourceId);
    if (res < 0) {
      _resLookup.add(resourceId);
      _res.add(WatchUi.loadResource(resourceId));
      res = _res.size() - 1;
    }
    return _res[res];
  }

  function initSettings() {
    burnInProtectionMode = hasDisplayMode ? System.getDisplayMode() == System.DISPLAY_MODE_LOW_POWER : false;
    lowPowerMode = burnInProtectionMode;

    loadProperties();
  }

  function loadProperties() {
    determineSleepTime();
    _set = null;
  }

  function purge() {
    _resLookup = null;
    _res = null;
    _set = null;
  }

  function determineSleepTime() {
    var profile = UserProfile.getProfile();
    var current = System.getClockTime();
    current = new Time.Duration(current.hour * 3600 + current.min * 60);

    Settings.isSleepTime = false;
    if (profile.wakeTime.lessThan(profile.sleepTime)) {
      Settings.isSleepTime = current.greaterThan(profile.sleepTime) || current.lessThan(profile.wakeTime);
    } else if (profile.wakeTime.greaterThan(profile.sleepTime)) {
      Settings.isSleepTime = current.greaterThan(profile.sleepTime) && current.lessThan(profile.wakeTime);
    }
  }

  const iconSize = (System.getDeviceSettings().screenWidth + System.getDeviceSettings().screenHeight) / 2 / 12.4;
  const strokeWidth = iconSize * 0.124;
  const hasDisplayMode as Boolean = System has :getDisplayMode;

  var burnInProtectionMode as Boolean?; // AMOLED Displays
  var lowPowerMode as Boolean?; // All Displays (MiP / AMOLED)
  var isSleepTime as Boolean?; // User configured sleep time active

  function useSleepTimeLayout() as Boolean {
    return (Settings.get(9) as Boolean) && Settings.isSleepTime;
  }

  var _set as Array<PropertyValueType>?;
  var _resLookup as Array<ResourceId>?;
  var _res as Array<Resource>?;
}
