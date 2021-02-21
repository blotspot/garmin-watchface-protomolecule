using Toybox.Application;
using Toybox.Background;
using Toybox.System;

(:background)
class SleepModeServiceDelegate extends System.ServiceDelegate {

  function initialize() {
    System.ServiceDelegate.initialize();
  }

  function onSleepTime() {
    Background.exit(true);
  }

  function onWakeTime() {
    Background.exit(false);
  }
}