using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.Graphics;
using Toybox.System;

class ProtomoleculeSettingsMenu extends WatchUi.Menu2 {

  function initialize() {
    Menu2.initialize({:title => WatchUi.loadResource(Rez.Strings.SettingsMenuLabel)});
    
    Menu2.addItem(menuItem("layout", 
      WatchUi.loadResource(Rez.Strings.SettingsLayoutTitle), 
      getLayoutSubLabel()));
 
    Menu2.addItem(menuItem("layoutSettings", WatchUi.loadResource(Rez.Strings.SettingsLayoutSettingsTitle), null));

    Menu2.addItem(menuItem("theme", 
      WatchUi.loadResource(Rez.Strings.SettingsThemeTitle), 
      getThemeSubLabel()));

    Menu2.addItem(toggleItem("activeHeartrate", 
      WatchUi.loadResource(Rez.Strings.ToggleMenuActiveHeartrateLabel), 
      WatchUi.loadResource(Rez.Strings.ToggleMenuActiveHeartrateEnabled), 
      WatchUi.loadResource(Rez.Strings.ToggleMenuActiveHeartrateDisabled)));
    Menu2.addItem(toggleItem("showMeridiemText", 
      WatchUi.loadResource(Rez.Strings.ToggleMenuShowAmPmLabel), 
      WatchUi.loadResource(Rez.Strings.ToggleMenuEnabled), 
      WatchUi.loadResource(Rez.Strings.ToggleMenuDisabled)));
    Menu2.addItem(toggleItem("sleepLayoutActive", 
      WatchUi.loadResource(Rez.Strings.ToggleMenuSleepTimeLayoutLabel), 
      WatchUi.loadResource(Rez.Strings.ToggleMenuEnabled), 
      WatchUi.loadResource(Rez.Strings.ToggleMenuDisabled)));
    Menu2.addItem(toggleItem("useSystemFontForDate", 
      WatchUi.loadResource(Rez.Strings.ToggleMenuSystemFontLabel), 
      WatchUi.loadResource(Rez.Strings.ToggleMenuSystemFontEnabled), 
      WatchUi.loadResource(Rez.Strings.ToggleMenuSystemFontDisabled)));
  }
}

class ProtomoleculeSettingsDelegate extends WatchUi.Menu2InputDelegate {

  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    var layout = Settings.get("layout");
    Log.debug("item " + item.getId());
    if (item.getId().equals("layoutSettings")) {
      if (layout == LayoutId.ORBIT) {
        pushOrbitSubMenu(); return;
      } else {
        pushCirclesSubMenu(); return;
      }
    }
    if (item.getId().equals("layout")) {
      pushLayoutOptionsMenu(item);
      return;
    }
    if (item.getId().equals("theme")) {
      pushThemeOptionsMenu(item);
      return;
    }
    if ("middle1middle2middle3".find(item.getId()) != null) {
      pushClockDatafieldOptionsMenu(item); return;
    }
    if (layout == LayoutId.ORBIT && "outerupper1upper2".find(item.getId()) != null) {
      pushOrbitDatafieldOptionsMenu(item); return;
    }
    if (layout == LayoutId.CIRCLES && "lower1lower2upper1upper2".find(item.getId()) != null) {
      pushInnerCirclesDatafieldOptionsMenu(item); return;
    }
    if (layout == LayoutId.CIRCLES && "outer".equals(item.getId())) {
      pushOuterCirclesDatafieldOptionsMenu(item); return;
    }
    if (item instanceof ToggleMenuItem) {
      Log.debug("Toggle '" + item.getId() + "': " + item.isEnabled());
      Settings.set(item.getId(), item.isEnabled());
    }
  }

  hidden function pushThemeOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => WatchUi.loadResource(Rez.Strings.SettingsChooseThemeTitle) });
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.ThemeExpanse), 0));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.ThemeEarth), 1));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.ThemeMars), 2));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.ThemeBelt), 3));
    
    WatchUi.pushView(menu, new OptionsItemDelegate(parent, false), WatchUi.SLIDE_LEFT);
  }

  hidden function pushLayoutOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => WatchUi.loadResource(Rez.Strings.SettingsChooseLayoutTitle) });
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.LayoutOrbitItem), 0));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.LayoutCirclesItem), 1));
    
    WatchUi.pushView(menu, new OptionsItemDelegate(parent, false), WatchUi.SLIDE_LEFT);
  }

  hidden function pushOrbitDatafieldOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => parent.getLabel() });
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.NoDataField), 0));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldSteps), 1));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldBattery), 2));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldCalories), 3));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldActiveMinutes), 4));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldFloorsUp), 7));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldFloorsDown), 8));

    WatchUi.pushView(menu, new OptionsItemDelegate(parent, true), WatchUi.SLIDE_LEFT);
  }
  
  hidden function pushInnerCirclesDatafieldOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => parent.getLabel() });
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.NoDataField), 0));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldSteps), 1));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldBattery), 2));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldCalories), 3));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldActiveMinutes), 4));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldFloorsUp), 7));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldFloorsDown), 8));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldBluetooth), 9));

    WatchUi.pushView(menu, new OptionsItemDelegate(parent, true), WatchUi.SLIDE_LEFT);
  }
  
  hidden function pushOuterCirclesDatafieldOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => parent.getLabel() });
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.NoDataField), 0));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldSteps), 1));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldBattery), 2));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldCalories), 3));

    WatchUi.pushView(menu, new OptionsItemDelegate(parent, true), WatchUi.SLIDE_LEFT);
  }
  
  hidden function pushClockDatafieldOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => parent.getLabel() });
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.NoDataField), 0));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldBattery), 2));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldActiveMinutes), 4));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldHeartRate), 5));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldMessages), 6));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldFloorsUp), 7));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldFloorsDown), 8));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldBluetooth), 9));
    menu.addItem(optionItem(WatchUi.loadResource(Rez.Strings.DataFieldAlarms), 10));

    WatchUi.pushView(menu, new OptionsItemDelegate(parent, true), WatchUi.SLIDE_LEFT);
  }

  hidden function pushOrbitSubMenu() {
    var menu = new WatchUi.Menu2({ :title => WatchUi.loadResource(Rez.Strings.SettingsOrbitLayoutGroupTitle) });
    menu.addItem(toggleItem("showOrbitIndicatorText", 
      WatchUi.loadResource(Rez.Strings.ToggleMenuShowIndicatorTextLabel), 
      WatchUi.loadResource(Rez.Strings.ToggleMenuShowIndicatorTextEnabled), 
      WatchUi.loadResource(Rez.Strings.ToggleMenuShowIndicatorTextDisabled)));
    menu.addItem(menuItem("upper1", 
      WatchUi.loadResource(Rez.Strings.SettingsLeftOrbitTitle), 
      getDataFieldSubLabel("upper1")));
    menu.addItem(menuItem("upper2", 
      WatchUi.loadResource(Rez.Strings.SettingsRightOrbitTitle), 
      getDataFieldSubLabel("upper2")));
    menu.addItem(menuItem("outer", 
      WatchUi.loadResource(Rez.Strings.SettingsOuterOrbitTitle), 
      getDataFieldSubLabel("outer")));
    menu.addItem(menuItem("middle1", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary1Title), 
      getDataFieldSubLabel("middle1")));
    menu.addItem(menuItem("middle2", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary2Title), 
      getDataFieldSubLabel("middle2")));
    menu.addItem(menuItem("middle3", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary3Title), 
      getDataFieldSubLabel("middle3")));

    WatchUi.pushView(menu, new ProtomoleculeSettingsDelegate(), WatchUi.SLIDE_LEFT);
  }
  
  hidden function pushCirclesSubMenu() {
    var menu = new WatchUi.Menu2({ :title => WatchUi.loadResource(Rez.Strings.SettingsCirclesLayoutGroupTitle) });
    menu.addItem(menuItem("upper1", 
      WatchUi.loadResource(Rez.Strings.SettingsUpper1Title), 
      getDataFieldSubLabel("upper1")));
    menu.addItem(menuItem("upper2", 
      WatchUi.loadResource(Rez.Strings.SettingsUpper2Title), 
      getDataFieldSubLabel("upper2")));
    menu.addItem(menuItem("lower1", 
      WatchUi.loadResource(Rez.Strings.SettingsLower1Title), 
      getDataFieldSubLabel("lower1")));
    menu.addItem(menuItem("lower2", 
      WatchUi.loadResource(Rez.Strings.SettingsLower2Title), 
      getDataFieldSubLabel("lower2")));
    menu.addItem(menuItem("outer", 
      WatchUi.loadResource(Rez.Strings.SettingsOuterTitle), 
      getDataFieldSubLabel("outer")));
    menu.addItem(menuItem("middle1", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary1Title), 
      getDataFieldSubLabel("middle1")));
    menu.addItem(menuItem("middle2", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary2Title), 
      getDataFieldSubLabel("middle2")));
    menu.addItem(menuItem("middle3", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary3Title), 
      getDataFieldSubLabel("middle3")));
    
    WatchUi.pushView(menu, new ProtomoleculeSettingsDelegate(), WatchUi.SLIDE_LEFT);
  }


  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}

class OptionsItemDelegate extends WatchUi.Menu2InputDelegate {
  var mParentMenuItem;
  var mIsDataField;
  
  function initialize(parentMenuItem, isDataField) {
    Menu2InputDelegate.initialize();
    mParentMenuItem = parentMenuItem;
    mIsDataField = isDataField;
  }

  function onSelect(subMenuItem) {
    var parentId = mParentMenuItem.getId();
    var id = subMenuItem.getId();

    if (mIsDataField) {
      Settings.setDataField(parentId, id);
    } else {
      Settings.set(parentId, id);
    }
		mParentMenuItem.setSubLabel(subMenuItem.getLabel());

		WatchUi.popView(WatchUi.SLIDE_RIGHT);
	}
}

function toggleItem(id, label, enabledSubLabel, disabledSubLabel) {
  return new WatchUi.ToggleMenuItem(label, { :enabled => enabledSubLabel, :disabled => disabledSubLabel }, id, Settings.get(id), null);
}

function menuItem(id, label, subLabel) {
  return new WatchUi.MenuItem(label, subLabel, id, null);
}

function optionItem(label, value) {
  return new WatchUi.MenuItem(label, null, value, null);
}

function getThemeSubLabel() {
  var theme = Settings.get("theme");
  if (theme == 0) {
    return WatchUi.loadResource(Rez.Strings.ThemeExpanse);
  } else if (theme == 1) {
    return WatchUi.loadResource(Rez.Strings.ThemeEarth);
  } else if (theme == 2) {
    return WatchUi.loadResource(Rez.Strings.ThemeMars);
  } else {
    return WatchUi.loadResource(Rez.Strings.ThemeBelt);
  }
}

function getLayoutSubLabel() {
  var layout = Settings.get("layout");
  if (layout == LayoutId.ORBIT) {
    return WatchUi.loadResource(Rez.Strings.LayoutOrbitItem);
  } else {
    return WatchUi.loadResource(Rez.Strings.LayoutCirclesItem);
  }
}

function getDataFieldSubLabel(dfId) {
  var dfValue = Settings.dataField(dfId);
  if (dfValue == 0) {
    return WatchUi.loadResource(Rez.Strings.NoDataField);
  } else if (dfValue == 1) {
    return WatchUi.loadResource(Rez.Strings.DataFieldSteps);
  } else if (dfValue == 2) {
    return WatchUi.loadResource(Rez.Strings.DataFieldBattery);
  } else if (dfValue == 3) {
    return WatchUi.loadResource(Rez.Strings.DataFieldCalories);
  } else if (dfValue == 4) {
    return WatchUi.loadResource(Rez.Strings.DataFieldActiveMinutes);
  } else if (dfValue == 5) {
    return WatchUi.loadResource(Rez.Strings.DataFieldHeartRate);
  } else if (dfValue == 6) {
    return WatchUi.loadResource(Rez.Strings.DataFieldMessages);
  } else if (dfValue == 7) {
    return WatchUi.loadResource(Rez.Strings.DataFieldFloorsUp);
  } else if (dfValue == 8) {
    return WatchUi.loadResource(Rez.Strings.DataFieldFloorsDown);
  } else if (dfValue == 9) {
    return WatchUi.loadResource(Rez.Strings.DataFieldBluetooth);
  } else {
    return WatchUi.loadResource(Rez.Strings.DataFieldAlarms);
  }
}