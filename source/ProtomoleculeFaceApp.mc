using Toybox.Application;

class ProtomoleculeFaceApp extends Application.AppBase {

  const gSecondaryDataFieldYPos = 0.74 * System.getDeviceSettings().screenHeight;
  const gSecondaryDataFieldXPos1 = 0.22 * System.getDeviceSettings().screenWidth;
  const gSecondaryDataFieldXPos2 = 0.50 * System.getDeviceSettings().screenWidth;
  const gSecondaryDataFieldXPos3 = 0.78 * System.getDeviceSettings().screenWidth;

  function initialize() {
    AppBase.initialize();
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