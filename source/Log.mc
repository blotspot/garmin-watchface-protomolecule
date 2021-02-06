using Toybox.System;
using Toybox.Application;

(:debug) module Log {

  function debug(string) {
    System.println("debug :: " + string);
  }
}