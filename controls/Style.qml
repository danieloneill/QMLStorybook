pragma Singleton
import QtQuick 2.15
import QtQuick.Controls.Material 2.15

Item {
    FontLoader { id: font_ts; source: "../fonts/TechnaSans-Regular.otf" }
    FontLoader { id: font_mr; source: "../fonts/Mollen-Regular.otf" }
    FontLoader { id: font_geb; source: "../fonts/Gogh-ExtraBold.otf" }

    property string currencySymbol: '$'

    property string buttonFontFamily: font_ts && font_ts.font ? font_ts.font.family : 'sans-serif'
    property int buttonFontSize: 12
    property color buttonBGColour: '#eaeaea'
    property color buttonBGHoverColour: '#fafafa'
    property color buttonBGPressedColour: '#ffffff'
    property color buttonBGCheckedColour: '#dadada'
    property color buttonBorderColour: '#cacaca'
    property color buttonTextColour: '#101010'
    property color buttonTextDisabledColour: '#6a6a6a'

    property string textFieldFontFamily: font_mr && font_mr.font ? font_mr.font.family : 'sans-serif'
    property int textFieldFontSize: 12
    property color textFieldBGColour: '#fafafa'
    property color textFieldBGFocusColour: '#fdfdfd'
    property color textFieldBorderColour: buttonBorderColour
    property color textFieldBorderFocusColour: '#8a7a9a'
    property color textFieldBGSelectedColour: '#8a7a9a'
    property color textFieldBGModified: '#22ff0000'

    property string textFontFamily: font_mr && font_mr.font ? font_mr.font.family : 'sans-serif'
    property color textLabelColour: '#ff442454'
    property int textFontSize: 12

    property color frameBorderColour: buttonBorderColour
    property color frameBGColour: buttonBGColour

    property color tableBorderColour: '#dadada'
    property color tableBorderFocusColour: '#8a7a9a'

    property color tableItemBG: '#ffffff'
    property color tableItemBGDark: '#303030'
    property color tableItemBGSelected: '#8a7a9a'
    property real tableItemPadding: 10
}
