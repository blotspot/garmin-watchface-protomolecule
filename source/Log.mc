import Toybox.Lang;
import Toybox.System;
import Toybox.Application;

(:debug)
module Log {
  function isDebugEnabled() as Boolean {
    return true;
  }

  function debug(string) {
    System.println("debug :: " + string);
  }
}

(:release)
module Log {
  function isDebugEnabled() as Boolean {
    return false;
  }

  function debug(string) {}
}
