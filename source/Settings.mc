import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
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
    burnInProtectionMode = hasDisplayMode ? System.getDisplayMode() == System.DISPLAY_MODE_LOW_POWER : false;
    lowPowerMode = burnInProtectionMode;

    loadProperties();
  }

  function loadProperties() {
    determineSleepTime();
  }

  function purge() {
    _resLookup = null;
    _res = null;
  }

  function determineSleepTime() {
    var profile = UserProfile.getProfile();
    var current = System.getClockTime();
    current = new Time.Duration(current.hour * 3600 + current.min * 60);
    if (Log.isDebugEnabled()) {
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

  const iconSize = (System.getDeviceSettings().screenWidth + System.getDeviceSettings().screenHeight) / 2 / 12.4;
  const strokeWidth = iconSize * 0.124;
  const hasDisplayMode as Boolean = System has :getDisplayMode;

  var burnInProtectionMode as Boolean?; // AMOLED Displays
  var lowPowerMode as Boolean?; // All Displays (MiP / AMOLED)
  var isSleepTime as Boolean?; // User configured sleep time active

  function useSleepTimeLayout() as Boolean {
    return Properties.getValue("sleepLayoutActive") && Settings.isSleepTime;
  }

  var _resLookup as Array<ResourceId>?;
  var _res as Array<Resource>?;
}
