using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class ProtomoleculeFaceView extends WatchUi.WatchFace {

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
    // Get and show the current time
    var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    var dateView = View.findDrawableById("Date");
    var hoursView = View.findDrawableById("Hours");
    var minutesView = View.findDrawableById("Minutes");
    
    dateView.setText(Lang.format("$1$, $2$ $3$", [now.day_of_week, now.month, now.day]));
    hoursView.setText(now.hour.format("%02d"));
    minutesView.setText(now.min.format("%02d"));

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
  }

}
