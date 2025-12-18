import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application.Properties;

class OptionsMenu2 extends WatchUi.Menu2 {
  function initialize(valueHolder as ValueHolder, title as String) {
    Menu2.initialize({ :title => title, :focus => valueHolder.getIndexOfCurrentSelection() });

    for (var i = 0; i < valueHolder.getSize(); i++) {
      var icon = valueHolder.getIconDrawable(i);
      if (icon != null) {
        Menu2.addItem(new WatchUi.IconMenuItem(valueHolder.getLabel(i), null, i, icon, null));
      } else {
        Menu2.addItem(new WatchUi.MenuItem(valueHolder.getLabel(i), null, i, null));
      }
    }
  }
}

class OptionsMenu2Delegate extends WatchUi.Menu2InputDelegate {
  var holder as ValueHolder?;
  protected var mParent as MenuItem;

  function initialize(parent as MenuItem) {
    Menu2InputDelegate.initialize();
    mParent = parent;
  }

  function onSelect(item as WatchUi.MenuItem) {
    holder.save(item.getId());
    mParent.setSubLabel(holder.getLabel(item.getId()));
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}

import Toybox.Complications;

(:onPressComplication)
class ComplicationsSettingsMenu extends WatchUi.Menu2 {
  function initialize(currentValue) {
    var iter = Complications.getComplications();
    var compl = iter.next();
    var selection = 0;
    var items = [];
    while (compl != null) {
      if (compl.getType() == currentValue) {
        selection = items.size();
      }
      if (compl.getType() != Complications.COMPLICATION_TYPE_INVALID && compl.getType() != Complications.COMPLICATION_TYPE_BATTERY) {
        items.add(new WatchUi.MenuItem(compl.longLabel, null, compl.getType(), null));
      }
      compl = iter.next();
    }
    Menu2.initialize({ :title => "Complication", :focus => selection });
    for (var i = 0; i < items.size(); i++) {
      addItem(items[i]);
    }
  }
}

(:onPressComplication)
class ComplicationsMenuDelegate extends WatchUi.Menu2InputDelegate {
  protected var mParent as MenuItem;

  function initialize(parent as MenuItem) {
    Menu2InputDelegate.initialize();
    mParent = parent;
  }

  function onSelect(item as WatchUi.MenuItem) {
    try {
      var compType = item.getId() as Complications.Type;
      Properties.setValue(mParent.getId() as String, compType);
      mParent.setSubLabel(Complications.getComplication(new Complications.Id(compType)).longLabel);
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    } catch (error) {
      if (Log has :debug) {
        Log.debug("Error at '" + mParent.getId() + "'. Couldn't save selected item " + item.getId());
      }
      onBack();
    }
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
