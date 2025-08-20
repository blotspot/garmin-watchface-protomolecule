import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;

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
    Log.debug("getInitialView");
    Settings.initSettings();
    initBackground();
    return [new ProtomoleculeFaceView()];
  }

  function getServiceDelegate() {
    return [new SleepModeServiceDelegate()];
  }

  function getSettingsView() {
    Log.debug("getSettingsView");
    return [new ProtomoleculeSettingsMenu(), new ProtomoleculeSettingsDelegate()];
  }

  // New app settings have been received so trigger a UI update
  function onSettingsChanged() {
    Log.debug("onSettingsChanged");
    Settings.loadProperties();
    WatchUi.requestUpdate();
  }

  function onDeviceSettingChanged(key as Symbol, value as Object) {
    Log.debug("onDeviceSettingChanged " + key.toString());
    Settings.loadProperties();
    WatchUi.requestUpdate();
  }

  function onBackgroundData(data) {
    Settings.isSleepTime = data;
    WatchUi.requestUpdate();
  }
}
