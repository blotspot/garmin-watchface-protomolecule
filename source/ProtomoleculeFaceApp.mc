using Toybox.Application;


const SCALE_STROKE_THICKNESS = 0.006;

class ProtomoleculeFaceApp extends Application.AppBase {

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