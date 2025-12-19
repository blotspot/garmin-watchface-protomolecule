import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Complications;
import Toybox.UserProfile;
import Toybox.WatchUi;

module Settings {
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
    burnInProtectionMode = HAS_DISPLAY_MODE ? System.getDisplayMode() == System.DISPLAY_MODE_LOW_POWER : false;
    lowPowerMode = burnInProtectionMode;
  }

  function purge() {
    _resLookup = null;
    _res = null;
  }

  function determineSleepTime() {
    var profile = UserProfile.getProfile();
    var current = System.getClockTime();
    current = new Time.Duration(current.hour * 3600 + current.min * 60);
    if (Log has :debug) {
      Log.debug("Sleep Time: " + (profile.sleepTime.value() / 3600).format(Format.INT_ZERO) + ":" + ((profile.sleepTime.value() % 3600) / 60).format(Format.INT_ZERO));
      Log.debug("Wake Time: " + (profile.wakeTime.value() / 3600).format(Format.INT_ZERO) + ":" + ((profile.wakeTime.value() % 3600) / 60).format(Format.INT_ZERO));
    }
    Settings.isSleepTime = false;
    if (profile.wakeTime.lessThan(profile.sleepTime)) {
      Settings.isSleepTime = current.greaterThan(profile.sleepTime) || current.lessThan(profile.wakeTime);
    } else if (profile.wakeTime.greaterThan(profile.sleepTime)) {
      Settings.isSleepTime = current.greaterThan(profile.sleepTime) && current.lessThan(profile.wakeTime);
    }
  }

  const ICON_SIZE = (System.getDeviceSettings().screenWidth + System.getDeviceSettings().screenHeight) / 2 / 12.4;
  const PEN_WIDTH = ICON_SIZE * 0.124;
  const HAS_DISPLAY_MODE as Boolean = System has :getDisplayMode;

  var burnInProtectionMode as Boolean?; // AMOLED Displays
  var lowPowerMode as Boolean?; // All Displays (MiP / AMOLED)
  var isSleepTime as Boolean?; // User configured sleep time active

  function useSleepTimeLayout() as Boolean {
    return Properties.getValue("sleepLayoutActive") && Settings.isSleepTime;
  }

  (:onPressComplication)
  function getComplicationIdFromProperty(property as String) as Complications.Id? {
    var type = Properties.getValue(property) as Number;
    try {
      if (type > 0) {
        return new Complications.Id(type as Complications.Type);
      }
    } catch (e) {
      if (Log has :debug) {
        Log.debug("can not load comp id from property '" + property + "'. Error: " + e.getErrorMessage());
      }
    }
    return null;
  }

  (:onPressComplication)
  function getComplicationLongLabelFromProperty(property as String) as String? {
    var id = getComplicationIdFromProperty(property);
    if (id != null) {
      return Complications.getComplication(id).longLabel;
    }
    return null;
  }

  var _resLookup as Array<ResourceId>?;
  var _res as Array<Resource>?;
}
