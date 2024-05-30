import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Graphics;

class OptionsItem extends WatchUi.Button {
  hidden var mLabel = "";

  function initialize(params) {
    Button.initialize(params);
  }

  function draw(dc) {
    var x = Settings.get("centerXPos");
    var y = locY + height / 2.0;
    dc.setColor(isCurrent() ? themeColor(Color.TEXT_ACTIVE) : themeColor(Color.TEXT_INACTIVE), Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y, isCurrent() ? Graphics.FONT_MEDIUM : Graphics.FONT_SMALL, mLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    if (isPrevious()) {
      dc.setColor(themeColor(Color.TEXT_INACTIVE), Graphics.COLOR_TRANSPARENT);
      dc.fillRectangle(locX, locY, width, 1);
    }
  }

  function setLabel(label) {
    mLabel = label;
  }

  function getLabel() {
    return mLabel;
  }

  hidden function isCurrent() {
    return identifier.equals("CurrentItem");
  }

  hidden function isPrevious() {
    return identifier.equals("PreviousItem");
  }

  hidden function isNext() {
    return identifier.equals("NextItem");
  }
}

class OptionsMenu extends WatchUi.View {
  hidden var mValueHolder;

  hidden var mTitle;
  hidden var mTitleTextArea;
  hidden var mPreviousItem;
  hidden var mCurrentItem;
  hidden var mNextItem;

  (:typecheck(false))
  function initialize(valueHolder, options) {
    View.initialize();
    mValueHolder = valueHolder;
    if (options == null) {
      options = {};
    }
    mTitle = options.hasKey(:title) ? options[:title] : "";
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.OptionsMenu(dc));
    initDrawables();
    setLabelsBasedOnSelectedId();
  }

  function onUpdate(dc) {
    clearClip(dc);
    mTitleTextArea.setText(mTitle);
    setLabelsBasedOnSelectedId();
    View.onUpdate(dc);
  }

  hidden function setLabelsBasedOnSelectedId() {
    mCurrentItem.setLabel(mValueHolder.getLabelRelativeToSelection(0));
    mPreviousItem.setLabel(mValueHolder.getLabelRelativeToSelection(-1));
    mNextItem.setLabel(mValueHolder.getLabelRelativeToSelection(1));
  }

  hidden function initDrawables() {
    mTitleTextArea = findDrawableById("Title");
    mPreviousItem = findDrawableById("PreviousItem");
    mCurrentItem = findDrawableById("CurrentItem");
    mNextItem = findDrawableById("NextItem");
  }
}

class OptionsMenuDelegate extends WatchUi.BehaviorDelegate {
  hidden var mValueHolder;
  hidden var mParentMenuItem;

  function initialize(valueHolder, parentMenuItem) {
    BehaviorDelegate.initialize();
    mValueHolder = valueHolder;
    mParentMenuItem = parentMenuItem;
  }

  function onMenu() {
    return false;
  }

  function onNextMode() {
    return onNextPage();
  }

  function onNextPage() {
    mValueHolder.incrementSelection();
    WatchUi.requestUpdate();
    return true;
  }

  function onPreviousMode() {
    return onPreviousPage();
  }

  function onPreviousPage() {
    mValueHolder.decrementSelection();
    WatchUi.requestUpdate();
    return true;
  }

  function onSelect() {
    mValueHolder.saveSelection();
    mParentMenuItem.setSubLabel(mValueHolder.getLabelRelativeToSelection(0));
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    return true;
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    return true;
  }
}
