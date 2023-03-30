import Toybox.Application;
import Toybox.Background;
import Toybox.System;

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