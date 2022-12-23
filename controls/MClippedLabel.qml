import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: clippedlabel
    clip: true
    property alias text: label.text
    property alias font: label.font
    property alias color: label.color
    property alias verticalAlignment: label.verticalAlignment
    property alias horizontalAlignment: label.horizontalAlignment
    property bool centered: false
    property bool running: true
    property alias style: label.style
    property alias styleColor: label.styleColor

    implicitHeight: label.implicitHeight + 10
    implicitWidth: label.implicitWidth + 10

    Item {
        id: labelContainer
        anchors.fill: parent
        //border.width: 1
        //border.color: 'blue'
        Text {
            id: label
            width: parent.width
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }

        clip: true
        visible: false
    }

    Item {
        id: maskRect
        anchors.fill: parent
        LinearGradient {
            id: maskRight
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            width: scrollAnimation.running ? 10 : 0
            start: Qt.point(0, 0)
            end: Qt.point(10, 0)
            gradient: Gradient {
                GradientStop { position: 0.0; color: 'black' }
                GradientStop { position: 1.0; color: 'transparent' }
            }
            visible: true
            opacity: ( label.x + label.contentWidth >= clippedlabel.width ) ?
                         1 - (10 / (20-(label.contentWidth - clippedlabel.width)))
                       : 1
        }
        LinearGradient {
            id: maskLeft
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }
            width: scrollAnimation.running ? 10 : 0
            start: Qt.point(0, 0)
            end: Qt.point(10, 0)
            gradient: Gradient {
                GradientStop { position: 0.0; color: 'transparent' }
                GradientStop { position: 1.0; color: 'black' }
            }
            visible: true
            opacity: ( label.x < 5 && label.x > 0 ) ? 1 - (label.x / 5) : 1
        }
        Rectangle {
            color: 'white'
            anchors {
                top: parent.top
                left: maskLeft.right
                right: maskRight.left
                bottom: parent.bottom
            }
        }
        visible: false
    }

    OpacityMask {
        id: labelMask
        anchors.fill: parent
        source: labelContainer
        maskSource: maskRect
        visible: true
    }

    SequentialAnimation {
        id: scrollAnimation
        running: clippedlabel.running && label.contentWidth > (clippedlabel.width - 10)
        loops: Animation.Infinite
        PropertyAnimation {
            target: label
            properties: 'x'
            to: 0 - (label.contentWidth - clippedlabel.width) - 10
            duration: (label.contentWidth - clippedlabel.width - 20) > 0 ? 40 * (label.contentWidth - clippedlabel.width + 20) : 1000
        }
        PauseAnimation { duration: 500; }
        PropertyAnimation {
            target: label
            properties: 'x'
            to: 10
            duration: (label.contentWidth - clippedlabel.width - 20) > 0 ? 20 * (label.contentWidth - clippedlabel.width + 20) : 1000
        }
        PauseAnimation { duration: 500; }
    }

/*  Debugging:

    Text {
        anchors {
            top: parent.top
            left: parent.left
        }
        text: ''+(maskLeft.opacity.toFixed(2))
        color: 'yellow'
        font.pointSize: 6
    }
*/
}
