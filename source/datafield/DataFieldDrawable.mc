import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import DataFieldInfo;
import Enums;

class DataFieldDrawable extends WatchUi.Drawable {
  hidden var mFieldId as FieldId;
  hidden var mLastInfo as DataFieldProperties? = null;
  hidden var mClipX as Numeric?;
  hidden var mClipY as Numeric?;
  hidden var mClipWidth as Numeric?;
  hidden var mClipHeight as Numeric?;

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

  private function isInHitbox(x as Number, y as Number) as Boolean {
    return x >= mClipX && x <= mClipX + mClipWidth && y >= mClipY && y <= mClipY + mClipHeight;
  }

  public function getComplicationForCoordinates(x as Number, y as Number) {
    if (mLastInfo != null && isInHitbox(x, y)) {
      Log.debug("Hit DataFieldDrawable id=" + mFieldId);
      return null;
    }
    return null;
  }
}
