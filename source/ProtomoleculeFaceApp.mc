using Toybox.Application;


const PTS = 0.006;

class ProtomoleculeFaceApp extends Application.AppBase {

  const gSecondaryDataFieldYPos = 0.715 * System.getDeviceSettings().screenHeight;
  const gSecondaryDataFieldXPos1 = 0.168 * System.getDeviceSettings().screenWidth;
  const gSecondaryDataFieldXPos2 = 0.50 * System.getDeviceSettings().screenWidth;
  const gSecondaryDataFieldXPos3 = 0.832 * System.getDeviceSettings().screenWidth;
  
  var gIconSize;

  function initialize() {
    AppBase.initialize();
    gIconSize = getProperty("iconSize");
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

}