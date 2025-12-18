import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Complications;
import Config;

class ProtomoleculeSettingsMenu extends WatchUi.Menu2 {
  (:mipDisplay)
  protected function addActiveHeartRateMenuItem() {
    addItem(
      $.toggleItem(
        "activeHeartrate",
        Settings.resource(Rez.Strings.ToggleMenuActiveHeartrateLabel),
        Settings.resource(Rez.Strings.ToggleMenuActiveHeartrateEnabled),
        Settings.resource(Rez.Strings.ToggleMenuActiveHeartrateDisabled)
      )
    );
  }

  function initialize() {
    Menu2.initialize({ :title => Settings.resource(Rez.Strings.SettingsMenuLabel) });

    addItem($.menuItem("layout", Settings.resource(Rez.Strings.SettingsLayoutTitle), $.getLayoutString(Properties.getValue("layout") as Layout)));
    addItem($.menuItem("layoutSettings", Settings.resource(Rez.Strings.SettingsLayoutSettingsTitle), null));
    addItem($.menuItem("theme", Settings.resource(Rez.Strings.SettingsThemeTitle), $.getThemeString(Properties.getValue("theme") as Theme)));
    addItem($.menuItem("timeSettings", Settings.resource(Rez.Strings.SettingsTimeSettingsTitle), null));
    if (self has :addActiveHeartRateMenuItem) {
      addActiveHeartRateMenuItem();
    }
    addItem(
      $.menuItem(
        "sleepLayoutSettings",
        Settings.resource(Rez.Strings.SettingsSleepLayoutSettingsTitle),
        Settings.resource(Rez.Strings.ToggleMenuSleepTimeLayoutLabel) +
          ": " +
          (Properties.getValue("sleepLayoutActive") ? Settings.resource(Rez.Strings.ToggleMenuEnabled) : Settings.resource(Rez.Strings.ToggleMenuDisabled))
      )
    );
    addItem(
      $.toggleItem(
        "useSystemFontForDate",
        Settings.resource(Rez.Strings.ToggleMenuSystemFontLabel),
        Settings.resource(Rez.Strings.ToggleMenuSystemFontEnabled),
        Settings.resource(Rez.Strings.ToggleMenuSystemFontDisabled)
      )
    );

    addItem($.menuItem("caloriesGoal", Settings.resource(Rez.Strings.SettingsCaloriesGoalTitle), Properties.getValue("caloriesGoal").toString()));
    addItem($.menuItem("batteryThreshold", Settings.resource(Rez.Strings.SettingsBatteryThresholdTitle), Properties.getValue("batteryThreshold").toString()));
    addItem(
      $.toggleItem(
        "dynamicBodyBattery",
        Settings.resource(Rez.Strings.SettingsDynamicBodyBatteryTitle),
        Settings.resource(Rez.Strings.ToggleMenuEnabled),
        Settings.resource(Rez.Strings.ToggleMenuDisabled)
      )
    );
    addItem($.menuItem("bodyBatteryThreshold", Settings.resource(Rez.Strings.SettingsBodyBatteryThresholdTitle), Properties.getValue("bodyBatteryThreshold").toString()));
  }
}

class ProtomoleculeSettingsDelegate extends WatchUi.Menu2InputDelegate {
  private var sleepLayoutMenuItem as MenuItem?;

  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    var id = item.getId() as String;
    if ("layoutSettings".equals(id)) {
      if (Properties.getValue("layout") == 0) {
        pushOrbitLayoutSettingsMenu();
      } else {
        pushCirclesLayoutSettingsMenu();
      }
      return;
    } else if ("timeSettings".equals(id)) {
      pushTimeSettingsMenu();
      return;
    } else if ("sleepLayoutSettings".equals(id)) {
      sleepLayoutMenuItem = item;
      pushSleepLayoutSettingsMenu();
      return;
    }
    if (item instanceof ToggleMenuItem) {
      Properties.setValue(id, (item as ToggleMenuItem).isEnabled());
      return;
    }
    if (item instanceof MenuItem) {
      pushOptionsMenu(item, id);
      return;
    }
  }

  function onBack() {
    if (sleepLayoutMenuItem != null) {
      sleepLayoutMenuItem.setSubLabel(
        Settings.resource(Rez.Strings.ToggleMenuSleepTimeLayoutLabel) +
          ": " +
          (Properties.getValue("sleepLayoutActive") ? Settings.resource(Rez.Strings.ToggleMenuEnabled) : Settings.resource(Rez.Strings.ToggleMenuDisabled))
      );
      sleepLayoutMenuItem = null;
    }
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }

  private function pushOrbitLayoutSettingsMenu() {
    var menu = new WatchUi.Menu2({ :title => Settings.resource(Rez.Strings.SettingsOrbitLayoutGroupTitle) });
    menu.addItem(
      $.toggleItem(
        "showOrbitIndicatorText",
        Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextLabel),
        Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextEnabled),
        Settings.resource(Rez.Strings.ToggleMenuShowIndicatorTextDisabled)
      )
    );
    menu.addItem($.menuItem("leftOrbitDataField", Settings.resource(Rez.Strings.ODSettingsLeftOrbitTitle), $.getDataFieldString(Properties.getValue("leftOrbitDataField") as FieldType)));
    menu.addItem($.menuItem("rightOrbitDataField", Settings.resource(Rez.Strings.ODSettingsRightOrbitTitle), $.getDataFieldString(Properties.getValue("rightOrbitDataField") as FieldType)));
    menu.addItem($.menuItem("outerOrbitDataField", Settings.resource(Rez.Strings.ODSettingsOuterOrbitTitle), $.getDataFieldString(Properties.getValue("outerOrbitDataField") as FieldType)));
    menu.addItem($.menuItem("noProgressDataField1", Settings.resource(Rez.Strings.SettingsSecondary1Title), $.getDataFieldString(Properties.getValue("noProgressDataField1") as FieldType)));
    menu.addItem($.menuItem("noProgressDataField2", Settings.resource(Rez.Strings.SettingsSecondary2Title), $.getDataFieldString(Properties.getValue("noProgressDataField2") as FieldType)));
    menu.addItem($.menuItem("noProgressDataField3", Settings.resource(Rez.Strings.SettingsSecondary3Title), $.getDataFieldString(Properties.getValue("noProgressDataField3") as FieldType)));

    WatchUi.pushView(menu, self, WatchUi.SLIDE_LEFT);
  }

  private function pushCirclesLayoutSettingsMenu() {
    var menu = new WatchUi.Menu2({ :title => Settings.resource(Rez.Strings.SettingsCirclesLayoutGroupTitle) });
    menu.addItem($.menuItem("upperDataField1", Settings.resource(Rez.Strings.ODSettingsUpper1Title), $.getDataFieldString(Properties.getValue("upperDataField1") as FieldType)));
    menu.addItem($.menuItem("upperDataField2", Settings.resource(Rez.Strings.ODSettingsUpper2Title), $.getDataFieldString(Properties.getValue("upperDataField2") as FieldType)));
    menu.addItem($.menuItem("lowerDataField1", Settings.resource(Rez.Strings.ODSettingsLower1Title), $.getDataFieldString(Properties.getValue("lowerDataField1") as FieldType)));
    menu.addItem($.menuItem("lowerDataField2", Settings.resource(Rez.Strings.ODSettingsLower2Title), $.getDataFieldString(Properties.getValue("lowerDataField2") as FieldType)));
    menu.addItem($.menuItem("outerDataField", Settings.resource(Rez.Strings.ODSettingsOuterTitle), $.getDataFieldString(Properties.getValue("outerDataField") as FieldType)));
    menu.addItem($.menuItem("noProgressDataField1", Settings.resource(Rez.Strings.SettingsSecondary1Title), $.getDataFieldString(Properties.getValue("noProgressDataField1") as FieldType)));
    menu.addItem($.menuItem("noProgressDataField2", Settings.resource(Rez.Strings.SettingsSecondary2Title), $.getDataFieldString(Properties.getValue("noProgressDataField2") as FieldType)));
    menu.addItem($.menuItem("noProgressDataField3", Settings.resource(Rez.Strings.SettingsSecondary3Title), $.getDataFieldString(Properties.getValue("noProgressDataField3") as FieldType)));

    WatchUi.pushView(menu, self, WatchUi.SLIDE_LEFT);
  }

  private function pushTimeSettingsMenu() {
    var menu = new WatchUi.Menu2({ :title => Settings.resource(Rez.Strings.SettingsTimeSettingsTitle) });
    menu.addItem(
      $.toggleItem("showSeconds", Settings.resource(Rez.Strings.SettingsShowSecondsTitle), Settings.resource(Rez.Strings.ToggleMenuEnabled), Settings.resource(Rez.Strings.ToggleMenuDisabled))
    );
    menu.addItem(
      $.toggleItem("showMeridiemText", Settings.resource(Rez.Strings.ToggleMenuShowAmPmLabel), Settings.resource(Rez.Strings.ToggleMenuEnabled), Settings.resource(Rez.Strings.ToggleMenuDisabled))
    );
    if (self has :addComplicationTimeSettings) {
      addComplicationTimeSettings(menu);
    }
    WatchUi.pushView(menu, self, WatchUi.SLIDE_LEFT);
  }

  (:onPressComplication)
  protected function addComplicationTimeSettings(menu) {
    var dateSubLabel = Settings.getComplicationLongLabelFromFroperty("dateComplicationTrigger");
    var timeSubLabel = Settings.getComplicationLongLabelFromFroperty("timeComplicationTrigger");
    var leftSubLabel = Settings.getComplicationLongLabelFromFroperty("leftComplicationTrigger");
    var rightSubLabel = Settings.getComplicationLongLabelFromFroperty("rightComplicationTrigger");
    menu.addItem($.menuItem("dateComplicationTrigger", Settings.resource(Rez.Strings.ComplicationTriggerDate), dateSubLabel));
    menu.addItem($.menuItem("timeComplicationTrigger", Settings.resource(Rez.Strings.ComplicationTriggerTime), timeSubLabel));
    menu.addItem($.menuItem("leftComplicationTrigger", Settings.resource(Rez.Strings.ComplicationTriggerLeft), leftSubLabel));
    menu.addItem($.menuItem("rightComplicationTrigger", Settings.resource(Rez.Strings.ComplicationTriggerRight), rightSubLabel));
  }

  private function pushSleepLayoutSettingsMenu() {
    var menu = new WatchUi.Menu2({ :title => Settings.resource(Rez.Strings.SettingsSleepLayoutSettingsTitle) });
    menu.addItem(
      $.toggleItem(
        "sleepLayoutActive",
        Settings.resource(Rez.Strings.ToggleMenuSleepTimeLayoutLabel),
        Settings.resource(Rez.Strings.ToggleMenuEnabled),
        Settings.resource(Rez.Strings.ToggleMenuDisabled)
      )
    );
    menu.addItem($.menuItem("sleepModeDataFieldUp", Settings.resource(Rez.Strings.ODSettingsSleepModeDFUpTitle), $.getDataFieldString(Properties.getValue("sleepModeDataFieldUp") as FieldType)));
    menu.addItem($.menuItem("sleepModeDataField1", Settings.resource(Rez.Strings.SettingsSecondary1Title), $.getDataFieldString(Properties.getValue("sleepModeDataField1") as FieldType)));
    menu.addItem($.menuItem("sleepModeDataField2", Settings.resource(Rez.Strings.SettingsSecondary2Title), $.getDataFieldString(Properties.getValue("sleepModeDataField2") as FieldType)));
    menu.addItem($.menuItem("sleepModeDataField3", Settings.resource(Rez.Strings.SettingsSecondary3Title), $.getDataFieldString(Properties.getValue("sleepModeDataField3") as FieldType)));

    WatchUi.pushView(menu, self, WatchUi.SLIDE_LEFT);
  }

  (:onPressComplication)
  protected function pushComplicationsMenu(item as MenuItem) {
    WatchUi.pushView(new ComplicationsSettingsMenu(Properties.getValue(item.getId() as String)), new ComplicationsMenuDelegate(item), WatchUi.SLIDE_LEFT);
  }

  protected function pushOptionsMenu(item as MenuItem, id as String) {
    var options = new OptionsMenu2Delegate(item);
    if ("layout".equals(id)) {
      options.holder = new FixedValuesFactory([$.getLayoutString(Config.LAYOUT_ORBIT), $.getLayoutString(Config.LAYOUT_CIRCLES)], id, {});
    }
    if ("theme".equals(id)) {
      options.holder = new FixedValuesFactory(
        [$.getThemeString(Config.THEME_EXPANSE), $.getThemeString(Config.THEME_EARTH), $.getThemeString(Config.THEME_MARS), $.getThemeString(Config.THEME_BELT)],
        id,
        {}
      );
    }
    if (
      self has :pushComplicationsMenu &&
      ("timeComplicationTrigger".equals(id) || "dateComplicationTrigger".equals(id) || "leftComplicationTrigger".equals(id) || "rightComplicationTrigger".equals(id))
    ) {
      pushComplicationsMenu(item);
      return;
    }
    if (
      "noProgressDataField1".equals(id) ||
      "noProgressDataField2".equals(id) ||
      "noProgressDataField3".equals(id) ||
      "sleepModeDataFieldUp".equals(id) ||
      "sleepModeDataField1".equals(id) ||
      "sleepModeDataField2".equals(id) ||
      "sleepModeDataField3".equals(id)
    ) {
      options.holder = new DataFieldFactory(
        [
          Config.DATA_NOTHING,
          Config.DATA_BATTERY,
          Config.DATA_ACTIVE_MINUTES,
          Config.DATA_HEART_RATE,
          Config.DATA_NOTIFICATION,
          Config.DATA_FLOORS_UP,
          Config.DATA_FLOORS_DOWN,
          Config.DATA_BLUETOOTH,
          Config.DATA_ALARMS,
          Config.DATA_BODY_BATTERY,
          Config.DATA_STRESS_LEVEL,
        ],
        id,
        {}
      );
    }
    if ("outerOrbitDataField".equals(id) || "leftOrbitDataField".equals(id) || "rightOrbitDataField".equals(id)) {
      options.holder = new DataFieldFactory(
        [
          Config.DATA_NOTHING,
          Config.DATA_STEPS,
          Config.DATA_BATTERY,
          Config.DATA_CALORIES,
          Config.DATA_ACTIVE_MINUTES,
          Config.DATA_FLOORS_UP,
          Config.DATA_FLOORS_DOWN,
          Config.DATA_BODY_BATTERY,
          Config.DATA_STRESS_LEVEL,
        ],
        id,
        {}
      );
    }
    if ("outerDataField".equals(id)) {
      options.holder = new DataFieldFactory([Config.DATA_NOTHING, Config.DATA_STEPS, Config.DATA_BATTERY, Config.DATA_CALORIES, Config.DATA_BODY_BATTERY], id, {});
    }
    if ("upperDataField1".equals(id) || "upperDataField2".equals(id) || "lowerDataField1".equals(id) || "lowerDataField2".equals(id)) {
      options.holder = new DataFieldFactory(
        [
          Config.DATA_NOTHING,
          Config.DATA_STEPS,
          Config.DATA_BATTERY,
          Config.DATA_CALORIES,
          Config.DATA_ACTIVE_MINUTES,
          Config.DATA_FLOORS_UP,
          Config.DATA_FLOORS_DOWN,
          Config.DATA_BLUETOOTH,
          Config.DATA_BODY_BATTERY,
          Config.DATA_STRESS_LEVEL,
        ],
        id,
        {}
      );
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
  }
}

function toggleItem(id as String, label as String, enabledSubLabel as String, disabledSubLabel as String) {
  return new WatchUi.ToggleMenuItem(label, { :enabled => enabledSubLabel, :disabled => disabledSubLabel }, id, Properties.getValue(id) as Boolean, null);
}

function menuItem(id as String, label as String, subLabel as String?) {
  return new WatchUi.MenuItem(label, subLabel, id, null);
}

function getThemeString(themeId as Theme) {
  var _theme = [Rez.Strings.ThemeExpanse, Rez.Strings.ThemeEarth, Rez.Strings.ThemeMars, Rez.Strings.ThemeBelt];
  return Settings.resource(_theme[themeId]);
}

function getLayoutString(layoutId as Layout) {
  var _layout = [Rez.Strings.LayoutOrbitItem, Rez.Strings.LayoutCirclesItem];
  return Settings.resource(_layout[layoutId]);
}

function getDataFieldString(dfId as FieldType) {
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
