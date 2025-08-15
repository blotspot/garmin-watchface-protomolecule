import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class ValueHolder {
  hidden var mPrefix as String;
  hidden var mSuffix as String;
  hidden var sizeCallback as Method;
  hidden var indexCallback as Method;
  hidden var textValueCallback as Method;
  hidden var settingsValueCallback as Method;

  protected var mSettingsId as Symbol;
  protected var mSelectionIndex as Number?;

  function initialize(
    settingsId as Symbol,
    options as
      {
        :prefix as String,
        :suffix as String,
        :size as Method,
        :index as Method,
        :textValue as Method,
        :settingsValue as Method,
      }?
  ) {
    mSettingsId = settingsId;
    mPrefix = options.hasKey(:prefix) ? options[:prefix] : "";
    mSuffix = options.hasKey(:suffix) ? options[:suffix] : "";
    sizeCallback = options[:size];
    indexCallback = options[:index];
    textValueCallback = options[:textValue];
    settingsValueCallback = options[:settingsValue];
    if (mSelectionIndex == null) {
      mSelectionIndex = 0;
    }
  }

  function getLabel(index) as String {
    return mPrefix + getTextValue(index) + mSuffix;
  }

  function getIndexOfCurrentSelection() as Number {
    return mSelectionIndex;
  }

  function save(index) as Void {
    Settings.set(mSettingsId, getSettingsValue(index));
  }

  //! get the settings value of the element at this index.
  function getSettingsValue(index as Number) as Number {
    return settingsValueCallback.invoke(index);
  }

  //! get the amount of elements in this Holder object
  function getSize() as Number {
    return sizeCallback.invoke();
  }

  //! gets the raw text value at the requested index
  protected function getTextValue(index as Number) as String {
    return textValueCallback.invoke(index);
  }

  //! get the index based on the value
  protected function getIndex(value) as Number {
    return indexCallback.invoke(value);
  }
}

class FixedValuesFactory extends ValueHolder {
  hidden var mValues as Array<String>;

  function initialize(
    values as Array<String>,
    settingsId as Symbol,
    options as
      {
        :prefix as String,
        :suffix as String,
      }?
  ) {
    mValues = values;
    mSelectionIndex = Settings.get(settingsId);

    if (options == null) {
      options = {};
    }
    options[:size] = method(:getSize);
    options[:index] = method(:getIndex);
    options[:textValue] = method(:getTextValue);
    options[:settingsValue] = method(:getSettingsValue);
    ValueHolder.initialize(settingsId, options);
  }

  protected function getTextValue(index as Number) as String {
    return mValues[index].toString();
  }

  function getSettingsValue(index as Number) as Number {
    return index;
  }

  function getIndex(value as String) as Number {
    return mValues.indexOf(value);
  }

  function getSize() as Number {
    return mValues.size();
  }
}

class DataFieldFactory extends ValueHolder {
  hidden var mValues as Array<Number>;

  function initialize(
    values as Array<Number>,
    settingsId as Symbol,
    options as
      {
        :prefix as String,
        :suffix as String,
      }?
  ) {
    mValues = values;
    mSelectionIndex = getIndex(Settings.get(settingsId));

    if (options == null) {
      options = {};
    }
    options[:size] = method(:getSize);
    options[:index] = method(:getIndex);
    options[:textValue] = method(:getTextValue);
    options[:settingsValue] = method(:getSettingsValue);
    ValueHolder.initialize(settingsId, options);
  }

  protected function getTextValue(index as Number) as String {
    return Settings.resource(DataFieldRez[mValues[index]]).toString();
  }

  function getSettingsValue(index as Number) as Number {
    return mValues[index];
  }

  function getIndex(value as Number) as Number {
    return mValues.indexOf(value);
  }

  function getSize() as Number {
    return mValues.size();
  }
}

class NumberFactory extends ValueHolder {
  hidden var mStart as Number;
  hidden var mStop as Number;
  hidden var mIncrement as Number;

  hidden var mFormatString as String;

  function initialize(
    start as Number,
    stop as Number,
    increment as Number,
    settingsId as Symbol,
    options as
      {
        :prefix as String,
        :suffix as String,
        :format as String,
      }?
  ) {
    mStart = start;
    mStop = stop;
    mIncrement = increment;
    mSelectionIndex = getIndex(Settings.get(settingsId));

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

  protected function getTextValue(index as Number) as String {
    return getSettingsValue(index).format(mFormatString);
  }

  function getSettingsValue(index as Number) as Number {
    return mStart + index * mIncrement;
  }

  function getIndex(value as Number) as Number {
    return (value - mStart) / mIncrement;
  }

  function getSize() as Number {
    return (mStop - mStart) / mIncrement + 1;
  }
}
