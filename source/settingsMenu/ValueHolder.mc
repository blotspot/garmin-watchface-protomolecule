import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Config;

class ValueHolder {
  protected var mPrefix as String;
  protected var mSuffix as String;

  protected var mSettingsId as String;
  protected var mSelectionIndex as Number?;

  function initialize(
    settingsId as String,
    options as
      {
        :prefix as String,
        :suffix as String,
      }?
  ) {
    mSettingsId = settingsId;
    mPrefix = options.hasKey(:prefix) ? options[:prefix] : "";
    mSuffix = options.hasKey(:suffix) ? options[:suffix] : "";
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
    Properties.setValue(mSettingsId, getSettingsValue(index));
  }

  //! get the settings value of the element at this index.
  function getSettingsValue(index as Number) as Number {
    return self.getSettingsValue(index);
  }

  function getIconDrawable(index as Number) as Drawable? {
    return self.getIconDrawable(index);
  }

  //! get the amount of elements in this Holder object
  function getSize() as Number {
    return self.getSize();
  }

  //! gets the raw text value at the requested index
  protected function getTextValue(index as Number) as String {
    return self.getTextValue(index);
  }

  //! get the index based on the value
  protected function getIndex(value) as Number {
    return self.getIndex(value);
  }
}

class FixedValuesFactory extends ValueHolder {
  protected var mValues as Array<String>;

  function initialize(
    values as Array<String>,
    settingsId as String,
    options as
      {
        :prefix as String,
        :suffix as String,
      }?
  ) {
    mValues = values;
    mSelectionIndex = Properties.getValue(settingsId) as Number;

    if (options == null) {
      options = {};
    }
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
  protected var mValues as Array<FieldType>;

  function initialize(
    values as Array<FieldType>,
    settingsId as String,
    options as
      {
        :prefix as String,
        :suffix as String,
      }?
  ) {
    mValues = values;
    mSelectionIndex = getIndex(Properties.getValue(settingsId) as FieldType);

    if (options == null) {
      options = {};
    }
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

  function getIndex(value as FieldType) as Number {
    return mValues.indexOf(value);
  }

  function getSize() as Number {
    return mValues.size();
  }
}

class NumberFactory extends ValueHolder {
  protected var mStart as Number;
  protected var mStop as Number;
  protected var mIncrement as Number;

  protected var mFormatString as String;

  function initialize(
    start as Number,
    stop as Number,
    increment as Number,
    settingsId as String,
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
    mSelectionIndex = getIndex(Properties.getValue(settingsId) as Number);

    if (options == null) {
      options = {};
    }
    mFormatString = options.hasKey(:format) ? options[:format] : "%d";
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
