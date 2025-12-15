import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

class ProtomoleculeFaceView extends WatchUi.WatchFace {
  private var _lastBIPModeState as Boolean;
  private var _lastSleepLayoutState as Boolean;
  private var _activeDefaultLayout as Number?;

  private var _currentLayout as Array<WatchUi.Drawable>?;

  private var _dataFieldUpdateCounter = 0;

  function initialize() {
    _lastBIPModeState = Settings.burnInProtectionMode;
    _lastSleepLayoutState = Settings.useSleepTimeLayout();
    WatchFace.initialize();
  }

  function chooseLayout(dc, onLayoutCall) {
    if (onLayoutCall) {
      if (Log.isDebugEnabled) {
        Log.debug("onLayoutCall");
      }
      return chooseLayoutByPriority(dc);
    }
    if (_lastBIPModeState != Settings.burnInProtectionMode) {
      if (Log.isDebugEnabled) {
        Log.debug("enter / exit low power mode triggered");
      }
      _lastBIPModeState = Settings.burnInProtectionMode;
      return chooseLayoutByPriority(dc);
    }
    if (_lastSleepLayoutState != Settings.useSleepTimeLayout()) {
      if (Log.isDebugEnabled) {
        Log.debug("sleep / wake time event triggered (and not in legacy BIP mode)");
      }
      _lastSleepLayoutState = Settings.useSleepTimeLayout();
      return chooseLayoutByPriority(dc);
    }
    if (_activeDefaultLayout != Properties.getValue("layout")) {
      if (Log.isDebugEnabled) {
        Log.debug("layout switch triggered");
      }
      _activeDefaultLayout = Properties.getValue("layout") as Number;
      return chooseLayoutByPriority(dc);
    }
    return null;
  }

  hidden function chooseLayoutByPriority(dc) {
    var layout = null;
    // Prio 1: Legacy BIP (pixes cycling)
    if (Settings.burnInProtectionMode && !Settings.hasDisplayMode) {
      if (Log.isDebugEnabled) {
        Log.debug("set burn-in protection layout (AMOLEDs below API 5)");
      }
      layout = Rez.Layouts.BurnInProtectionLayout(dc);
    }
    // Prio 2: Sleep Time (when enabled in settings)
    if (Settings.useSleepTimeLayout()) {
      if (Log.isDebugEnabled) {
        Log.debug("set sleep time layout");
      }
      layout = Rez.Layouts.SleepLayout(dc);
    }
    // Prio 3: AMOLED Low Power Mode (<10% luminance)
    if (Settings.burnInProtectionMode && Settings.hasDisplayMode) {
      if (Log.isDebugEnabled) {
        Log.debug("set low power mode layout (AMOLEDs above API 5)");
      }
      layout = Rez.Layouts.LowPowerModeLayout(dc);
    }
    if (layout == null) {
      // If no special Layouts found, choose default layout
      if (Log.isDebugEnabled) {
        Log.debug("set default layout");
      }
      layout = _activeDefaultLayout == Enums.LAYOUT_ORBIT ? Rez.Layouts.OrbitLayout(dc) : Rez.Layouts.CirclesLayout(dc);
    }
    _currentLayout = layout;

    return _currentLayout;
  }

  // Load your resources here
  function onLayout(dc) {
    Settings.loadProperties();
    setLayout(chooseLayout(dc, true));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {
    if (Log.isDebugEnabled) {
      Log.debug("onShow");
    }
  }

  // Update the view
  function onUpdate(dc) {
    $.saveClearClip(dc);
    // Call the parent onUpdate function to redraw the layout
    var layout = chooseLayout(dc, false);
    if (layout != null) {
      setLayout(layout);
    }

    View.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {
    if (Log.isDebugEnabled) {
      Log.debug("onHide");
    }
    Settings.purge();
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
    if (requiresBurnInProtection()) {
      if (Log.isDebugEnabled) {
        Log.debug("onExitSleep burnInProtectionMode");
      }
      Settings.burnInProtectionMode = false;
      WatchUi.requestUpdate();
    }
    if (Log.isDebugEnabled) {
      Log.debug("onExitSleep lowPowerMode");
    }
    Settings.lowPowerMode = false;
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
    _dataFieldUpdateCounter = 0;
    if (requiresBurnInProtection()) {
      if (Log.isDebugEnabled) {
        Log.debug("onEnterSleep burnInProtectionMode");
      }
      Settings.burnInProtectionMode = true;
      WatchUi.requestUpdate();
    }
    if (Log.isDebugEnabled) {
      Log.debug("onEnterSleep lowPowerMode");
    }
    Settings.lowPowerMode = true;
  }

  function onPartialUpdate(dc) {
    if (!Settings.isSleepTime && Properties.getValue("activeHeartrate")) {
      _dataFieldUpdateCounter += 1;
      _dataFieldUpdateCounter = _dataFieldUpdateCounter % 10;

      if (_dataFieldUpdateCounter == 0) {
        for (var i = 0; i < _currentLayout.size(); i += 1) {
          var drawable = _currentLayout[i];
          if (drawable instanceof SecondaryDataField) {
            (drawable as SecondaryDataField).partialUpdate(dc);
          }
        }
      }
    }
  }

  function getCurrentLayout() as Array<WatchUi.Drawable> {
    return _currentLayout;
  }

  private var _deviceSettings;

  private function _settings() as DeviceSettings {
    if (_deviceSettings == null) {
      _deviceSettings = System.getDeviceSettings();
    }
    return _deviceSettings;
  }

  //! check if watch requires burn-in protection (AMOLED)
  hidden function requiresBurnInProtection() as Boolean {
    return _settings() has :requiresBurnInProtection && _settings().requiresBurnInProtection;
  }
}

import Toybox.Complications;

(:api420AndAbove)
class ProtomoleculeFaceViewDelegate extends WatchUi.WatchFaceDelegate {
  private var _view as ProtomoleculeFaceView;

  function initialize(view as ProtomoleculeFaceView) {
    WatchFaceDelegate.initialize();
    _view = view;
  }

  function onPress(clickEvent as WatchUi.ClickEvent) as Boolean {
    var coordinates = clickEvent.getCoordinates();
    var drawables = _view.getCurrentLayout();

    for (var i = 0; i < drawables.size(); i += 1) {
      var drawable = drawables[i];
      if (drawable instanceof DataFieldDrawable || drawable instanceof DateAndTime) {
        var complication = drawable.getComplicationForCoordinates(coordinates[0], coordinates[1]);
        if (complication != null) {
          Complications.exitTo(complication);
          return true;
        }
      }
    }
    return false;
  }
}
