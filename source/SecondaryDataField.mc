using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Application;
using Color;

class SecondaryDataField extends DataFieldDrawable {

  hidden var mOffsetMod;

  hidden var mYPos;
  hidden var mXPos;

  hidden var mTextFont;
  hidden var mIconFont;

  function initialize(params) {
    DataFieldDrawable.initialize(params);

    mFieldId = params[:fieldId];
    mOffsetMod = params[:offsetModifier];
    mXPos = params[:relativeXPos] * app.gWidth;
    mYPos = 0.685 * app.gHeight;

    mTextFont = Ui.loadResource(Rez.Fonts.SecondaryIndicatorFont);
    mIconFont = Ui.loadResource(Rez.Fonts.IconsFont);
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    update(dc);
  }

  function update(dc) {
    var fieldWidth = dc.getTextWidthInPixels(mLastInfo.text, mTextFont) + app.gIconSize;
    var offset = fieldWidth * mOffsetMod;
    setClippingRegion(dc, offset, app.gStrokeWidth);

    if (mLastInfo.text.equals("0")) {
      dc.setColor(Color.INACTIVE, Color.BACKGROUND);
    } else {
      dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    }

    mLastInfo.icon.invoke(dc, mXPos - offset + (app.gIconSize / 2.0), mYPos, app.gIconSize, app.gStrokeWidth);
    drawText(dc, mLastInfo.text, mTextFont, mXPos - offset + app.gIconSize + app.gStrokeWidth);
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
  }

  function drawText(dc, text, font, xPos) {
    dc.drawText(
      xPos,
      mYPos - 1,
      font,
      text,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function setClippingRegion(dc, offset, penSize) {
    var contentDimensions = getDimensions(dc);
    dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    dc.setClip(
      mXPos - offset,
      mYPos - contentDimensions[1] / 2 - penSize / 2,
      contentDimensions[0] + penSize,
      contentDimensions[1] + penSize
    );
    dc.clear();
  }

  function getDimensions(dc) {
    var dim = dc.getTextDimensions(mLastInfo.text, mTextFont);
    dim[0] = dim[0] + app.gIconSize;
    if (dim[1] < app.gIconSize) {
      dim[1] = app.gIconSize;
    }

    return dim;
  }
}