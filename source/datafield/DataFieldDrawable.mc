import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import DataFieldInfo;
import Config;

class DataFieldDrawable extends WatchUi.Drawable {
  protected var mFieldId as FieldId;
  protected var mLastInfo as DataFieldProperties? = null;

  (:onPressComplication)
  protected var mHitbox as { :x as Numeric, :y as Numeric, :width as Numeric, :height as Numeric }?;

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

  (:mipDisplay)
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
    if (self has :mHitbox && mHitbox != null && self has :drawHitbox) {
      drawHitbox(dc, Graphics.COLOR_BLUE);
    }
    $.saveSetAntiAlias(dc, false);
  }

  (:debug,:onPressComplication)
  protected function drawHitbox(dc, color) {
    dc.setPenWidth(1);
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    dc.drawRoundedRectangle(mHitbox[:x], mHitbox[:y], mHitbox[:width], mHitbox[:height], Settings.ICON_SIZE * 0.5);
  }

  (:onPressComplication)
  protected function isInHitbox(x as Number, y as Number) as Boolean {
    return x >= mHitbox[:x] && x <= mHitbox[:x] + mHitbox[:width] && y >= mHitbox[:y] && y <= mHitbox[:y] + mHitbox[:height];
  }

  (:onPressComplication)
  public function getComplicationForCoordinates(x as Number, y as Number) as Toybox.Complications.Id? {
    if (mLastInfo != null && isInHitbox(x, y)) {
      var complicationType = mLastInfo.getComplicationType();
      if (complicationType != null && complicationType != Toybox.Complications.COMPLICATION_TYPE_INVALID) {
        return new Complications.Id(complicationType);
      }
    }
    return null;
  }
}
