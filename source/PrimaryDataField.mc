using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.ActivityMonitor;

class PrimaryDataField extends DataFieldDrawable {

  hidden var mXPos;
  hidden var mYPos;
  hidden var mTextTop;

  hidden var mTextFont;
  hidden var mIconFont;

  function initialize(params) {
    DataFieldDrawable.initialize(params);
    
    mXPos = params[:relativeXPos] * app.gWidth;
    mYPos = params[:relativeYPos] * app.gHeight;

    mTextTop = params[:textTop];

    mTextFont = Ui.loadResource(Rez.Fonts.PrimaryIndicatorFont);
    mIconFont = Ui.loadResource(Rez.Fonts.IconsFont);
  }

  function draw(dc) {
    DataFieldDrawable.draw(dc);
    update(dc);
  }

  function update(dc) {
    setClippingRegion(dc, app.gStrokeWidth);
    dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    var contentDimensions = getDimensions(dc);

    if (mTextTop) {
      drawText(dc, mLastInfo.text, mYPos - (app.gIconSize / 3.0), mTextFont);
      mLastInfo.icon.invoke(
        dc,
        mXPos, 
        mYPos + contentDimensions[1] - app.gIconSize + app.gStrokeWidth,
        app.gIconSize,
        app.gStrokeWidth
      );
    } else {
      mLastInfo.icon.invoke(
        dc,
        mXPos,
        mYPos + (app.gIconSize / 2.0), 
        app.gIconSize, 
        app.gStrokeWidth
      );
      drawText(dc, mLastInfo.text, mYPos + app.gIconSize, mTextFont);
//      drawText(dc, mLastInfo.icon, mYPos, mIconFont);
    }
  }

  function partialUpdate(dc) {
    drawPartialUpdate(dc, method(:update));
  }

  hidden function drawText(dc, text, yPos, font) {
    dc.drawText(mXPos, yPos, font, text, Graphics.TEXT_JUSTIFY_CENTER);
  }

  hidden function setClippingRegion(dc, penSize) {
    dc.setColor(themeColor(mFieldId), Color.BACKGROUND);
    var contentDimensions = getDimensions(dc);
    dc.setClip(
      mXPos - contentDimensions[0] / 2 - penSize / 2,
      mYPos - penSize / 2,
      contentDimensions[0] + penSize,
      contentDimensions[1] + penSize
    );
    dc.clear();
  }

  hidden function getDimensions(dc) {
    var dim = dc.getTextDimensions(mLastInfo.text, mTextFont);
    dim[1] = dim[1] + app.gIconSize + 2;
    if (dim[0] < app.gIconSize) {
      dim[0] = app.gIconSize;
    }

    return dim;
  }
}