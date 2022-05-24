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
      getLayoutString(Settings.get("layout"))));
 
    Menu2.addItem(menuItem("layoutSettings", WatchUi.loadResource(Rez.Strings.SettingsLayoutSettingsTitle), null));

    Menu2.addItem(menuItem("theme", 
      WatchUi.loadResource(Rez.Strings.SettingsThemeTitle), 
      getThemeString(Settings.get("theme"))));

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
    var layoutId = Settings.get("layout");

    if (item.getId().equals("layoutSettings")) {             
      if (layoutId == LayoutId.ORBIT) {
        pushOrbitSubMenu(); return;
      } else {
        pushCirclesSubMenu(); return;
      }
    }
    if (item.getId().equals("layout")) {
      pushLayoutOptionsMenu(item); return;
    }
    if (item.getId().equals("theme")) {
      pushThemeOptionsMenu(item); return;
    }
    if ("middle1middle2middle3".find(item.getId()) != null) {
      pushClockDatafieldOptionsMenu(item); return;
    }
    if (layoutId == LayoutId.ORBIT && "outerupper1upper2".find(item.getId()) != null) {
      pushOrbitDatafieldOptionsMenu(item); return;
    }
    if (layoutId == LayoutId.CIRCLES && "lower1lower2upper1upper2".find(item.getId()) != null) {
      pushInnerCirclesDatafieldOptionsMenu(item); return;
    }
    if (layoutId == LayoutId.CIRCLES && "outer".equals(item.getId())) {
      pushOuterCirclesDatafieldOptionsMenu(item); return;
    }
    if (item instanceof ToggleMenuItem) {
      Log.debug("Toggle '" + item.getId() + "': " + item.isEnabled());
      Settings.set(item.getId(), item.isEnabled());
    }
  }

  hidden function pushThemeOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => WatchUi.loadResource(Rez.Strings.SettingsChooseThemeTitle) });
    menu.addItem(optionItem(getThemeString(0), 0));
    menu.addItem(optionItem(getThemeString(1), 1));
    menu.addItem(optionItem(getThemeString(2), 2));
    menu.addItem(optionItem(getThemeString(3), 3));
    
    WatchUi.pushView(menu, new OptionsItemDelegate(parent, false), WatchUi.SLIDE_LEFT);
  }

  hidden function pushLayoutOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => WatchUi.loadResource(Rez.Strings.SettingsChooseLayoutTitle) });
    menu.addItem(optionItem(getLayoutString(0), 0));
    menu.addItem(optionItem(getLayoutString(1), 1));
    
    WatchUi.pushView(menu, new OptionsItemDelegate(parent, false), WatchUi.SLIDE_LEFT);
  }

  hidden function pushOrbitDatafieldOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => parent.getLabel() });
    menu.addItem(optionItem(getDataFieldString(0), 0));
    menu.addItem(optionItem(getDataFieldString(1), 1));
    menu.addItem(optionItem(getDataFieldString(2), 2));
    menu.addItem(optionItem(getDataFieldString(3), 3));
    menu.addItem(optionItem(getDataFieldString(4), 4));
    menu.addItem(optionItem(getDataFieldString(7), 7));
    menu.addItem(optionItem(getDataFieldString(8), 8));

    WatchUi.pushView(menu, new OptionsItemDelegate(parent, true), WatchUi.SLIDE_LEFT);
  }
  
  hidden function pushInnerCirclesDatafieldOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => parent.getLabel() });
    menu.addItem(optionItem(getDataFieldString(0), 0));
    menu.addItem(optionItem(getDataFieldString(1), 1));
    menu.addItem(optionItem(getDataFieldString(2), 2));
    menu.addItem(optionItem(getDataFieldString(3), 3));
    menu.addItem(optionItem(getDataFieldString(4), 4));
    menu.addItem(optionItem(getDataFieldString(7), 7));
    menu.addItem(optionItem(getDataFieldString(8), 8));
    menu.addItem(optionItem(getDataFieldString(9), 9));

    WatchUi.pushView(menu, new OptionsItemDelegate(parent, true), WatchUi.SLIDE_LEFT);
  }
  
  hidden function pushOuterCirclesDatafieldOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => parent.getLabel() });
    menu.addItem(optionItem(getDataFieldString(0), 0));
    menu.addItem(optionItem(getDataFieldString(1), 1));
    menu.addItem(optionItem(getDataFieldString(2), 2));
    menu.addItem(optionItem(getDataFieldString(3), 3));

    WatchUi.pushView(menu, new OptionsItemDelegate(parent, true), WatchUi.SLIDE_LEFT);
  }
  
  hidden function pushClockDatafieldOptionsMenu(parent) {
    var menu = new WatchUi.Menu2({ :title => parent.getLabel() });
    menu.addItem(optionItem(getDataFieldString(0), 0));
    menu.addItem(optionItem(getDataFieldString(2), 2));
    menu.addItem(optionItem(getDataFieldString(4), 4));
    menu.addItem(optionItem(getDataFieldString(5), 5));
    menu.addItem(optionItem(getDataFieldString(6), 6));
    menu.addItem(optionItem(getDataFieldString(7), 7));
    menu.addItem(optionItem(getDataFieldString(8), 8));
    menu.addItem(optionItem(getDataFieldString(9), 9));
    menu.addItem(optionItem(getDataFieldString(10), 10));

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
      getDataFieldString(Settings.dataField("upper1"))));
    menu.addItem(menuItem("upper2", 
      WatchUi.loadResource(Rez.Strings.SettingsRightOrbitTitle), 
      getDataFieldString(Settings.dataField("upper2"))));
    menu.addItem(menuItem("outer", 
      WatchUi.loadResource(Rez.Strings.SettingsOuterOrbitTitle), 
      getDataFieldString(Settings.dataField("outer"))));
    menu.addItem(menuItem("middle1", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary1Title), 
      getDataFieldString(Settings.dataField("middle1"))));
    menu.addItem(menuItem("middle2", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary2Title), 
      getDataFieldString(Settings.dataField("middle2"))));
    menu.addItem(menuItem("middle3", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary3Title), 
      getDataFieldString(Settings.dataField("middle3"))));

    WatchUi.pushView(menu, new ProtomoleculeSettingsDelegate(), WatchUi.SLIDE_LEFT);
  }
  
  hidden function pushCirclesSubMenu() {
    var menu = new WatchUi.Menu2({ :title => WatchUi.loadResource(Rez.Strings.SettingsCirclesLayoutGroupTitle) });
    menu.addItem(menuItem("upper1", 
      WatchUi.loadResource(Rez.Strings.SettingsUpper1Title), 
      getDataFieldString(Settings.dataField("upper1"))));
    menu.addItem(menuItem("upper2", 
      WatchUi.loadResource(Rez.Strings.SettingsUpper2Title), 
      getDataFieldString(Settings.dataField("upper2"))));
    menu.addItem(menuItem("lower1", 
      WatchUi.loadResource(Rez.Strings.SettingsLower1Title), 
      getDataFieldString(Settings.dataField("lower1"))));
    menu.addItem(menuItem("lower2", 
      WatchUi.loadResource(Rez.Strings.SettingsLower2Title), 
      getDataFieldString(Settings.dataField("lower2"))));
    menu.addItem(menuItem("outer", 
      WatchUi.loadResource(Rez.Strings.SettingsOuterTitle), 
      getDataFieldString(Settings.dataField("outer"))));
    menu.addItem(menuItem("middle1", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary1Title), 
      getDataFieldString(Settings.dataField("middle1"))));
    menu.addItem(menuItem("middle2", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary2Title), 
      getDataFieldString(Settings.dataField("middle2"))));
    menu.addItem(menuItem("middle3", 
      WatchUi.loadResource(Rez.Strings.SettingsSecondary3Title), 
      getDataFieldString(Settings.dataField("middle3"))));
    
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

var _themeStrings = null;

function getThemeString(themeId) {
  if (_themeStrings == null) {
    _themeStrings = [
      WatchUi.loadResource(Rez.Strings.ThemeExpanse),
      WatchUi.loadResource(Rez.Strings.ThemeEarth),
      WatchUi.loadResource(Rez.Strings.ThemeMars),
      WatchUi.loadResource(Rez.Strings.ThemeBelt)
    ];
  }
  return _themeStrings[themeId];
}

var _layoutStrings = null;

function getLayoutString(layoutId) {
  if (_layoutStrings == null) {
    _layoutStrings = [
      WatchUi.loadResource(Rez.Strings.LayoutOrbitItem),
      WatchUi.loadResource(Rez.Strings.LayoutCirclesItem)
    ];
  }
  return _layoutStrings[layoutId];
}

var _dataFieldStrings = null;

function getDataFieldString(dfValue) {
  if (_dataFieldStrings == null) {
    _dataFieldStrings = [
      WatchUi.loadResource(Rez.Strings.NoDataField),
      WatchUi.loadResource(Rez.Strings.DataFieldSteps),
      WatchUi.loadResource(Rez.Strings.DataFieldBattery),
      WatchUi.loadResource(Rez.Strings.DataFieldCalories),
      WatchUi.loadResource(Rez.Strings.DataFieldActiveMinutes),
      WatchUi.loadResource(Rez.Strings.DataFieldHeartRate),
      WatchUi.loadResource(Rez.Strings.DataFieldMessages),
      WatchUi.loadResource(Rez.Strings.DataFieldFloorsUp),
      WatchUi.loadResource(Rez.Strings.DataFieldFloorsDown),
      WatchUi.loadResource(Rez.Strings.DataFieldBluetooth),
      WatchUi.loadResource(Rez.Strings.DataFieldAlarms)
    ];
  }
  return _dataFieldStrings[dfValue];
}