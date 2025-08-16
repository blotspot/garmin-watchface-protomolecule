import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Background;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Toybox.WatchUi;

(:background)
class ProtomoleculeFaceApp extends Application.AppBase {
  function initialize() {
    AppBase.initialize();
  }

  function initBackground() {
    if (System has :ServiceDelegate) {
      Background.registerForSleepEvent();
      Background.registerForWakeEvent();
    }
  }

  // onStart() is called on application start up
  function onStart(state) {}

  // onStop() is called when your application is exiting
  function onStop(state) {}

  // Return the initial view of your application here
  function getInitialView() {
    Settings.initSettings();
    initBackground();
    return [new ProtomoleculeFaceView()];
  }

  function getServiceDelegate() {
    return [new SleepModeServiceDelegate()];
  }

  function getSettingsView() {
    return [new ProtomoleculeSettingsMenu(), new ProtomoleculeSettingsDelegate()];
  }

  // New app settings have been received so trigger a UI update
  function onSettingsChanged() {
    Settings.loadProperties();
    Settings.determineSleepTime();
    WatchUi.requestUpdate();
  }

  function onBackgroundData(data) {
    Settings.isSleepTime = data;
    WatchUi.requestUpdate();
  }
}
