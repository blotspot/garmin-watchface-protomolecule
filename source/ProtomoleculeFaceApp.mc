using Toybox.Application;
using Toybox.Math;
using Toybox.System;

class ProtomoleculeFaceApp extends Application.AppBase {

  var gIconSize;
  var gStrokeWidth;

  var gTheme;
  var gCaloriesGoal;
  var gBatteryThreshold;
  var gDrawRemainingIndicator;
  var gNoProgressDataField1;
  var gNoProgressDataField2;
  var gNoProgressDataField3;
  var gOuterDataField;
  var gUpperDataField1;
  var gUpperDataField2;
  var gLowerDataField1;
  var gLowerDataField2;

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

  function loadConfigurableProperties() {
    gTheme = getProperty("theme");
    gCaloriesGoal = getProperty("caloriesGoal");
    gBatteryThreshold = getProperty("batteryThreshold");
    gNoProgressDataField1 = getProperty("noProgressDataField1");
    gNoProgressDataField2 = getProperty("noProgressDataField2");
    gNoProgressDataField3 = getProperty("noProgressDataField3");
    gOuterDataField = getProperty("outerDataField");
    gUpperDataField1 = getProperty("upperDataField1");
    gUpperDataField2 = getProperty("upperDataField2");
    gLowerDataField1 = getProperty("lowerDataField1");
    gLowerDataField2 = getProperty("lowerDataField2");
  }

  // onStart() is called on application start up
  function onStart(state) {
  }

  // onStop() is called when your application is exiting
  function onStop(state) {
  }

  // Return the initial view of your application here
  function getInitialView() {
    return [ new ProtomoleculeFaceView() ];
  }

  // function getSettingsView() {
  //   return [ new ProtomoleculeSettingsView() ]
  // }

  // New app settings have been received so trigger a UI update
  function onSettingsChanged() {
    loadConfigurableProperties();
    WatchUi.requestUpdate();
  }

}