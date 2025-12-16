import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import DataFieldInfo;
import Enums;

class DataFieldDrawableAbstract extends WatchUi.Drawable {
  protected var mFieldId as FieldId;
  protected var mLastInfo as DataFieldProperties? = null;

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

  function partialUpdate(dc) {
    var currentInfo = DataFieldInfo.getInfoForField(mFieldId);
    if (currentInfo != null && !currentInfo.equals(mLastInfo)) {
      mLastInfo = currentInfo;
      drawDataField(dc, true);
    }
  }

  protected function drawDataField(dc, partial as Boolean) {
    $.saveSetAntiAlias(dc, true);
    self.drawDataField(dc, partial);
    $.saveSetAntiAlias(dc, false);
  }
}

(:apiBelow420)
class DataFieldDrawable extends DataFieldDrawableAbstract {
  function initialize(params) {
    DataFieldDrawableAbstract.initialize(params);
  }
}

(:api420AndAbove)
class DataFieldDrawable extends DataFieldDrawableAbstract {
  protected var mHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;

  function initialize(params) {
    DataFieldDrawableAbstract.initialize(params);
  }

  (:debug)
  protected function drawHitbox(dc, color) {
    dc.setPenWidth(1);
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    dc.drawRoundedRectangle(mHitbox[:x], mHitbox[:y], mHitbox[:width], mHitbox[:height], Settings.iconSize * 0.5);
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
