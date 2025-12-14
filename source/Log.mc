import Toybox.Lang;
import Toybox.System;
import Toybox.Application;

(:debug)
module Log {
  const isDebugEnabled as Boolean = true;

  function debug(string) {
    System.println("debug :: " + string);
  }
}

(:release)
module Log {
  const isDebugEnabled as Boolean = false;

  function debug(string) {}
}
