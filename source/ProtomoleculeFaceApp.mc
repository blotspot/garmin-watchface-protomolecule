using Toybox.Application;
using Toybox.Background;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.UserProfile;
using Toybox.WatchUi as Ui;

(:background)
class ProtomoleculeFaceApp extends Application.AppBase {

  var gIconSize;
  var gStrokeWidth;
  var gIsSleepTime = false;

  var gLayout;
  var gTheme;
  var gCaloriesGoal;
  var gBatteryThreshold;
  var gActiveHeartrate;
  var gSleepLayoutActive;
  var gShowOrbitIndicatorText;
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

  var gCenterXPos;
  var gCenterYPos;

  function initialize() {
    AppBase.initialize();
    loadProperties();
  }

  function loadProperties() {
    var width = System.getDeviceSettings().screenWidth;
    var height = System.getDeviceSettings().screenHeight;
    gIconSize = Math.round((width + height) / 2 / 12.4);
    gStrokeWidth = Math.round((width + height) / 2 / 100);
    gCenterXPos = width / 2.0;
    gCenterYPos = height / 2.0;
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
    gLayout = getProperty("layout");
    gTheme = getProperty("theme");
    gCaloriesGoal = getProperty("caloriesGoal");
    gBatteryThreshold = getProperty("batteryThreshold");
    gActiveHeartrate = getProperty("activeHeartrate");
    gShowOrbitIndicatorText = getProperty("showOrbitIndicatorText");
    gSleepLayoutActive = getProperty("sleepTimeLayout");
    gNoProgressDataField1 = getProperty("noProgressDataField1");
    gNoProgressDataField2 = getProperty("noProgressDataField2");
    gNoProgressDataField3 = getProperty("noProgressDataField3");
    gOuterDataField = (gLayout == 0) ? getProperty("outerOrbitDataField") : getProperty("outerDataField");
    gUpperDataField1 = (gLayout == 0) ? getProperty("leftOrbitDataField") : getProperty("upperDataField1");
    gUpperDataField2 = (gLayout == 0) ? getProperty("rightOrbitDataField") :  getProperty("upperDataField2");
    gLowerDataField1 = (gLayout == 0) ? null : getProperty("lowerDataField1");
    gLowerDataField2 = (gLayout == 0) ? null : getProperty("lowerDataField2");
  }

  function determineSleepTime() {
    var profile = UserProfile.getProfile();
    var current = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    current = new Time.Duration(current.hour * 3600 + current.min * 60);

    if (profile.wakeTime.lessThan(profile.sleepTime)) {
      gIsSleepTime = gSleepLayoutActive && (current.greaterThan(profile.sleepTime) || current.lessThan(profile.wakeTime));
    } else if (profile.wakeTime.greaterThan(profile.sleepTime)) {
      gIsSleepTime = gSleepLayoutActive && current.greaterThan(profile.sleepTime) && current.lessThan(profile.wakeTime);
    } else {
      gIsSleepTime = false;
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
    determineSleepTime();
    WatchUi.requestUpdate();
  }

  function onBackgroundData(data) {
    gIsSleepTime = gSleepLayoutActive && data;
    Log.debug("sleepTime " + gIsSleepTime);
    WatchUi.requestUpdate();
  }

}