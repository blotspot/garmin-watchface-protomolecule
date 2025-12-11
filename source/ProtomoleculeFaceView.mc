import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

class ProtomoleculeFaceView extends WatchUi.WatchFace {
  hidden var mLastBIPModeState as Boolean;
  hidden var mLastSleepLayoutState as Boolean;
  hidden var mActiveDefaultLayout as Number?;

  hidden var mNoProgress1 as SecondaryDataField?;
  hidden var mNoProgress2 as SecondaryDataField?;
  hidden var mNoProgress3 as SecondaryDataField?;

  hidden var mDataFieldUpdateCounter = 0;

  hidden var mSettings;

  function initialize() {
    mLastBIPModeState = Settings.burnInProtectionMode;
    mLastSleepLayoutState = Settings.useSleepTimeLayout();
    WatchFace.initialize();
  }

  function chooseLayout(dc, onLayoutCall) {
    if (onLayoutCall) {
      Log.debug("onLayoutCall");
      return chooseLayoutByPriority(dc);
    }
    if (mLastBIPModeState != Settings.burnInProtectionMode) {
      Log.debug("enter / exit low power mode triggered");
      mLastBIPModeState = Settings.burnInProtectionMode;
      return chooseLayoutByPriority(dc);
    }
    if (mLastSleepLayoutState != Settings.useSleepTimeLayout()) {
      Log.debug("sleep / wake time event triggered (and not in legacy BIP mode)");
      mLastSleepLayoutState = Settings.useSleepTimeLayout();
      return chooseLayoutByPriority(dc);
    }
    if (mActiveDefaultLayout != Properties.getValue("layout")) {
      Log.debug("layout switch triggered");
      mActiveDefaultLayout = Properties.getValue("layout") as Number;
      return chooseLayoutByPriority(dc);
    }
    return null;
  }

  hidden function chooseLayoutByPriority(dc) {
    // Prio 1: Legacy BIP (pixes cycling)
    if (Settings.burnInProtectionMode && !Settings.hasDisplayMode) {
      Log.debug("set burn-in protection layout (AMOLEDs below API 5)");
      return Rez.Layouts.BurnInProtectionLayout(dc);
    }
    // Prio 2: Sleep Time (when enabled in settings)
    if (Settings.useSleepTimeLayout()) {
      Log.debug("set sleep time layout");
      return Rez.Layouts.SleepLayout(dc);
    }
    // Prio 3: AMOLED Low Power Mode (<10% luminance)
    if (Settings.burnInProtectionMode && Settings.hasDisplayMode) {
      Log.debug("set low power mode layout (AMOLEDs above API 5)");
      return Rez.Layouts.LowPowerModeLayout(dc);
    }
    // Finally: Choose default layout
    Log.debug("set default layout");
    return mActiveDefaultLayout == 0 ? Rez.Layouts.OrbitLayout(dc) : Rez.Layouts.CirclesLayout(dc);
  }

  // Load your resources here
  function onLayout(dc) {
    Settings.loadProperties();
    setLayout(chooseLayout(dc, true));
    getDrawableDataFields();
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {
    Log.debug("onShow");
    Settings.purge();
  }

  // Update the view
  function onUpdate(dc) {
    saveClearClip(dc);
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
    Log.debug("onHide");
    Settings.purge();
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
    if (requiresBurnInProtection()) {
      Log.debug("onExitSleep burnInProtectionMode");
      Settings.burnInProtectionMode = false;
      WatchUi.requestUpdate();
    }
    Log.debug("onExitSleep lowPowerMode");
    Settings.lowPowerMode = false;
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
    mDataFieldUpdateCounter = 0;
    if (requiresBurnInProtection()) {
      Log.debug("onEnterSleep burnInProtectionMode");
      Settings.burnInProtectionMode = true;
      WatchUi.requestUpdate();
    }
    Log.debug("onEnterSleep lowPowerMode");
    Settings.lowPowerMode = true;
  }

  function onPartialUpdate(dc) {
    if (!Settings.isSleepTime && Properties.getValue("activeHeartrate")) {
      mDataFieldUpdateCounter += 1;
      mDataFieldUpdateCounter = mDataFieldUpdateCounter % 10;
      if (mDataFieldUpdateCounter == 0) {
        if (mNoProgress1 != null) {
          mNoProgress1.partialUpdate(dc);
        }
        if (mNoProgress2 != null) {
          mNoProgress2.partialUpdate(dc);
        }
        if (mNoProgress3 != null) {
          mNoProgress3.partialUpdate(dc);
        }
      }
    }
  }

  hidden function _settings() as DeviceSettings {
    if (mSettings == null) {
      mSettings = System.getDeviceSettings();
    }
    return mSettings;
  }

  hidden function displayModeAvailable() as Boolean {
    return System has :getDisplayMode;
  }

  //! check if watch requires burn-in protection (AMOLED)
  hidden function requiresBurnInProtection() as Boolean {
    return _settings() has :requiresBurnInProtection && _settings().requiresBurnInProtection;
  }

  hidden function getDrawableDataFields() {
    mNoProgress1 = findDrawableById("NoProgressDataField1");
    mNoProgress2 = findDrawableById("NoProgressDataField2");
    mNoProgress3 = findDrawableById("NoProgressDataField3");
  }
}
