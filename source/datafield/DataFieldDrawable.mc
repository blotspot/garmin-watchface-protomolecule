import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

class DataFieldDrawable extends WatchUi.Drawable {
  hidden var mFieldId;
  hidden var mLastInfo = null;

  function initialize(params as Object) {
    Drawable.initialize(params);

    mFieldId = params[:fieldId];
  }

  function draw(dc) {
    mLastInfo = DataFieldInfo.getInfoForField(mFieldId);
  }

  function drawPartialUpdate(dc, drawCallback) {
    var currentInfo = DataFieldInfo.getInfoForField(mFieldId);
    if (!currentInfo.equals(mLastInfo)) {
      mLastInfo = currentInfo;
      drawCallback.invoke(dc); // invoke update method of child class
    }
  }
}
