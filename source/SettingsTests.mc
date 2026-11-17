import Toybox.Lang;
import Toybox.Test;
import Toybox.Time;

(:test)
function testSameDaySleepWindow(logger as Test.Logger) as Boolean {
  var asleep = Settings.isWithinSleepWindow(
    new Time.Duration(12 * 3600),
    new Time.Duration(8 * 3600),
    new Time.Duration(22 * 3600)
  );
  var awake = Settings.isWithinSleepWindow(
    new Time.Duration(7 * 3600),
    new Time.Duration(8 * 3600),
    new Time.Duration(22 * 3600)
  );
  logger.debug("Same-day sleep-window checks");
  return asleep && !awake;
}

(:test)
function testOvernightSleepWindow(logger as Test.Logger) as Boolean {
  var beforeMidnight = Settings.isWithinSleepWindow(
    new Time.Duration(23 * 3600),
    new Time.Duration(22 * 3600),
    new Time.Duration(7 * 3600)
  );
  var afterMidnight = Settings.isWithinSleepWindow(
    new Time.Duration(6 * 3600),
    new Time.Duration(22 * 3600),
    new Time.Duration(7 * 3600)
  );
  var daytime = Settings.isWithinSleepWindow(
    new Time.Duration(12 * 3600),
    new Time.Duration(22 * 3600),
    new Time.Duration(7 * 3600)
  );
  logger.debug("Overnight sleep-window checks");
  return beforeMidnight && afterMidnight && !daytime;
}

(:test)
function testSleepWindowExcludesEndpoints(logger as Test.Logger) as Boolean {
  var atSleepTime = Settings.isWithinSleepWindow(
    new Time.Duration(22 * 3600),
    new Time.Duration(22 * 3600),
    new Time.Duration(7 * 3600)
  );
  var atWakeTime = Settings.isWithinSleepWindow(
    new Time.Duration(7 * 3600),
    new Time.Duration(22 * 3600),
    new Time.Duration(7 * 3600)
  );
  logger.debug("Sleep and wake boundary checks");
  return !atSleepTime && !atWakeTime;
}

(:test)
function testEqualSleepAndWakeTimesDisableWindow(logger as Test.Logger) as Boolean {
  var asleep = Settings.isWithinSleepWindow(
    new Time.Duration(12 * 3600),
    new Time.Duration(8 * 3600),
    new Time.Duration(8 * 3600)
  );
  logger.debug("Equal sleep and wake times disable the window");
  return !asleep;
}