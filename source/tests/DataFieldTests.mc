import Toybox.Complications;
import Toybox.Lang;
import Toybox.Test;

(:test)
function testHitboxInsideAndBoundary(logger as Test.Logger) as Boolean {
  var hitbox = { :x => 10, :y => 20, :width => 30, :height => 40 };
  var inside = isPointInHitbox(hitbox, 25, 30);
  var leftTop = isPointInHitbox(hitbox, 10, 20);
  var rightBottom = isPointInHitbox(hitbox, 40, 60);
  var outside = isPointInHitbox(hitbox, 41, 30);
  var nullHitbox = isPointInHitbox(null, 10, 10);
  logger.debug("Hitbox geometry checks");
  return inside && leftTop && rightBottom && !outside && !nullHitbox;
}

(:test)
function testLayoutPriorityPrecedence(logger as Test.Logger) as Boolean {
  var legacyBip = getLayoutPriority(true, false, true, Config.LAYOUT_CIRCLES);
  var sleepMode = getLayoutPriority(true, true, true, Config.LAYOUT_CIRCLES);
  var lowPower = getLayoutPriority(true, true, false, Config.LAYOUT_CIRCLES);
  var defaultLayout = getLayoutPriority(false, true, false, Config.LAYOUT_ORBIT);
  logger.debug("Layout priority checks");
  return legacyBip == Config.LAYOUT_BIP
    && sleepMode == Config.LAYOUT_SLEEP
    && lowPower == Config.LAYOUT_LPM
    && defaultLayout == Config.LAYOUT_ORBIT;
}

(:test)
function testNumberFactoryConversionRoundTrip(logger as Test.Logger) as Boolean {
  var factory = new NumberFactory(50, 90, 10, "testNumberFactory", { :initialIndex => 0 });
  var first = factory.getSettingsValue(0);
  var middle = factory.getSettingsValue(2);
  var last = factory.getSettingsValue(4);
  var roundTrip = factory.getIndex(first) == 0
    && factory.getIndex(middle) == 2
    && factory.getIndex(last) == 4;
  logger.debug("Number factory conversion checks");
  return factory.getSize() == 5 && first == 50 && middle == 70 && last == 90 && roundTrip;
}

(:test)
function testFixedValuesFactoryConversion(logger as Test.Logger) as Boolean {
  var factory = new FixedValuesFactory(["one", "two", "three"], "testFixedValuesFactory", { :initialIndex => 0 });
  logger.debug("Fixed values factory conversion checks");
  return factory.getSize() == 3
    && factory.getIndex("two") == 1
    && factory.getSettingsValue(2) == 2
    && factory.getLabel(1).equals("two");
}

(:test)
function testDataFieldComplicationMappings(logger as Test.Logger) as Boolean {
  var steps = DataFieldInfo.getComplicationsTypeForField(Config.DATA_STEPS);
  var calories = DataFieldInfo.getComplicationsTypeForField(Config.DATA_ACTIVE_CALORIES);
  var bluetooth = DataFieldInfo.getComplicationsTypeForField(Config.DATA_BLUETOOTH);
  var alarms = DataFieldInfo.getComplicationsTypeForField(Config.DATA_ALARMS);
  var unknown = DataFieldInfo.getComplicationsTypeForField(Config.DATA_SECONDS);
  logger.debug("Data field complication mapping checks");
  return steps == Complications.COMPLICATION_TYPE_STEPS
    && calories == Complications.COMPLICATION_TYPE_CALORIES
    && bluetooth == Complications.COMPLICATION_TYPE_INVALID
    && alarms == Complications.COMPLICATION_TYPE_INVALID
    && unknown == null;
}
