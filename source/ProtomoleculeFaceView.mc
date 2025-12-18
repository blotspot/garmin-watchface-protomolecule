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

  (:mipDisplay)
  protected var mDataFieldUpdateCounter = 0;

  function initialize() {
    _lastBIPModeState = Settings.burnInProtectionMode;
    _lastSleepLayoutState = Settings.useSleepTimeLayout();
    WatchFace.initialize();
  }

  function chooseLayout(dc, onLayoutCall) {
    if (onLayoutCall) {
      if (Log has :debug) {
        Log.debug("onLayoutCall");
      }
      return chooseLayoutByPriority(dc);
    }
    if (_lastBIPModeState != Settings.burnInProtectionMode) {
      if (Log has :debug) {
        Log.debug("enter / exit low power mode triggered");
      }
      _lastBIPModeState = Settings.burnInProtectionMode;
      return chooseLayoutByPriority(dc);
    }
    if (_lastSleepLayoutState != Settings.useSleepTimeLayout()) {
      if (Log has :debug) {
        Log.debug("sleep / wake time event triggered (and not in legacy BIP mode)");
      }
      _lastSleepLayoutState = Settings.useSleepTimeLayout();
      return chooseLayoutByPriority(dc);
    }
    if (_activeDefaultLayout != Properties.getValue("layout")) {
      if (Log has :debug) {
        Log.debug("layout switch triggered");
      }
      _activeDefaultLayout = Properties.getValue("layout") as Number;
      return chooseLayoutByPriority(dc);
    }
    return null;
  }

  protected function chooseLayoutByPriority(dc) {
    // Prio 1: Legacy BIP (pixes cycling)
    if (Settings.burnInProtectionMode && !Settings.HAS_DISPLAY_MODE) {
      if (Log has :debug) {
        Log.debug("set burn-in protection layout (AMOLEDs below API 5)");
      }
      _currentLayout = Rez.Layouts.BurnInProtectionLayout(dc);
    }
    // Prio 2: Sleep Time (when enabled in settings)
    else if (Settings.useSleepTimeLayout()) {
      if (Log has :debug) {
        Log.debug("set sleep time layout");
      }
      _currentLayout = Rez.Layouts.SleepLayout(dc);
    }
    // Prio 3: AMOLED Low Power Mode (<10% luminance)
    else if (Settings.burnInProtectionMode && Settings.HAS_DISPLAY_MODE) {
      if (Log has :debug) {
        Log.debug("set low power mode layout (AMOLEDs above API 5)");
      }
      _currentLayout = Rez.Layouts.LowPowerModeLayout(dc);
    }
    // DEFAULT: choose default layout
    else {
      if (Log has :debug) {
        Log.debug("set default layout");
      }
      _currentLayout = _activeDefaultLayout == Config.LAYOUT_ORBIT ? Rez.Layouts.OrbitLayout(dc) : Rez.Layouts.CirclesLayout(dc);
    }

    return _currentLayout;
  }

  // Load your resources here
  function onLayout(dc) {
    Settings.determineSleepTime();
    setLayout(chooseLayout(dc, true));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {
    if (Log has :debug) {
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
    if (Log has :debug) {
      Log.debug("onHide");
    }
    Settings.purge();
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
    if (requiresBurnInProtection()) {
      if (Log has :debug) {
        Log.debug("onExitSleep burnInProtectionMode");
      }
      Settings.burnInProtectionMode = false;
      WatchUi.requestUpdate();
    }
    if (Log has :debug) {
      Log.debug("onExitSleep lowPowerMode");
    }
    Settings.lowPowerMode = false;
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
    if (self has :mDataFieldUpdateCounter) {
      mDataFieldUpdateCounter = 0;
    }
    if (requiresBurnInProtection()) {
      if (Log has :debug) {
        Log.debug("onEnterSleep burnInProtectionMode");
      }
      Settings.burnInProtectionMode = true;
      WatchUi.requestUpdate();
    }
    if (Log has :debug) {
      Log.debug("onEnterSleep lowPowerMode");
    }
    Settings.lowPowerMode = true;
  }

  (:mipDisplay)
  function onPartialUpdate(dc) {
    if (!Settings.useSleepTimeLayout() && Properties.getValue("activeHeartrate")) {
      mDataFieldUpdateCounter += 1;
      mDataFieldUpdateCounter = mDataFieldUpdateCounter % 10;

      if (mDataFieldUpdateCounter == 0) {
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
  protected function requiresBurnInProtection() as Boolean {
    return _settings() has :requiresBurnInProtection && _settings().requiresBurnInProtection;
  }
}

import Toybox.Complications;

(:onPressComplication)
class ProtomoleculeFaceViewDelegate extends WatchUi.WatchFaceDelegate {
  private var _view as ProtomoleculeFaceView;

  function initialize(view as ProtomoleculeFaceView) {
    WatchFaceDelegate.initialize();
    _view = view;
  }

  function onPress(clickEvent as WatchUi.ClickEvent) as Boolean {
    if (!Settings.useSleepTimeLayout() && !Settings.lowPowerMode) {
      var coordinates = clickEvent.getCoordinates();
      var drawables = _view.getCurrentLayout();

      for (var i = 0; i < drawables.size(); i += 1) {
        var drawable = drawables[i];
        if (drawable instanceof DataFieldDrawable || drawable instanceof DateAndTime) {
          try {
            var complicationId = drawable.getComplicationForCoordinates(coordinates[0], coordinates[1]);
            if (complicationId != null) {
              startGlance(complicationId);
              return true;
            }
          } catch (error) {
            if (Log has :debug) {
              Log.debug("Could not handle onPress. Error: " + error.getErrorMessage());
            }
            return false;
          }
        }
      }
    }
    return false;
  }

  (:debug)
  private function startGlance(complicationId) {
    try {
      var c = Complications.getComplication(complicationId);
      Log.debug("Clicked complication: " + c.longLabel);
    } catch (e) {
      Log.debug("Eror on " + complicationId);
    }
  }

  (:release)
  private function startGlance(complicationId) {
    Complications.exitTo(complicationId);
  }
}
