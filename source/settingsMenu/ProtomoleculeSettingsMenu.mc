import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;

class ProtomoleculeSettingsMenu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({ :title => Settings.resource(Rez.Strings.SettingsMenuLabel) });

    Menu2.addItem(menuItem("layout", Settings.resource(Rez.Strings.SettingsLayoutTitle), getLayoutString(Properties.getValue("layout") as Number)));
    Menu2.addItem(menuItem("layoutSettings", Settings.resource(Rez.Strings.SettingsLayoutSettingsTitle), null));
    Menu2.addItem(menuItem("theme", Settings.resource(Rez.Strings.SettingsThemeTitle), getThemeString(Properties.getValue("theme") as Number)));

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

    Menu2.addItem(menuItem("caloriesGoal", Settings.resource(Rez.Strings.SettingsCaloriesGoalTitle), Properties.getValue("caloriesGoal").toString()));
    Menu2.addItem(menuItem("batteryThreshold", Settings.resource(Rez.Strings.SettingsBatteryThresholdTitle), Properties.getValue("batteryThreshold").toString()));
    Menu2.addItem(
      toggleItem(
        "dynamicBodyBattery",
        Settings.resource(Rez.Strings.SettingsDynamicBodyBatteryTitle),
        Settings.resource(Rez.Strings.ToggleMenuEnabled),
        Settings.resource(Rez.Strings.ToggleMenuDisabled)
      )
    );
    Menu2.addItem(menuItem("bodyBatteryThreshold", Settings.resource(Rez.Strings.SettingsBodyBatteryThresholdTitle), Properties.getValue("bodyBatteryThreshold").toString()));
  }
}

class ProtomoleculeSettingsDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    var id = item.getId() as String;
    if ("layoutSettings".equals(id)) {
      if (Properties.getValue("layout") == 0) {
        var menu = new WatchUi.Menu2({ :title => Settings.resource(Rez.Strings.SettingsOrbitLayoutGroupTitle) });
        menu.addItem(
          toggleItem(
            "showOrbitIndicatorText",
            Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextLabel),
            Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextEnabled),
            Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextDisabled)
          )
        );
        menu.addItem(menuItem("leftOrbitDataField", Settings.resource(Rez.Strings.ODSettingsLeftOrbitTitle), getDataFieldString(Properties.getValue("leftOrbitDataField") as Number)));
        menu.addItem(menuItem("rightOrbitDataField", Settings.resource(Rez.Strings.ODSettingsRightOrbitTitle), getDataFieldString(Properties.getValue("rightOrbitDataField") as Number)));
        menu.addItem(menuItem("outerOrbitDataField", Settings.resource(Rez.Strings.ODSettingsOuterOrbitTitle), getDataFieldString(Properties.getValue("outerOrbitDataField") as Number)));
        menu.addItem(menuItem("noProgressDataField1", Settings.resource(Rez.Strings.SettingsSecondary1Title), getDataFieldString(Properties.getValue("noProgressDataField1") as Number)));
        menu.addItem(menuItem("noProgressDataField2", Settings.resource(Rez.Strings.SettingsSecondary2Title), getDataFieldString(Properties.getValue("noProgressDataField2") as Number)));
        menu.addItem(menuItem("noProgressDataField3", Settings.resource(Rez.Strings.SettingsSecondary3Title), getDataFieldString(Properties.getValue("noProgressDataField3") as Number)));

        WatchUi.pushView(menu, self, WatchUi.SLIDE_LEFT);
        return;
      } else {
        var menu = new WatchUi.Menu2({ :title => Settings.resource(Rez.Strings.SettingsCirclesLayoutGroupTitle) });
        menu.addItem(menuItem("upperDataField1", Settings.resource(Rez.Strings.ODSettingsUpper1Title), getDataFieldString(Properties.getValue("upperDataField1") as Number)));
        menu.addItem(menuItem("upperDataField2", Settings.resource(Rez.Strings.ODSettingsUpper2Title), getDataFieldString(Properties.getValue("upperDataField2") as Number)));
        menu.addItem(menuItem("lowerDataField1", Settings.resource(Rez.Strings.ODSettingsLower1Title), getDataFieldString(Properties.getValue("lowerDataField1") as Number)));
        menu.addItem(menuItem("lowerDataField2", Settings.resource(Rez.Strings.ODSettingsLower2Title), getDataFieldString(Properties.getValue("lowerDataField2") as Number)));
        menu.addItem(menuItem("outerDataField", Settings.resource(Rez.Strings.ODSettingsOuterTitle), getDataFieldString(Properties.getValue("outerDataField") as Number)));
        menu.addItem(menuItem("noProgressDataField1", Settings.resource(Rez.Strings.SettingsSecondary1Title), getDataFieldString(Properties.getValue("noProgressDataField1") as Number)));
        menu.addItem(menuItem("noProgressDataField2", Settings.resource(Rez.Strings.SettingsSecondary2Title), getDataFieldString(Properties.getValue("noProgressDataField2") as Number)));
        menu.addItem(menuItem("noProgressDataField3", Settings.resource(Rez.Strings.SettingsSecondary3Title), getDataFieldString(Properties.getValue("noProgressDataField3") as Number)));

        WatchUi.pushView(menu, self, WatchUi.SLIDE_LEFT);
        return;
      }
    }
    if (item instanceof ToggleMenuItem) {
      Properties.setValue(id, (item as ToggleMenuItem).isEnabled());
      return;
    }
    if (item instanceof MenuItem) {
      var options = new OptionsMenu2Delegate(item);
      if ("layout".equals(id)) {
        options.holder = new FixedValuesFactory([getLayoutString(0), getLayoutString(1)], id, {});
      }
      if ("theme".equals(id)) {
        options.holder = new FixedValuesFactory([getThemeString(0), getThemeString(1), getThemeString(2), getThemeString(3)], id, {});
      }
      if ("noProgressDataField1noProgressDataField2noProgressDataField3".find(id)) {
        options.holder = new DataFieldFactory([0, 2, 4, 5, 6, 7, 8, 9, 10, 11, 13], id, {});
      }
      if ("outerOrbitDataFieldleftOrbitDataFieldrightOrbitDataField".find(id)) {
        options.holder = new DataFieldFactory([0, 1, 2, 3, 4, 7, 8, 11, 13], id, {});
      }
      if ("outerDataField".equals(id)) {
        options.holder = new DataFieldFactory([0, 1, 2, 3, 11], id, {});
      }
      if ("upperDataField1upperDataField2lowerDataField1lowerDataField2".find(id)) {
        options.holder = new DataFieldFactory([0, 1, 2, 3, 4, 7, 8, 9, 11, 13], id, {});
      }
      if ("caloriesGoal".equals(id)) {
        options.holder = new NumberFactory(1500, 4000, 100, id, {});
      }
      if ("batteryThreshold".equals(id)) {
        options.holder = new NumberFactory(10, 55, 5, id, { :suffix => "%" });
      }
      if ("bodyBatteryThreshold".equals(id)) {
        options.holder = new NumberFactory(10, 60, 5, id, { :suffix => "%" });
      }
      WatchUi.pushView(new OptionsMenu2(options.holder, item.getLabel()), options, WatchUi.SLIDE_LEFT);
      return;
    }
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}

function toggleItem(id as String, label as String, enabledSubLabel as String, disabledSubLabel as String) {
  return new WatchUi.ToggleMenuItem(label, { :enabled => enabledSubLabel, :disabled => disabledSubLabel }, id, Properties.getValue(id) as Boolean, null);
}

function menuItem(id as String, label as String, subLabel as String?) {
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
