import QtQuick 2.15

Rectangle {
    id: topButtonRect
    property alias font: label.font
    property alias text: label.text
    property alias horizontalAlignment: label.horizontalAlignment
    property alias verticalAlignment: label.verticalAlignment
    property alias leftPadding: label.leftPadding
    property alias image: image
    property bool checkable: false
    property bool checked: false
    property bool showAsPressed: false

    signal clicked()

    implicitWidth: label.text.length > 0 ? label.implicitWidth + 24 : 28
    implicitHeight: label.text.length > 0 ? label.implicitHeight + 16 : 28

    color: (showAsPressed || mouseArea.pressed) ? Style.buttonBGPressedColour :
                    (checked ? Style.buttonBGCheckedColour :
                               (mouseArea.containsMouse ? Style.buttonBGHoverColour : Style.buttonBGColour)
                    )
    //clip: true

    border {
        width: 1
        color: Style.buttonBorderColour
    }
    radius: 4

    Keys.onSpacePressed: clicked();
    Keys.onReturnPressed: clicked();

    Rectangle {
        id: borderRectFocused
        anchors.fill: parent
        anchors.margins: 2
        radius: 4
        border {
            width: 1
            color: parent.color == Style.buttonBGCheckedColour ? Style.buttonBGHoverColour : Style.buttonBorderColour
        }
        color: 'transparent'
        visible: parent.activeFocus
    }

    Text {
        id: label
        anchors.fill: parent
        anchors.margins: 6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: Style.buttonFontSize
        font.family: Style.buttonFontFamily
        elide: Text.ElideRight
        color: topButtonRect.enabled ? Style.buttonTextColour : Style.buttonTextDisabledColour
    }

    Image {
        id: image
        width: 24
        height: 24
        sourceSize.width: width
        sourceSize.height: height
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            if( parent.checkable )
                parent.checked = !parent.checked;

            parent.clicked();
        }
        hoverEnabled: parent.enabled
    }
}
