import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class OptionsMenu2 extends WatchUi.Menu2 {
  function initialize(valueHolder as ValueHolder, title as String) {
    Menu2.initialize({ :title => title, :focus => valueHolder.getIndexOfCurrentSelection() });

    for (var i = 0; i < valueHolder.getSize(); i++) {
      Menu2.addItem(new WatchUi.MenuItem(valueHolder.getLabel(i), null, i, null));
    }
  }
}

class OptionsMenu2Delegate extends WatchUi.Menu2InputDelegate {
  hidden var mValueHolder as ValueHolder;
  hidden var mParent as MenuItem;

  function initialize(valueHolder as ValueHolder, parent as MenuItem) {
    Menu2InputDelegate.initialize();
    mValueHolder = valueHolder;
    mParent = parent;
  }

  function onSelect(item) {
    mValueHolder.save(item.getId());
    mParent.setSubLabel(mValueHolder.getLabel(item.getId()));
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
