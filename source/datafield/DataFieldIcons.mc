import Toybox.WatchUi;
import Toybox.Math;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;

module DataFieldIcons {
  //! dc => Drawable object
  //! x  => x-Axis center point
  //! y  => y-Axis center point
  //! size    => max. height & width of the object
  //! penSize => stroke width for unfilled areas
  //! value   => value of data field

  function drawBattery(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y + size * 0.1, "m");
  }

  function drawBatteryFull(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y + size * 0.1, "h");
  }

  function drawBatteryLow(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y + size * 0.1, "k");
  }

  function drawBatteryLoading(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y + size * 0.1, "l");
  }

  function drawSteps(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "s");
  }

  function drawCalories(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "c");
  }

  function drawActiveMinutes(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "t");
  }

  function drawNotificationInactive(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y + size * 0.1, "N");
  }

  function drawNotificationActive(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y + size * 0.1, "n");
  }

  function drawHeartRate(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "p");
  }

  function drawNoHeartRate(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "P");
  }

  function drawFloorsUp(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "F");
  }

  function drawFloorsDown(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "f");
  }

  function drawBluetoothConnection(dc, x, y, size, penSize, value) as Void {
    dc.setColor(themeColor(Color.TEXT_ACTIVE), Graphics.COLOR_TRANSPARENT);
    textIcon(dc, x, y, "b");
  }

  function drawNoBluetoothConnection(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "B");
  }

  function drawAlarms(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "a");
  }

  function drawNoAlarms(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "A");
  }

  function drawSeconds(dc, x, y, size, penSize, value) as Void {
    dc.setColor(themeColor(Color.TEXT_ACTIVE), Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y - size * 0.1, Settings.resource(Rez.Fonts.MeridiemFont), value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawBodyBattery(dc, x, y, size, penSize, value) as Void {
    var iconText = "o";
    if (Settings.get("dynamicBodyBattery")) {
      var threshold = Settings.get("bodyBatteryThreshold");
      value = value.toLong();
      Log.debug("body battery " + value + " / " + threshold);
      if (value <= 5) {
        iconText = "z";
      } else if (value < threshold) {
        iconText = "y";
      }
    }

    textIcon(dc, x, y, iconText);
  }

  function drawStressLevel(dc, x, y, size, penSize, value) as Void {
    textIcon(dc, x, y, "x");
  }

  function textIcon(dc, x, y, string) as Void {
    var font = Settings.resource(Rez.Fonts.IconsFont);
    dc.drawText(x, y, font, string, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function _getBuffer(size) as Lang.Double {
    return size / 10.0;
  }
}
