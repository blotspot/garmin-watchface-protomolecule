using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.Graphics;
using Toybox.System;

class ProtomoleculeSettingsMenu extends Ui.Menu2 {

  function initialize() {
    Menu2.initialize({:title=>"Settings"});
    
    Menu2.addItem(new Ui.ToggleMenuItem("Active Heartrate", Settings.get(:activeHeartrate) ? "10 sec" : "1 min", "activeHeartrate", Settings.get(:activeHeartrate), null));
    Menu2.addItem(new Ui.ToggleMenuItem("Show AM / PM", Settings.get(:showMeridiemText) ? "On" : "Off", "showMeridiemText", Settings.get(:showMeridiemText), null));
    Menu2.addItem(new Ui.ToggleMenuItem("Sleep layout", Settings.get(:sleepLayoutActive) ? "On" : "Off", "sleepTimeLayout", Settings.get(:sleepLayoutActive), null));
    Menu2.addItem(new Ui.ToggleMenuItem("Alt. font for date", Settings.get(:useSystemFontForDate) ? "On" : "Off", "useSystemFontForDate", Settings.get(:useSystemFontForDate), null));
    

    if (Settings.get(:theme) == LayoutId.ORBIT) {
   	  Menu2.addItem(new Ui.ToggleMenuItem("Indicator", Settings.get(:showOrbitIndicatorText) ? "Icon and Text" : "Icon only", "showOrbitIndicatorText", Settings.get(:showOrbitIndicatorText), null)); 
    } else {

    }
  }

  function onBack() {
    Settings.loadProperties();
    Ui.popView(WatchUi.SLIDE_IMMEDIATE);
		return false;
  }
}

class ProtomoleculeSettingsDelegate extends Ui.Menu2InputDelegate {

  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    Log.debug(item.getId() + "; " + item.isEnabled());
    Properties.setValue(item.getId(), item.isEnabled());
    Settings.loadProperties();
    item.requestUpdate();
  }
}

class SubMenuDelegate extends Ui.Menu2InputDelegate {
    
  var parentMenuItem;
  
  function initialize(p) {
    Menu2InputDelegate.initialize();
    parentMenuItem = p;
  }

  function onSelect(subMenuItem) {
    var parentId = parentMenuItem.getId();
    var id = subMenuItem.getId();
    var label = subMenuItem.getLabel();

		Properties.setValue(parentId, id);  // ParentMenuItem ID and SubMenuItem ID are used to set application property to new index
		parentMenuItem.setSubLabel(label);  // ParentMenuItem sublabel is changed to match SubMenuItem label
		Ui.popView(Ui.SLIDE_RIGHT);
	}
}