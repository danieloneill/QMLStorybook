import QtQuick
import QtQuick.Controls

TextField {
    readonly property bool modified: ( origText.length > 0 && origText !== text )

    property string origText
    function setText(newText)
    {
        origText = text = newText;
    }

    function revert()
    {
        text = origText;
    }

    Image {
        id: undoImage
        visible: parent.modified
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 5
        }
        source: Material.theme == Material.Dark ? '../../images/icons/undo icon white.png' : '../../images/icons/undo icon.png'
        MouseArea {
            anchors.fill: parent
            onClicked: revert();
        }
    }
}
