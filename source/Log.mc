import Toybox.System;
import Toybox.Application;

(:debug)
module Log {
  function debug(string) {
    System.println("debug :: " + string);
  }
}

(:release)
module Log {
  function debug(string) {}
}
