using Toybox.System;
using Toybox.Application;

module Log {

  function debug(string) {
    if (Application.getApp().gDevMode) {
      System.println("debug :: " + string);
    }
  }
}