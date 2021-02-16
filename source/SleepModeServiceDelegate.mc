using Toybox.Application;
using Toybox.Background;
using Toybox.System;

(:background)
class SleepModeServiceDelegate extends System.ServiceDelegate {

  function initialize() {
    System.ServiceDelegate.initialize();
  }

  function onSleepTime() {
    System.println("sleep event triggered");
    Background.exit(true);
  }

  function onWakeTime() {
    System.println("wake event triggered");
    Background.exit(false);
  }
}