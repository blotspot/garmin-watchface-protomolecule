using Toybox.Application.Properties;
using Toybox.Math;
using Toybox.System;
using Toybox.WatchUi;

module Settings {
  function get(key) {
    return _settings[key];
  }

  function dataField(symbol) {
    return _dataField[symbol];
  }

  function iconFont() {
    if (_font[:icons] == null) {
      _font[:icons] = WatchUi.loadResource(Rez.Fonts.IconsFont);
    }

    return _font[:icons];
  }

  function textFont() {
    if (_font[:text] == null) {
      _font[:text] = WatchUi.loadResource(Rez.Fonts.SecondaryIndicatorFont);
    }

    return _font[:text];
  }

  function initSettings() {
    var width = System.getDeviceSettings().screenWidth;
    var height = System.getDeviceSettings().screenHeight;
    
    _settings[:iconSize] = Math.round((width + height) / 2 / 12.4);
    _settings[:strokeWidth] = Math.round((width + height) / 2 / 100);
    _settings[:centerXPos] = width / 2.0;
    _settings[:centerYPos] = height / 2.0;
    
    loadProperties();
  }

  function loadProperties() {
    _settings[:layout] = Properties.getValue("layout");
    _settings[:theme] = Properties.getValue("theme");
    _settings[:caloriesGoal] = Properties.getValue("caloriesGoal");
    _settings[:batteryThreshold] = Properties.getValue("batteryThreshold");
    _settings[:activeHeartrate] = Properties.getValue("activeHeartrate");
    _settings[:showOrbitIndicatorText] = Properties.getValue("showOrbitIndicatorText");
    _settings[:showMeridiemText] = Properties.getValue("showMeridiemText");
    _settings[:sleepLayoutActive] = Properties.getValue("sleepTimeLayout");
    _settings[:useSystemFontForDate] = Properties.getValue("useSystemFontForDate");
    
    _dataField[:middle1] = Properties.getValue("noProgressDataField1");
    _dataField[:middle2] = Properties.getValue("noProgressDataField2");
    _dataField[:middle3] = Properties.getValue("noProgressDataField3");
    _dataField[:outer] = (_settings[:layout] == 0) ? Properties.getValue("outerOrbitDataField") : Properties.getValue("outerDataField");
    _dataField[:upper1] = (_settings[:layout] == 0) ? Properties.getValue("leftOrbitDataField") : Properties.getValue("upperDataField1");
    _dataField[:upper2] = (_settings[:layout] == 0) ? Properties.getValue("rightOrbitDataField") : Properties.getValue("upperDataField2");
    _dataField[:lower1] = (_settings[:layout] == 0) ? null : Properties.getValue("lowerDataField1");
    _dataField[:lower2] = (_settings[:layout] == 0) ? null : Properties.getValue("lowerDataField2");
  }

  var isSleepTime = false;

  var _dataField = {
    :middle1 => null, 
    :middle2 => null,
    :middle3 => null,
    :outer => null,
    :upper1 => null,
    :upper2 => null,
    :lower1 => null,
    :lower2 => null
  };

  var _settings = {
    :iconSize => null,
    :strokeWidth => null,
    :centerXPos => null,
    :centerYPos => null,
    :layout => null,
    :theme => null,
    :caloriesGoal => 0,
    :batteryThreshold => 0,
    :activeHeartrate => false,
    :showOrbitIndicatorText => false,
    :showMeridiemText => false,
    :sleepLayoutActive => false,
    :useSystemFontForDate => false
  };

  var _font = {
    :icons => null,
    :text => null
  };
}