import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import DataFieldInfo;

class DataFieldDrawable extends WatchUi.Drawable {
  hidden var mFieldId as Number;
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
        :fieldId as Number,
      }
  ) {
    Drawable.initialize(params);

    mFieldId = params[:fieldId];
  }

  function draw(dc as Graphics.Dc) {
    mLastInfo = DataFieldInfo.getInfoForField(mFieldId);
  }

  function drawPartialUpdate(dc as Graphics.Dc, drawCallback as Method) {
    var currentInfo = DataFieldInfo.getInfoForField(mFieldId);
    if (currentInfo != null && !currentInfo.equals(mLastInfo)) {
      mLastInfo = currentInfo;
      drawCallback.invoke(dc); // invoke `update(dc)` method of child class
    }
  }
}
