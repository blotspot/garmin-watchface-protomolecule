import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;
import Config;

class SecondaryDataField extends DataFieldDrawable {
  private var _offsetMod as Numeric;
  private var _color as Number;

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
        :position as Number,
        :x as Numeric,
        :y as Numeric,
        :color as Config.Color,
        :drawWidth as Number,
        :drawHeight as Number,
      }
  ) {
    //! redefine locX / locY.
    //! Doing it the stupid way because the layout isn't allowing a `dc` call in their definition.
    params[:locX] = params[:x] * params[:drawWidth];
    params[:locY] = params[:y] * params[:drawHeight];
    DataFieldDrawable.initialize(params);

    var pos = params[:position];
    _offsetMod = pos == 2 ? 0 : pos == 1 ? 0.5 : 1;
    _color = params.hasKey(:color) ? $.themeColor(params[:color]) : Graphics.COLOR_WHITE;

    if (self has :setHitbox && !Settings.useSleepTimeLayout() && !Settings.lowPowerMode) {
      setHitbox();
    }
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      DataFieldDrawable.drawDataField(dc, false);
    }
  }

  protected function drawDataField(dc, partial as Boolean) {
    //! stroke width acts as buffer used in the clipping region and between icon and text
    var dim = getDimensions(dc);
    setClippingRegion(dc, dim);

    if (partial) {
      clearForPartialUpdate(dc);
    }
    if (mLastInfo.progress == 0) {
      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(_color, Graphics.COLOR_TRANSPARENT);
    }

    var offsetX = dim[0] * _offsetMod + Settings.PEN_WIDTH / 2d;
    mLastInfo.icon.drawAt(dc, locX - offsetX + Settings.ICON_SIZE / 2d /* icon will be centered at x, so add half icon size */, locY);
    if (mLastInfo.text != null) {
      dc.drawText(
        locX - offsetX + Settings.ICON_SIZE + Settings.PEN_WIDTH,
        locY - 1, // just txt font things :shrug:
        Settings.resource(Rez.Fonts.SecondaryIndicatorFont),
        mLastInfo.text,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  protected function setClippingRegion(dc, dim as Array<Numeric>) {
    var offsetX = dim[0] * _offsetMod;
    dc.setClip(locX - offsetX, locY - dim[1] / 2, dim[0], dim[1]);
  }

  (:onPressComplication)
  protected function setHitbox() {
    var width = Settings.ICON_SIZE * 2.7;
    var height = Settings.ICON_SIZE * 1.5;

    mHitbox = {
      :width => width,
      :height => height,
      :x => locX - width * _offsetMod - Settings.PEN_WIDTH,
      :y => locY - height / 2,
    };
  }

  private function clearForPartialUpdate(dc) {
    // clear with background color so we don't draw over existing text
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
  }

  private function getDimensions(dc) as Array<Numeric> {
    var textWidth = 0;
    if (mLastInfo.text != null) {
      textWidth = dc.getTextWidthInPixels(mLastInfo.text, Settings.resource(Rez.Fonts.SecondaryIndicatorFont));
    }
    var fieldWidth = textWidth + Settings.ICON_SIZE + Settings.PEN_WIDTH * 2;
    // NOTE: +1 makes me less nervous about the bounds on 218x218 size displays and that's a good thing
    return [fieldWidth, Settings.ICON_SIZE + Settings.PEN_WIDTH * 2 + 1];
  }
}
