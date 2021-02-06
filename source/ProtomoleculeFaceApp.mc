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
  var gPrimaryDataFieldBottom;
  var gPrimaryDataFieldRight;
  var gPrimaryDataFieldLeft;
  var gSecondaryDataField1;
  var gSecondaryDataField2;
  var gSecondaryDataField3;
  var gSimpleLayoutDataFieldLeft;
  var gSimpleLayoutDataFieldRight;

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
    gDrawRemainingIndicator = getProperty("showRemainingIndicator");
    gPrimaryDataFieldBottom = getProperty("primaryDataFieldBottom");
    gPrimaryDataFieldRight = getProperty("primaryDataFieldRight");
    gPrimaryDataFieldLeft = getProperty("primaryDataFieldLeft");
    gSecondaryDataField1 = getProperty("secondaryDataField1");
    gSecondaryDataField2 = getProperty("secondaryDataField2");
    gSecondaryDataField3 = getProperty("secondaryDataField3");
    gSimpleLayoutDataFieldLeft = getProperty("simpleDataFieldLeft");
    gSimpleLayoutDataFieldRight = getProperty("simpleDataFieldRight");
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