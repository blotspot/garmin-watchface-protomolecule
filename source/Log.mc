using Toybox.System;
using Toybox.Application;

(:debug) module Log {

  function debug(string) {
    if (Application.getApp().gDevMode) {
      System.println("debug :: " + string);
    }
  }
}