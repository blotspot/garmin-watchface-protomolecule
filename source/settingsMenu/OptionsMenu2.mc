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
  hidden var mParent as MenuItem;

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
