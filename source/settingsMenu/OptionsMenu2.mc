import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

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

(:api420AndAbove)
class ComplicationsSettingsMenu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({ :title => Settings.resource(Rez.Strings.SettingsMenuLabel) });

    var iter = Complications.getComplications();
    var compl = iter.next();
    while (compl != null) {
      var item = new WatchUi.MenuItem(compl.longLabel, compl.value + " (" + compl.getType() + ")", compl.complicationId, null);
      if (compl.getIcon() != null) {
        item.setIcon(compl.getIcon());
      }
      Menu2.addItem(item);
      compl = iter.next();
    }
  }
}

(:api420AndAbove)
class ComplicationsMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item as WatchUi.MenuItem) {
    try {
      Complications.exitTo(item.getId() as Complications.Id);
    } catch (error) {}
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
