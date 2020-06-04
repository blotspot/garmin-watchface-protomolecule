using Toybox.Application;

const AMOLED_DISPLAY_SIZE = 390;

class ProtomoleculeFaceApp extends Application.AppBase {

  var gDevMode;
  var gIconSize;

  var gTheme;
  var gCaloriesGoal;
  var gDrawRemainingIndicator;
  var gPrimaryDataFieldBottom;
  var gPrimaryDataFieldRight;
  var gPrimaryDataFieldLeft;
  var gSecondaryDataField1;
  var gSecondaryDataField2;
  var gSecondaryDataField3;

  function initialize() {
    AppBase.initialize();
    loadProperties();
  }

  function loadProperties() {
    gIconSize = getProperty("iconSize");
    gDevMode = getProperty("devMode");
    loadConfigurableProperties();
  }

  function loadConfigurableProperties() {
    gTheme = getProperty("theme");
    gCaloriesGoal = getProperty("caloriesGoal");
    gDrawRemainingIndicator = getProperty("showRemainingIndicator");
    gPrimaryDataFieldBottom = getProperty("primaryDataFieldBottom");
    gPrimaryDataFieldRight = getProperty("primaryDataFieldRight");
    gPrimaryDataFieldLeft = getProperty("primaryDataFieldLeft");
    gSecondaryDataField1 = getProperty("secondaryDataField1");
    gSecondaryDataField2 = getProperty("secondaryDataField2");
    gSecondaryDataField3 = getProperty("secondaryDataField3");
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

  // New app settings have been received so trigger a UI update
  function onSettingsChanged() {
    loadConfigurableProperties();
    WatchUi.requestUpdate();
  }

}