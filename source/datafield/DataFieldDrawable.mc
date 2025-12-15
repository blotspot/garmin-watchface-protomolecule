import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import DataFieldInfo;
import Enums;

class DataFieldDrawableAbstract extends WatchUi.Drawable {
  hidden var mFieldId as FieldId;
  hidden var mLastInfo as DataFieldProperties? = null;

  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Numeric,
        :locY as Numeric,
        :width as Numeric,
        :height as Numeric,
        :visible as Boolean,
        :fieldId as FieldId,
      }
  ) {
    mFieldId = params[:fieldId];
    Drawable.initialize(params);
  }

  function draw(dc) {
    mLastInfo = DataFieldInfo.getInfoForField(mFieldId);
  }

  function drawPartialUpdate(dc, drawCallback as Method) {
    var currentInfo = DataFieldInfo.getInfoForField(mFieldId);
    if (currentInfo != null && !currentInfo.equals(mLastInfo)) {
      mLastInfo = currentInfo;
      drawCallback.invoke(dc, true); // invoke `update(dc)` method of child class
    }
  }
}

(:apiBelow420)
class DataFieldDrawable extends DataFieldDrawableAbstract {
  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Numeric,
        :locY as Numeric,
        :width as Numeric,
        :height as Numeric,
        :visible as Boolean,
        :fieldId as FieldId,
      }
  ) {
    DataFieldDrawableAbstract.initialize(params);
  }
}

(:api420AndAbove)
class DataFieldDrawable extends DataFieldDrawableAbstract {
  hidden var mHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;

  function initialize(
    params as
      {
        :identifier as Object,
        :locX as Numeric,
        :locY as Numeric,
        :width as Numeric,
        :height as Numeric,
        :visible as Boolean,
        :fieldId as FieldId,
      }
  ) {
    DataFieldDrawableAbstract.initialize(params);
  }

  (:debug)
  hidden function drawHitbox(dc, color) {
    dc.setPenWidth(1);
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    dc.drawRectangle(mHitbox[:x], mHitbox[:y], mHitbox[:width], mHitbox[:height]);
  }

  private function isInHitbox(x as Number, y as Number) as Boolean {
    return x >= mHitbox[:x] && x <= mHitbox[:x] + mHitbox[:width] && y >= mHitbox[:y] && y <= mHitbox[:y] + mHitbox[:height];
  }

  public function getComplicationForCoordinates(x as Number, y as Number) {
    if (mLastInfo != null && isInHitbox(x, y)) {
      Log.debug("Hit DataFieldDrawable id=" + mLastInfo.fieldType);
      var complicationType = mLastInfo.getComplicationType();
      if (complicationType != null && complicationType != Toybox.Complications.COMPLICATION_TYPE_INVALID) {
        return new Complications.Id(complicationType);
      }
    }
    return null;
  }
}
