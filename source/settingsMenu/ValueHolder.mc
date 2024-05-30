import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class ValueHolder {
  hidden var mPrefix;
  hidden var mSuffix;
  hidden var sizeCallback;
  hidden var indexCallback;
  hidden var textValueCallback;
  hidden var settingsValueCallback;

  protected var mSettingsId;
  protected var mCurrentSelection;

  (:typecheck(false))
  function initialize(settingsId, options) {
    mSettingsId = settingsId;
    mPrefix = options.hasKey(:prefix) ? options[:prefix] : "";
    mSuffix = options.hasKey(:suffix) ? options[:suffix] : "";
    sizeCallback = options[:size];
    indexCallback = options[:index];
    textValueCallback = options[:textValue];
    settingsValueCallback = options[:settingsValue];
  }

  hidden function getLabelValue(index) {
    return mPrefix + getTextValue(index).toString() + mSuffix;
  }

  hidden function wrapIndex(index) {
    if (index < 0) {
      index = getSize() + index;
    }
    return index % getSize();
  }

  function getLabelRelativeToSelection(pos) {
    return getLabelValue(wrapIndex(mCurrentSelection + pos));
  }

  function incrementSelection() {
    mCurrentSelection = wrapIndex(mCurrentSelection + 1);
  }

  function decrementSelection() {
    mCurrentSelection = wrapIndex(mCurrentSelection - 1);
  }

  function saveSelection() {
    Settings.set(mSettingsId, getSettingsValue(mCurrentSelection));
  }

  //! get the settings value of the element at this index.
  protected function getSettingsValue(index) {
    return settingsValueCallback.invoke(index);
  }

  //! get the amount of elements in this Holder object
  protected function getSize() {
    return sizeCallback.invoke();
  }

  //! gets the raw text value at the requested index
  protected function getTextValue(index) {
    return textValueCallback.invoke(index);
  }

  //! get the index based on the value
  protected function getIndex(value) {
    return indexCallback.invoke(value);
  }
}

class FixedValuesFactory extends ValueHolder {
  hidden var mValues as Array<String>;

  (:typecheck(false))
  function initialize(values, settingsId, options) {
    mValues = values;
    mCurrentSelection = Settings.get(settingsId);

    if (options == null) {
      options = {};
    }
    options[:size] = method(:getSize);
    options[:index] = method(:getIndex);
    options[:textValue] = method(:getTextValue);
    options[:settingsValue] = method(:getSettingsValue);
    ValueHolder.initialize(settingsId, options);
  }

  protected function getTextValue(index) {
    return mValues[index].toString();
  }

  function getSettingsValue(index) {
    return index;
  }

  function getIndex(value) {
    return mValues.indexOf(value);
  }

  function getSize() {
    return mValues.size();
  }
}

class DataFieldFactory extends ValueHolder {
  hidden var mValues as Array<Number>;

  (:typecheck(false))
  function initialize(values, settingsId, options) {
    mValues = values;
    mCurrentSelection = getIndex(Settings.get(settingsId));

    if (options == null) {
      options = {};
    }
    options[:size] = method(:getSize);
    options[:index] = method(:getIndex);
    options[:textValue] = method(:getTextValue);
    options[:settingsValue] = method(:getSettingsValue);
    ValueHolder.initialize(settingsId, options);
  }

  protected function getTextValue(index) {
    return Settings.resource(DataFieldRez[mValues[index]]);
  }

  function getSettingsValue(index) {
    return mValues[index];
  }

  function getIndex(value) {
    return mValues.indexOf(value);
  }

  function getSize() {
    return mValues.size();
  }
}

class NumberFactory extends ValueHolder {
  hidden var mStart;
  hidden var mStop;
  hidden var mIncrement;

  hidden var mFormatString;

  (:typecheck(false))
  function initialize(start, stop, increment, settingsId, options) {
    mStart = start;
    mStop = stop;
    mIncrement = increment;
    mCurrentSelection = getIndex(Settings.get(settingsId));

    if (options == null) {
      options = {};
    }
    mFormatString = options.hasKey(:format) ? options[:format] : "%d";

    options[:size] = method(:getSize);
    options[:index] = method(:getIndex);
    options[:textValue] = method(:getTextValue);
    options[:settingsValue] = method(:getSettingsValue);

    ValueHolder.initialize(settingsId, options);
  }

  protected function getTextValue(index) {
    return getSettingsValue(index).format(mFormatString);
  }

  function getSettingsValue(index) {
    return mStart + index * mIncrement;
  }

  function getIndex(value) {
    return (value - mStart) / mIncrement;
  }

  function getSize() {
    return (mStop - mStart) / mIncrement + 1;
  }
}
