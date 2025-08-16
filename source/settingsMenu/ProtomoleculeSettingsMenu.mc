import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;

class ProtomoleculeSettingsMenu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({ :title => Settings.resource(Rez.Strings.SettingsMenuLabel) });

    Menu2.addItem(menuItem("layout", Settings.resource(Rez.Strings.SettingsLayoutTitle), getLayoutString(Settings.get("layout"))));
    Menu2.addItem(menuItem("layoutSettings", Settings.resource(Rez.Strings.SettingsLayoutSettingsTitle), null));
    Menu2.addItem(menuItem("theme", Settings.resource(Rez.Strings.SettingsThemeTitle), getThemeString(Settings.get("theme"))));

    Menu2.addItem(
      toggleItem(
        "activeHeartrate",
        Settings.resource(Rez.Strings.ToggleMenuActiveHeartrateLabel),
        Settings.resource(Rez.Strings.ToggleMenuActiveHeartrateEnabled),
        Settings.resource(Rez.Strings.ToggleMenuActiveHeartrateDisabled)
      )
    );
    Menu2.addItem(
      toggleItem("showSeconds", Settings.resource(Rez.Strings.SettingsShowSecondsTitle), Settings.resource(Rez.Strings.ToggleMenuEnabled), Settings.resource(Rez.Strings.ToggleMenuDisabled))
    );
    Menu2.addItem(
      toggleItem("showMeridiemText", Settings.resource(Rez.Strings.ToggleMenuShowAmPmLabel), Settings.resource(Rez.Strings.ToggleMenuEnabled), Settings.resource(Rez.Strings.ToggleMenuDisabled))
    );
    Menu2.addItem(
      toggleItem(
        "sleepLayoutActive",
        Settings.resource(Rez.Strings.ToggleMenuSleepTimeLayoutLabel),
        Settings.resource(Rez.Strings.ToggleMenuEnabled),
        Settings.resource(Rez.Strings.ToggleMenuDisabled)
      )
    );
    Menu2.addItem(
      toggleItem(
        "useSystemFontForDate",
        Settings.resource(Rez.Strings.ToggleMenuSystemFontLabel),
        Settings.resource(Rez.Strings.ToggleMenuSystemFontEnabled),
        Settings.resource(Rez.Strings.ToggleMenuSystemFontDisabled)
      )
    );

    Menu2.addItem(menuItem("caloriesGoal", Settings.resource(Rez.Strings.SettingsCaloriesGoalTitle), Settings.get("caloriesGoal").toString()));
    Menu2.addItem(menuItem("batteryThreshold", Settings.resource(Rez.Strings.SettingsBatteryThresholdTitle), Settings.get("batteryThreshold").toString()));
    Menu2.addItem(
      toggleItem(
        "dynamicBodyBattery",
        Settings.resource(Rez.Strings.SettingsDynamicBodyBatteryTitle),
        Settings.resource(Rez.Strings.ToggleMenuEnabled),
        Settings.resource(Rez.Strings.ToggleMenuDisabled)
      )
    );
    Menu2.addItem(menuItem("bodyBatteryThreshold", Settings.resource(Rez.Strings.SettingsBodyBatteryThresholdTitle), Settings.get("bodyBatteryThreshold").toString()));
  }
}

class ProtomoleculeSettingsDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    var layoutId = Settings.get("layout");

    if ("layoutSettings".equals(item.getId())) {
      if (layoutId == LayoutId.ORBIT) {
        pushOrbitSubMenu();
        return;
      } else {
        pushCirclesSubMenu();
        return;
      }
    }
    if ("layout".equals(item.getId())) {
      pushLayoutOptionsMenu(item);
      return;
    }
    if ("theme".equals(item.getId())) {
      pushThemeOptionsMenu(item);
      return;
    }
    if ("middle1middle2middle3".find(item.getId() as String) != null) {
      pushClockDatafieldOptionsMenu(item);
      return;
    }
    if (layoutId == LayoutId.ORBIT && "outerupper1upper2".find(item.getId() as String) != null) {
      pushOrbitDatafieldOptionsMenu(item);
      return;
    }
    if (layoutId == LayoutId.CIRCLES && "lower1lower2upper1upper2".find(item.getId() as String) != null) {
      pushInnerCirclesDatafieldOptionsMenu(item);
      return;
    }
    if (layoutId == LayoutId.CIRCLES && "outer".equals(item.getId())) {
      pushOuterCirclesDatafieldOptionsMenu(item);
      return;
    }
    if ("caloriesGoal".equals(item.getId())) {
      pushCaloriesPicker(item);
      return;
    }
    if ("batteryThreshold".equals(item.getId())) {
      pushBatteryPicker(item);
      return;
    }
    if ("bodyBatteryThreshold".equals(item.getId())) {
      pushBodyBatteryPicker(item);
      return;
    }
    if (item instanceof ToggleMenuItem) {
      Settings.set(item.getId() as String, (item as ToggleMenuItem).isEnabled());
    }
  }

  hidden function pushCaloriesPicker(parent as MenuItem) as Void {
    var holder = new NumberFactory(1500, 4000, 100, parent.getId() as String, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushBatteryPicker(parent as MenuItem) as Void {
    var holder = new NumberFactory(10, 55, 5, parent.getId() as String, { :suffix => "%" });
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushBodyBatteryPicker(parent as MenuItem) as Void {
    var holder = new NumberFactory(10, 60, 5, parent.getId() as String, { :suffix => "%" });
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushThemeOptionsMenu(parent as MenuItem) as Void {
    var holder = new FixedValuesFactory([getThemeString(0), getThemeString(1), getThemeString(2), getThemeString(3)], parent.getId() as String, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushLayoutOptionsMenu(parent as MenuItem) {
    var holder = new FixedValuesFactory([getLayoutString(0), getLayoutString(1)], parent.getId() as String, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushOrbitDatafieldOptionsMenu(parent as MenuItem) as Void {
    var holder = new DataFieldFactory([0, 1, 2, 3, 4, 7, 8, 11, 13], parent.getId() as String, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushInnerCirclesDatafieldOptionsMenu(parent as MenuItem) {
    var holder = new DataFieldFactory([0, 1, 2, 3, 4, 7, 8, 9, 11, 13], parent.getId() as String, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushOuterCirclesDatafieldOptionsMenu(parent as MenuItem) {
    var holder = new DataFieldFactory([0, 1, 2, 3, 11], parent.getId() as String, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushClockDatafieldOptionsMenu(parent as MenuItem) {
    var holder = new DataFieldFactory([0, 2, 4, 5, 6, 7, 8, 9, 10, 11, 13], parent.getId() as String, {});
    WatchUi.pushView(new OptionsMenu2(holder, parent.getLabel()), new OptionsMenu2Delegate(holder, parent), WatchUi.SLIDE_LEFT);
  }

  hidden function pushOrbitSubMenu() {
    var menu = new WatchUi.Menu2({ :title => Settings.resource(Rez.Strings.SettingsOrbitLayoutGroupTitle) });
    menu.addItem(
      toggleItem(
        "showOrbitIndicatorText",
        Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextLabel),
        Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextEnabled),
        Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextDisabled)
      )
    );
    menu.addItem(menuItem("upper1", Settings.resource(Rez.Strings.ODSettingsLeftOrbitTitle), getDataFieldString(Settings.get("upper1"))));
    menu.addItem(menuItem("upper2", Settings.resource(Rez.Strings.ODSettingsRightOrbitTitle), getDataFieldString(Settings.get("upper2"))));
    menu.addItem(menuItem("outer", Settings.resource(Rez.Strings.ODSettingsOuterOrbitTitle), getDataFieldString(Settings.get("outer"))));
    menu.addItem(menuItem("middle1", Settings.resource(Rez.Strings.SettingsSecondary1Title), getDataFieldString(Settings.get("middle1"))));
    menu.addItem(menuItem("middle2", Settings.resource(Rez.Strings.SettingsSecondary2Title), getDataFieldString(Settings.get("middle2"))));
    menu.addItem(menuItem("middle3", Settings.resource(Rez.Strings.SettingsSecondary3Title), getDataFieldString(Settings.get("middle3"))));

    WatchUi.pushView(menu, new ProtomoleculeSettingsDelegate(), WatchUi.SLIDE_LEFT);
  }

  hidden function pushCirclesSubMenu() {
    var menu = new WatchUi.Menu2({ :title => Settings.resource(Rez.Strings.SettingsCirclesLayoutGroupTitle) });
    menu.addItem(menuItem("upper1", Settings.resource(Rez.Strings.ODSettingsUpper1Title), getDataFieldString(Settings.get("upper1"))));
    menu.addItem(menuItem("upper2", Settings.resource(Rez.Strings.ODSettingsUpper2Title), getDataFieldString(Settings.get("upper2"))));
    menu.addItem(menuItem("lower1", Settings.resource(Rez.Strings.ODSettingsLower1Title), getDataFieldString(Settings.get("lower1"))));
    menu.addItem(menuItem("lower2", Settings.resource(Rez.Strings.ODSettingsLower2Title), getDataFieldString(Settings.get("lower2"))));
    menu.addItem(menuItem("outer", Settings.resource(Rez.Strings.ODSettingsOuterTitle), getDataFieldString(Settings.get("outer"))));
    menu.addItem(menuItem("middle1", Settings.resource(Rez.Strings.SettingsSecondary1Title), getDataFieldString(Settings.get("middle1"))));
    menu.addItem(menuItem("middle2", Settings.resource(Rez.Strings.SettingsSecondary2Title), getDataFieldString(Settings.get("middle2"))));
    menu.addItem(menuItem("middle3", Settings.resource(Rez.Strings.SettingsSecondary3Title), getDataFieldString(Settings.get("middle3"))));

    WatchUi.pushView(menu, new ProtomoleculeSettingsDelegate(), WatchUi.SLIDE_LEFT);
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}

function toggleItem(id as String, label as String, enabledSubLabel as String, disabledSubLabel as String) {
  return new WatchUi.ToggleMenuItem(label, { :enabled => enabledSubLabel, :disabled => disabledSubLabel }, id, Settings.get(id), null);
}

function menuItem(id as String, label as String, subLabel as String?) {
  return new WatchUi.MenuItem(label, subLabel, id, null);
}

var _theme as Array<ResourceId>? = null;

function getThemeString(themeId as Number?) {
  if (_theme == null) {
    _theme = [Rez.Strings.ThemeExpanse, Rez.Strings.ThemeEarth, Rez.Strings.ThemeMars, Rez.Strings.ThemeBelt];
  }
  return Settings.resource(_theme[themeId]);
}

var _layout as Array<ResourceId>? = null;

function getLayoutString(layoutId as Number?) {
  if (_layout == null) {
    _layout = [Rez.Strings.LayoutOrbitItem, Rez.Strings.LayoutCirclesItem];
  }
  return Settings.resource(_layout[layoutId]);
}

function getDataFieldString(dfId as Number) {
  return Settings.resource(DataFieldRez[dfId]);
}
