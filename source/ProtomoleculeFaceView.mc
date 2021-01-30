using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;

class ProtomoleculeFaceView extends Ui.WatchFace {

  var mEnterSleep = false;

  function initialize() {
    WatchFace.initialize();
  }

  // Load your resources here
  function onLayout(dc) {
    setLayout(Rez.Layouts.WatchFace(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {
  }

  // Update the view
  function onUpdate(dc) {
    clearClip(dc);
    // Call the parent onUpdate function to redraw the layout
    if (requiresBurnInProtection()) {
      setLayout(mEnterSleep ? Rez.Layouts.SimpleWatchFace(dc) : Rez.Layouts.WatchFace(dc));
    }
    View.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
    if (requiresBurnInProtection()) {
      mEnterSleep = false;
      WatchUi.requestUpdate();
    }
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
    if (requiresBurnInProtection()) {
      mEnterSleep = true;
      WatchUi.requestUpdate();
    }
  }

  function requiresBurnInProtection() {
    var settings = System.getDeviceSettings();
    return settings has :requiresBurnInProtection && settings.requiresBurnInProtection;
  }

  // too expensive
  function onPartialUpdate(dc) {
    // View.onPartialUpdate(dc);
  }

}
