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
  hidden var iconDrawableCallback as Method;

  protected var mSettingsId as Number;
  protected var mSelectionIndex as Number?;

  function initialize(
    settingsId as Number,
    options as
      {
        :prefix as String,
        :suffix as String,
        :size as Method,
        :index as Method,
        :textValue as Method,
        :settingsValue as Method,
        :iconDrawable as Method,
      }?
  ) {
    mSettingsId = settingsId;
    mPrefix = options.hasKey(:prefix) ? options[:prefix] : "";
    mSuffix = options.hasKey(:suffix) ? options[:suffix] : "";
    sizeCallback = options[:size];
    indexCallback = options[:index];
    textValueCallback = options[:textValue];
    settingsValueCallback = options[:settingsValue];
    iconDrawableCallback = options[:iconDrawable];
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

  function getIconDrawable(index as Number) as Drawable? {
    return iconDrawableCallback.invoke(index);
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
    settingsId as Number,
    options as
      {
        :prefix as String,
        :suffix as String,
      }?
  ) {
    mValues = values;
    mSelectionIndex = Settings.get(settingsId) as Number;

    if (options == null) {
      options = {};
    }
    options[:size] = method(:getSize);
    options[:index] = method(:getIndex);
    options[:textValue] = method(:getTextValue);
    options[:settingsValue] = method(:getSettingsValue);
    options[:iconDrawable] = method(:getIconDrawable);
    ValueHolder.initialize(settingsId, options);
  }

  protected function getTextValue(index as Number) as String {
    return mValues[index].toString();
  }

  function getSettingsValue(index as Number) as Number {
    return index;
  }

  function getIconDrawable(index as Number) as Drawable? {
    return null;
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
    settingsId as Number,
    options as
      {
        :prefix as String,
        :suffix as String,
      }?
  ) {
    mValues = values;
    mSelectionIndex = getIndex(Settings.get(settingsId) as Number);

    if (options == null) {
      options = {};
    }
    options[:size] = method(:getSize);
    options[:index] = method(:getIndex);
    options[:textValue] = method(:getTextValue);
    options[:settingsValue] = method(:getSettingsValue);
    options[:iconDrawable] = method(:getIconDrawable);
    ValueHolder.initialize(settingsId, options);
  }

  protected function getTextValue(index as Number) as String {
    var DataFieldRez = [
      /*  0 */ Rez.Strings.NoDataField,
      /*  1 */ Rez.Strings.DataFieldSteps,
      /*  2 */ Rez.Strings.DataFieldBattery,
      /*  3 */ Rez.Strings.DataFieldCalories,
      /*  4 */ Rez.Strings.DataFieldActiveMinutes,
      /*  5 */ Rez.Strings.DataFieldHeartRate,
      /*  6 */ Rez.Strings.DataFieldMessages,
      /*  7 */ Rez.Strings.DataFieldFloorsUp,
      /*  8 */ Rez.Strings.DataFieldFloorsDown,
      /*  9 */ Rez.Strings.DataFieldBluetooth,
      /* 10 */ Rez.Strings.DataFieldAlarms,
      /* 11 */ Rez.Strings.DataFieldBodyBattery,
      /* 12 */ Rez.Strings.DataFieldSeconds,
      /* 13 */ Rez.Strings.DataFieldStressLevel,
    ];
    return Settings.resource(DataFieldRez[mValues[index]]).toString();
  }

  function getSettingsValue(index as Number) as Number {
    return mValues[index];
  }

  function getIconDrawable(index as Number) as Drawable? {
    return DataFieldInfo.getIconDrawableForType(mValues[index], null);
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
    settingsId as Number,
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
    mSelectionIndex = getIndex(Settings.get(settingsId) as Number);

    if (options == null) {
      options = {};
    }
    mFormatString = options.hasKey(:format) ? options[:format] : "%d";

    options[:size] = method(:getSize);
    options[:index] = method(:getIndex);
    options[:textValue] = method(:getTextValue);
    options[:settingsValue] = method(:getSettingsValue);
    options[:iconDrawable] = method(:getIconDrawable);

    ValueHolder.initialize(settingsId, options);
  }

  protected function getTextValue(index as Number) as String {
    return getSettingsValue(index).format(mFormatString);
  }

  function getSettingsValue(index as Number) as Number {
    return mStart + index * mIncrement;
  }

  function getIconDrawable(index as Number) as Drawable? {
    return null;
  }

  function getIndex(value as Number) as Number {
    return (value - mStart) / mIncrement;
  }

  function getSize() as Number {
    return (mStop - mStart) / mIncrement + 1;
  }
}
