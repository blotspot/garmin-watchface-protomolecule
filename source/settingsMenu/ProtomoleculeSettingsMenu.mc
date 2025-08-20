import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;

class ProtomoleculeSettingsMenu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({ :title => Settings.resource(Rez.Strings.SettingsMenuLabel) });

    Menu2.addItem(menuItem(0, Settings.resource(Rez.Strings.SettingsLayoutTitle), getLayoutString(Settings.get(0 /* layout */) as Number)));
    Menu2.addItem(menuItem(-1, Settings.resource(Rez.Strings.SettingsLayoutSettingsTitle), null));
    Menu2.addItem(menuItem(1, Settings.resource(Rez.Strings.SettingsThemeTitle), getThemeString(Settings.get(1 /* theme */) as Number)));

    Menu2.addItem(
      toggleItem(
        6,
        Settings.resource(Rez.Strings.ToggleMenuActiveHeartrateLabel),
        Settings.resource(Rez.Strings.ToggleMenuActiveHeartrateEnabled),
        Settings.resource(Rez.Strings.ToggleMenuActiveHeartrateDisabled)
      )
    );
    Menu2.addItem(toggleItem(11, Settings.resource(Rez.Strings.SettingsShowSecondsTitle), Settings.resource(Rez.Strings.ToggleMenuEnabled), Settings.resource(Rez.Strings.ToggleMenuDisabled)));
    Menu2.addItem(toggleItem(8, Settings.resource(Rez.Strings.ToggleMenuShowAmPmLabel), Settings.resource(Rez.Strings.ToggleMenuEnabled), Settings.resource(Rez.Strings.ToggleMenuDisabled)));
    Menu2.addItem(toggleItem(9, Settings.resource(Rez.Strings.ToggleMenuSleepTimeLayoutLabel), Settings.resource(Rez.Strings.ToggleMenuEnabled), Settings.resource(Rez.Strings.ToggleMenuDisabled)));
    Menu2.addItem(
      toggleItem(10, Settings.resource(Rez.Strings.ToggleMenuSystemFontLabel), Settings.resource(Rez.Strings.ToggleMenuSystemFontEnabled), Settings.resource(Rez.Strings.ToggleMenuSystemFontDisabled))
    );

    Menu2.addItem(menuItem(2, Settings.resource(Rez.Strings.SettingsCaloriesGoalTitle), Settings.get(2 /* caloriesGoal */).toString()));
    Menu2.addItem(menuItem(3, Settings.resource(Rez.Strings.SettingsBatteryThresholdTitle), Settings.get(3 /* batteryThreshold */).toString()));
    Menu2.addItem(toggleItem(5, Settings.resource(Rez.Strings.SettingsDynamicBodyBatteryTitle), Settings.resource(Rez.Strings.ToggleMenuEnabled), Settings.resource(Rez.Strings.ToggleMenuDisabled)));
    Menu2.addItem(menuItem(4, Settings.resource(Rez.Strings.SettingsBodyBatteryThresholdTitle), Settings.get(4 /* bodyBatteryThreshold */).toString()));
  }
}

class ProtomoleculeSettingsDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    var id = item.getId() as Number;

    if (-1 == id) {
      if (Settings.get(0 /* layout */) == 0) {
        pushOrbitSubMenu();
        return;
      } else {
        pushCirclesSubMenu();
        return;
      }
    }
    if (0 == id) {
      pushLayoutOptionsMenu(item);
      return;
    }
    if (1 == id) {
      pushThemeOptionsMenu(item);
      return;
    }
    if (12 == id || 13 == id || 14 == id) {
      pushClockDatafieldOptionsMenu(item);
      return;
    }
    if (15 == id || 16 == id || 17 == id) {
      pushOrbitDatafieldOptionsMenu(item);
      return;
    }
    if (18 == id) {
      pushOuterCirclesDatafieldOptionsMenu(item);
      return;
    }
    if (19 == id || 20 == id || 21 == id || 22 == id) {
      pushInnerCirclesDatafieldOptionsMenu(item);
      return;
    }
    if (2 == id) {
      pushCaloriesPicker(item);
      return;
    }
    if (3 == id) {
      pushBatteryPicker(item);
      return;
    }
    if (4 == id) {
      pushBodyBatteryPicker(item);
      return;
    }
    if (item instanceof ToggleMenuItem) {
      Settings.set(item.getId() as Number, (item as ToggleMenuItem).isEnabled());
    }
  }

  hidden function pushCaloriesPicker(parent as MenuItem) as Void {
    var holder = new NumberFactory(1500, 4000, 100, parent.getId() as Number, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushBatteryPicker(parent as MenuItem) as Void {
    var holder = new NumberFactory(10, 55, 5, parent.getId() as Number, { :suffix => "%" });
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushBodyBatteryPicker(parent as MenuItem) as Void {
    var holder = new NumberFactory(10, 60, 5, parent.getId() as Number, { :suffix => "%" });
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushThemeOptionsMenu(parent as MenuItem) as Void {
    var holder = new FixedValuesFactory([getThemeString(0), getThemeString(1), getThemeString(2), getThemeString(3)], parent.getId() as Number, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushLayoutOptionsMenu(parent as MenuItem) {
    var holder = new FixedValuesFactory([getLayoutString(0), getLayoutString(1)], parent.getId() as Number, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushOrbitDatafieldOptionsMenu(parent as MenuItem) as Void {
    var holder = new DataFieldFactory([0, 1, 2, 3, 4, 7, 8, 11, 13], parent.getId() as Number, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushInnerCirclesDatafieldOptionsMenu(parent as MenuItem) {
    var holder = new DataFieldFactory([0, 1, 2, 3, 4, 7, 8, 9, 11, 13], parent.getId() as Number, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushOuterCirclesDatafieldOptionsMenu(parent as MenuItem) {
    var holder = new DataFieldFactory([0, 1, 2, 3, 11], parent.getId() as Number, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushClockDatafieldOptionsMenu(parent as MenuItem) {
    var holder = new DataFieldFactory([0, 2, 4, 5, 6, 7, 8, 9, 10, 11, 13], parent.getId() as Number, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushOrbitSubMenu() {
    var menu = new WatchUi.Menu2({ :title => Settings.resource(Rez.Strings.SettingsOrbitLayoutGroupTitle) });
    menu.addItem(
      toggleItem(
        7,
        Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextLabel),
        Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextEnabled),
        Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextDisabled)
      )
    );
    menu.addItem(menuItem(16, Settings.resource(Rez.Strings.ODSettingsLeftOrbitTitle), getDataFieldString(Settings.get(16) as Number)));
    menu.addItem(menuItem(17, Settings.resource(Rez.Strings.ODSettingsRightOrbitTitle), getDataFieldString(Settings.get(17) as Number)));
    menu.addItem(menuItem(15, Settings.resource(Rez.Strings.ODSettingsOuterOrbitTitle), getDataFieldString(Settings.get(15) as Number)));
    menu.addItem(menuItem(12, Settings.resource(Rez.Strings.SettingsSecondary1Title), getDataFieldString(Settings.get(12) as Number)));
    menu.addItem(menuItem(13, Settings.resource(Rez.Strings.SettingsSecondary2Title), getDataFieldString(Settings.get(13) as Number)));
    menu.addItem(menuItem(14, Settings.resource(Rez.Strings.SettingsSecondary3Title), getDataFieldString(Settings.get(14) as Number)));

    WatchUi.pushView(menu, new ProtomoleculeSettingsDelegate(), WatchUi.SLIDE_LEFT);
  }

  hidden function pushCirclesSubMenu() {
    var menu = new WatchUi.Menu2({ :title => Settings.resource(Rez.Strings.SettingsCirclesLayoutGroupTitle) });
    menu.addItem(menuItem(19, Settings.resource(Rez.Strings.ODSettingsUpper1Title), getDataFieldString(Settings.get(19) as Number)));
    menu.addItem(menuItem(20, Settings.resource(Rez.Strings.ODSettingsUpper2Title), getDataFieldString(Settings.get(20) as Number)));
    menu.addItem(menuItem(21, Settings.resource(Rez.Strings.ODSettingsLower1Title), getDataFieldString(Settings.get(21) as Number)));
    menu.addItem(menuItem(22, Settings.resource(Rez.Strings.ODSettingsLower2Title), getDataFieldString(Settings.get(22) as Number)));
    menu.addItem(menuItem(18, Settings.resource(Rez.Strings.ODSettingsOuterTitle), getDataFieldString(Settings.get(18) as Number)));
    menu.addItem(menuItem(12, Settings.resource(Rez.Strings.SettingsSecondary1Title), getDataFieldString(Settings.get(12) as Number)));
    menu.addItem(menuItem(13, Settings.resource(Rez.Strings.SettingsSecondary2Title), getDataFieldString(Settings.get(13) as Number)));
    menu.addItem(menuItem(14, Settings.resource(Rez.Strings.SettingsSecondary3Title), getDataFieldString(Settings.get(14) as Number)));

    WatchUi.pushView(menu, new ProtomoleculeSettingsDelegate(), WatchUi.SLIDE_LEFT);
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}

function toggleItem(id as Number, label as String, enabledSubLabel as String, disabledSubLabel as String) {
  return new WatchUi.ToggleMenuItem(label, { :enabled => enabledSubLabel, :disabled => disabledSubLabel }, id, Settings.get(id), null);
}

function menuItem(id as Number, label as String, subLabel as String?) {
  return new WatchUi.MenuItem(label, subLabel, id, null);
}

function getThemeString(themeId as Number) {
  var _theme = [Rez.Strings.ThemeExpanse, Rez.Strings.ThemeEarth, Rez.Strings.ThemeMars, Rez.Strings.ThemeBelt];
  return Settings.resource(_theme[themeId]);
}

function getLayoutString(layoutId as Number) {
  var _layout = [Rez.Strings.LayoutOrbitItem, Rez.Strings.LayoutCirclesItem];
  return Settings.resource(_layout[layoutId]);
}

function getDataFieldString(dfId as Number) {
  var DataFieldRez = [
    /*  0 */ Rez.Strings.NoDataField,
    /*  1 */ Rez.Strings.DataFieldSteps,
    /*  2 */ Rez.Strings.DataFieldBattery,
    /*  3 */ Rez.Strings.DataFieldCalories,
    /*  4 */ Rez.Strings.DataFieldActiveMinutes,
    /*  5 */ Rez.Strings.DataFieldHeartRate,
    /*  6 */ Rez.Strings.DataFieldMessages,
    /*  7 */ Rez.Strings.DataFieldFloorsUp,
    /*  8 */ Rez.Strings.DataFieldFloorsDown,
    /*  9 */ Rez.Strings.DataFieldBluetooth,
    /* 10 */ Rez.Strings.DataFieldAlarms,
    /* 11 */ Rez.Strings.DataFieldBodyBattery,
    /* 12 */ Rez.Strings.DataFieldSeconds,
    /* 13 */ Rez.Strings.DataFieldStressLevel,
  ];
  return Settings.resource(DataFieldRez[dfId]);
}
