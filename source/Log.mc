using Toybox.System;
using Toybox.Application;

module Log {

  const _DEV_MODE = Application.getApp().getProperty("devMode");

  function debug(string) {
    if (_DEV_MODE) {
      System.println("debug :: " + string);
    }
  }
}