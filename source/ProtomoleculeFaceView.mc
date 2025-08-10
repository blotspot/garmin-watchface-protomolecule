import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

class ProtomoleculeFaceView extends WatchUi.WatchFace {
  var mBurnInProtectionMode as Boolean = false;
  var mLastUpdateBIPModeState as Boolean = false;
  var mLastUpdateSleepTimeState as Boolean = false;
  hidden var mLastLayout;

  hidden var mNoProgress1;
  hidden var mNoProgress2;
  hidden var mNoProgress3;

  hidden var mActiveHeartrateField;
  hidden var mActiveHeartrateCounter = 0;

  hidden var mSettings;

  function initialize() {
    WatchFace.initialize();
  }

  function chooseLayout(dc, onLayoutCall) {
    if (onLayoutCall) {
      Log.debug("onLayoutCall");
      return chooseLayoutByPriority(dc);
    }
    if (requiresBurnInProtection() && mLastUpdateBIPModeState != mBurnInProtectionMode) {
      Log.debug("enter / exit low power mode triggered");
      mLastUpdateBIPModeState = mBurnInProtectionMode;
      return chooseLayoutByPriority(dc);
    }
    if ((!mBurnInProtectionMode || (mBurnInProtectionMode && displayModeAvailable())) && mLastUpdateSleepTimeState != Settings.isSleepTime) {
      Log.debug("sleep / wake time event triggered (and not in legacy BIP mode)");
      mLastUpdateSleepTimeState = Settings.isSleepTime;
      return chooseLayoutByPriority(dc);
    }
    if (!mBurnInProtectionMode && !Settings.isSleepTime && mLastLayout != Settings.get("layout")) {
      Log.debug("layout switch triggered");
      mLastLayout = Settings.get("layout");
      return chooseLayoutByPriority(dc);
    }
    return null;
  }

  hidden function chooseLayoutByPriority(dc) {
    // Prio 1: Legacy BIP (pixes cycling)
    if (mBurnInProtectionMode && !displayModeAvailable()) {
      Log.debug("set burn-in protection layout (AMOLEDs below API 5)");
      mLastUpdateBIPModeState = mBurnInProtectionMode;
      return Rez.Layouts.BurnInProtectionLayout(dc);
    }
    // Prio 2: Sleep Time (when enabled in settings)
    if (Settings.isSleepTime) {
      Log.debug("set sleep time layout");
      mLastUpdateSleepTimeState = Settings.isSleepTime;
      return Rez.Layouts.SleepLayout(dc);
    }
    // Prio 3: AMOLED Low Power Mode (<10% luminance)
    if (mBurnInProtectionMode && displayModeAvailable()) {
      Log.debug("set low power mode layout (AMOLEDs above API 5)");
      return Rez.Layouts.LowPowerModeLayout(dc);
    }
    // Finally: Choose default layout
    Log.debug("set default layout");
    return defaultLayout(dc);
  }

  hidden function defaultLayout(dc) {
    mLastLayout = Settings.get("layout");
    return mLastLayout == LayoutId.ORBIT ? Rez.Layouts.OrbitLayout(dc) : Rez.Layouts.CirclesLayout(dc);
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
    if (!mLastUpdateSleepTimeState) {
      updateHeartrate(dc);
    }
  }

  function updateHeartrate(dc) {
    if (mActiveHeartrateField != null) {
      mActiveHeartrateCounter += 1;
      if (mActiveHeartrateCounter % 10 == 0) {
        mActiveHeartrateField.partialUpdate(dc);
        mActiveHeartrateCounter = 0;
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
