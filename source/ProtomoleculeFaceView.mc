using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;

class ProtomoleculeFaceView extends Ui.WatchFace {

  var mEnterSleep = false;
  var mLastUpdateSleepTime = false; 
  hidden var mOuterRing;
  hidden var mUpperRing1;
  hidden var mUpperRing2;
  hidden var mLowerRing1;
  hidden var mLowerRing2;
  hidden var mNoProgress1;
  hidden var mNoProgress2;
  hidden var mNoProgress3;

  hidden var mActiveHeartrateField;
  hidden var mActiveHeartrateCounter = 0;

  hidden var mSettings;

  function initialize() {
    WatchFace.initialize();
  }

  // Load your resources here
  function onLayout(dc) {
    setLayout(Rez.Layouts.WatchFaceAlt(dc));
    getDrawableDataFields();
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {
  }

  // Update the view
  function onUpdate(dc) {
    clearClip(dc);
    // Call the parent onUpdate function to redraw the layout
    if (requiresBurnInProtection()) {
      setLayout((mEnterSleep) ? Rez.Layouts.SimpleWatchFace(dc) : Rez.Layouts.WatchFaceAlt(dc));
    } else {
      if (mLastUpdateSleepTime != Application.getApp().gIsSleepTime) {
        setLayout((Application.getApp().gIsSleepTime) ? Rez.Layouts.WatchFaceSleep(dc) : Rez.Layouts.WatchFaceAlt(dc));
        mLastUpdateSleepTime = Application.getApp().gIsSleepTime;
      }
    }

    if (Application.getApp().gActiveHeartrate) {
      if (Application.getApp().gNoProgressDataField1 == FieldType.HEART_RATE) {
        mActiveHeartrateField = mNoProgress1;
      } else if (Application.getApp().gNoProgressDataField2 == FieldType.HEART_RATE) {
        mActiveHeartrateField = mNoProgress2;
      } else if (Application.getApp().gNoProgressDataField3 == FieldType.HEART_RATE) {
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
  function onHide() {
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
    if (requiresBurnInProtection()) {
      mEnterSleep = false;
      WatchUi.requestUpdate();
    }
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
    if (requiresBurnInProtection()) {
      mEnterSleep = true;
      WatchUi.requestUpdate();
    }
  }

  // too expensive
  function onPartialUpdate(dc) {
    if (!Application.getApp().gIsSleepTime) {
      updateHeartrate(dc);
    }
  }

  function updateHeartrate(dc) {
    if (mActiveHeartrateField != null) {
      mActiveHeartrateCounter += 1; 
      if (mActiveHeartrateCounter % 10 == 0) {
        mActiveHeartrateField.draw(dc);
        mActiveHeartrateCounter = 0;
      }
    }
  }

  hidden function _settings() {
    if (mSettings == null) {
      mSettings = System.getDeviceSettings();
    }
    return mSettings;
  }

  hidden function requiresBurnInProtection() {
    return _settings() has :requiresBurnInProtection && _settings().requiresBurnInProtection;
  }

  hidden function getDrawableDataFields() {
    mOuterRing = findDrawableById("OuterDataField");
    mUpperRing1 = findDrawableById("UpperDataField1");
    mUpperRing2 = findDrawableById("UpperDataField2");
    mLowerRing1 = findDrawableById("LowerDataField1");
    mLowerRing2 = findDrawableById("LowerDataField2");
    mNoProgress1 = findDrawableById("NoProgressDataField1");
    mNoProgress2 = findDrawableById("NoProgressDataField2");
    mNoProgress3 = findDrawableById("NoProgressDataField3");
  }
}
