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
    var fieldWidth = dc.getTextWidthInPixels(mLastInfo.text, app.gTextFont) + app.gIconSize;
    var offset = fieldWidth * mOffsetMod;
    setClippingRegion(dc, offset, app.gStrokeWidth);

    if (mLastInfo.text.equals("0")) {
      dc.setColor(themeColor(Color.SECONDARY_INACTIVE), Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(themeColor(Color.SECONDARY_ACTIVE), Graphics.COLOR_TRANSPARENT);
    }

    mLastInfo.icon.invoke(dc, mXPos - offset + (app.gIconSize / 2.0), mYPos, app.gIconSize, app.gStrokeWidth, mLastInfo.text);
    drawText(dc, mLastInfo.text, app.gTextFont, mXPos - offset + app.gIconSize + app.gStrokeWidth);
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
    dc.setColor(themeColor(mFieldId), themeColor(Color.BACKGROUND));
    dc.setClip(
      mXPos - offset,
      mYPos - contentDimensions[1] / 2 - penSize / 2,
      contentDimensions[0] + penSize,
      contentDimensions[1] + penSize
    );
    dc.clear();
  }

  function getDimensions(dc) {
    var dim = dc.getTextDimensions(mLastInfo.text, app.gTextFont);
    dim[0] = dim[0] + app.gIconSize;
    if (dim[1] < app.gIconSize) {
      dim[1] = app.gIconSize;
    }

    return dim;
  }
}