import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

class ProtomoleculeFaceView extends WatchUi.WatchFace {
  var mBurnInProtectionMode as Boolean = false;

  hidden var mLastBIPModeState as Boolean = false;
  hidden var mLastSleepTimeState as Boolean = false;
  hidden var mActiveDefaultLayout as Number;

  hidden var mNoProgress1;
  hidden var mNoProgress2;
  hidden var mNoProgress3;

  hidden var mActiveHeartrateField;
  hidden var noProgressFieldUpdateCounter = 0;

  hidden var mSettings;

  function initialize() {
    mActiveDefaultLayout = Settings.get("layout");
    WatchFace.initialize();
  }

  function chooseLayout(dc, onLayoutCall) {
    if (onLayoutCall) {
      Log.debug("onLayoutCall");
      return chooseLayoutByPriority(dc);
    }
    if (mLastBIPModeState != mBurnInProtectionMode) {
      Log.debug("enter / exit low power mode triggered");
      mLastBIPModeState = mBurnInProtectionMode;
      return chooseLayoutByPriority(dc);
    }
    if (mLastSleepTimeState != Settings.isSleepTimeLayout()) {
      Log.debug("sleep / wake time event triggered (and not in legacy BIP mode)");
      mLastSleepTimeState = Settings.isSleepTimeLayout();
      return chooseLayoutByPriority(dc);
    }
    if (mActiveDefaultLayout != Settings.get("layout")) {
      Log.debug("layout switch triggered");
      mActiveDefaultLayout = Settings.get("layout");
      return chooseLayoutByPriority(dc);
    }
    return null;
  }

  hidden function chooseLayoutByPriority(dc) {
    // Prio 1: Legacy BIP (pixes cycling)
    if (mBurnInProtectionMode && !displayModeAvailable()) {
      Log.debug("set burn-in protection layout (AMOLEDs below API 5)");
      return Rez.Layouts.BurnInProtectionLayout(dc);
    }
    // Prio 2: Sleep Time (when enabled in settings)
    if (Settings.isSleepTimeLayout()) {
      Log.debug("set sleep time layout");
      return Rez.Layouts.SleepLayout(dc);
    }
    // Prio 3: AMOLED Low Power Mode (<10% luminance)
    if (mBurnInProtectionMode && displayModeAvailable()) {
      Log.debug("set low power mode layout (AMOLEDs above API 5)");
      return Rez.Layouts.LowPowerModeLayout(dc);
    }
    // Finally: Choose default layout
    Log.debug("set default layout");
    return mActiveDefaultLayout == LayoutId.ORBIT ? Rez.Layouts.OrbitLayout(dc) : Rez.Layouts.CirclesLayout(dc);
  }

  // Load your resources here
  function onLayout(dc) {
    setLayout(chooseLayout(dc, true));
    getDrawableDataFields();
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {}

  // Update the view
  function onUpdate(dc) {
    saveClearClip(dc);
    // Call the parent onUpdate function to redraw the layout
    var layout = chooseLayout(dc, false);
    if (layout != null) {
      setLayout(layout);
    }

    if (Settings.get("activeHeartrate")) {
      if (Settings.get("middle1") == FieldType.HEART_RATE) {
        mActiveHeartrateField = mNoProgress1;
      } else if (Settings.get("middle2") == FieldType.HEART_RATE) {
        mActiveHeartrateField = mNoProgress2;
      } else if (Settings.get("middle3") == FieldType.HEART_RATE) {
        mActiveHeartrateField = mNoProgress3;
      } else {
        mActiveHeartrateField = null;
      }
    } else {
      mActiveHeartrateField = null;
    }

    View.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
    if (requiresBurnInProtection()) {
      mBurnInProtectionMode = false;
      WatchUi.requestUpdate();
    }
    Settings.lowPowerMode = false;
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
    if (requiresBurnInProtection()) {
      mBurnInProtectionMode = true;
      WatchUi.requestUpdate();
    }
    Settings.lowPowerMode = true;
  }

  function onPartialUpdate(dc) {
    if (!Settings.isSleepTime) {
      noProgressFieldUpdateCounter += 1;
      noProgressFieldUpdateCounter = noProgressFieldUpdateCounter % 10;
      if (noProgressFieldUpdateCounter == 0) {
        mNoProgress1.partialUpdate(dc);
        mNoProgress2.partialUpdate(dc);
        mNoProgress3.partialUpdate(dc);
      }
    }
    if (Settings.isSleepTime && noProgressFieldUpdateCounter != 0) {
      noProgressFieldUpdateCounter = 0;
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
