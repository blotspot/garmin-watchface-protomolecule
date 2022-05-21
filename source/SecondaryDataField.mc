using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Application;
using Color;

class SecondaryDataField extends DataFieldDrawable {

  hidden var mOffsetMod;

  hidden var mYPos;
  hidden var mXPos;

  function initialize(params) {
    DataFieldDrawable.initialize(params);

    mFieldId = params[:fieldId];
    mOffsetMod = params[:offsetModifier];
    mXPos = params[:xPos];
    mYPos = params[:yPos];
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    if (mLastInfo != null) {
      update(dc);
    }
  }

  function update(dc) {
    var fieldWidth = dc.getTextWidthInPixels(mLastInfo.text, Settings.textFont()) + Settings.get(:iconSize);
    var offset = fieldWidth * mOffsetMod;
    setClippingRegion(dc, offset, Settings.get(:strokeWidth));

    if (mLastInfo.text.equals("0")) {
      dc.setColor(themeColor(Color.TEXT_INACTIVE), Graphics.COLOR_TRANSPARENT);
    }

    mLastInfo.icon.invoke(dc, mXPos - offset + (Settings.get(:iconSize) / 2.0), mYPos, Settings.get(:iconSize), Settings.get(:strokeWidth), mLastInfo.text);
    drawText(dc, mLastInfo.text, Settings.textFont(), mXPos - offset + Settings.get(:iconSize) + Settings.get(:strokeWidth));
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
    dc.setColor(themeColor(Color.TEXT_ACTIVE), themeColor(Color.BACKGROUND));
    dc.setClip(
      mXPos - offset,
      mYPos - contentDimensions[1] / 2 - penSize / 2,
      contentDimensions[0] + penSize,
      contentDimensions[1] + penSize
    );
    dc.clear();
  }

  function getDimensions(dc) {
    var dim = dc.getTextDimensions("000", Settings.textFont());
    dim[0] = dim[0] + Settings.get(:iconSize);
    if (dim[1] < Settings.get(:iconSize)) {
      dim[1] = Settings.get(:iconSize);
    }

    return dim;
  }
}