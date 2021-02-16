using Toybox.Application;
using Toybox.Background;
using Toybox.Math;
using Toybox.System;
using Toybox.Time.Gregorian;
using Toybox.UserProfile;
using Toybox.WatchUi as Ui;

(:background)
class ProtomoleculeFaceApp extends Application.AppBase {

  var gIconSize;
  var gStrokeWidth;
  var gIsSleepTime = false;

  var gTheme;
  var gCaloriesGoal;
  var gBatteryThreshold;
  var gActiveHeartrate;
  var gDrawRemainingIndicator;
  var gNoProgressDataField1;
  var gNoProgressDataField2;
  var gNoProgressDataField3;
  var gOuterDataField;
  var gUpperDataField1;
  var gUpperDataField2;
  var gLowerDataField1;
  var gLowerDataField2;

  var gIconsFont;
  var gTextFont;

  function initialize() {
    AppBase.initialize();
    loadProperties();
  }

  function loadProperties() {
    var width = System.getDeviceSettings().screenWidth;
    var height = System.getDeviceSettings().screenHeight;
    gIconSize = Math.round((width + height) / 2 / 12.4);
    gStrokeWidth = Math.round((width + height) / 2 / 100);
    loadConfigurableProperties();
  }

  function getIconsFont() {
    if (gIconsFont == null) {
      gIconsFont = Ui.loadResource(Rez.Fonts.IconsFont);
    }

    return gIconsFont;
  }

  function getTextFont() {
    if (gTextFont == null) {
      gTextFont = Ui.loadResource(Rez.Fonts.SecondaryIndicatorFont);
    }

    return gTextFont;
  }

  function loadConfigurableProperties() {
    gTheme = getProperty("theme");
    gCaloriesGoal = getProperty("caloriesGoal");
    gBatteryThreshold = getProperty("batteryThreshold");
    gActiveHeartrate = getProperty("activeHeartrate");
    gNoProgressDataField1 = getProperty("noProgressDataField1");
    gNoProgressDataField2 = getProperty("noProgressDataField2");
    gNoProgressDataField3 = getProperty("noProgressDataField3");
    gOuterDataField = getProperty("outerDataField");
    gUpperDataField1 = getProperty("upperDataField1");
    gUpperDataField2 = getProperty("upperDataField2");
    gLowerDataField1 = getProperty("lowerDataField1");
    gLowerDataField2 = getProperty("lowerDataField2");
  }

  function determineSleepTime() {
    var profile = UserProfile.getProfile();
    var oneDay = Gregorian.duration({:days => 1});
    Log.debug("current " + oneDay.value());
    Log.debug("sleep " + profile.sleepTime.value());
    Log.debug("wake " + profile.wakeTime.value());
    gIsSleepTime = oneDay.greaterThan(profile.sleepTime) && oneDay.greaterThan(profile.wakeTime);
    if (profile.wakeTime.greaterThan(profile.sleepTime) || profile.wakeTime.compare(profile.sleepTime) == 0) {
      gIsSleepTime = !gIsSleepTime;
    }
    Log.debug("sleepTime " + gIsSleepTime);
  }

  function initBackground() {
    if (System has :ServiceDelegate) {     
      Background.registerForSleepEvent();
      Background.registerForWakeEvent();
    }
  }

  // onStart() is called on application start up
  function onStart(state) {
  }

  // onStop() is called when your application is exiting
  function onStop(state) {
  }

  // Return the initial view of your application here
  function getInitialView() {
    initBackground();
    determineSleepTime();
    return [ new ProtomoleculeFaceView() ];
  }

  function getServiceDelegate() {
    return [ new SleepModeServiceDelegate() ];
  }

  // function getSettingsView() {
  //   return [ new ProtomoleculeSettingsView() ]
  // }

  // New app settings have been received so trigger a UI update
  function onSettingsChanged() {
    loadConfigurableProperties();
    WatchUi.requestUpdate();
  }

  function onBackgroundData(data) {
    Log.debug("background data recieved: "+data);
    gIsSleepTime = data;
    WatchUi.requestUpdate();
  }

}