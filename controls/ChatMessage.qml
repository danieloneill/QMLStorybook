import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import QtGraphicalEffects 1.15

Item {
    id: message

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.height

    property string username
    property string avatar
    property string timestamp
    property string presence
    property string contents
    property bool outbound: true

    readonly property color fgColour: outbound ? '#000000' : '#000000'
    readonly property color bgColour: outbound ? '#cabada' : '#d4d4ea'

    RowLayout {
        id: mainLayout

        width: parent.width * 0.8
        //implicitHeight: contentColumn.height > avatarItem.height ? contentColumn.height : avatarItem.height

        anchors {
            right: outbound ? parent.right : undefined
            left: outbound ? undefined : parent.left
        }

        Item {
            id: avatarItem

            implicitHeight: 48
            implicitWidth: 48

            Image {
                id: avatarImage
                source: avatar
                sourceSize.width: 48
                sourceSize.height: 48
                width: 48
                height: 48
                visible: false
            }

            Rectangle {
                id: mask
                radius: 90
                color: 'black'
                width: 48
                height: 48
                visible: false
            }

            OpacityMask {
                width: 48
                height: 48
                source: avatarImage
                maskSource: mask
            }

            Rectangle {
                width: 10
                height: 10
                radius: 90
                color: 'white'
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }

                Rectangle {
                    anchors {
                        fill: parent
                        margins: 1.5
                    }
                    radius: 90
                    color: presence === 'online' ? 'green' :
                           presence === 'away' ? 'yellow' :
                           presence === 'dnd' ? 'blue' :
                           presence === 'offline' ? 'red' :
                           'magenta'
                }
            }
        }

        ColumnLayout {
            id: contentColumn

            spacing: 3
            Layout.fillWidth: true

            RowLayout {
                id: unameRow
                Label {
                    id: labelUsername
                    Layout.fillWidth: true
                    text: username
                    font.bold: true
                    font.pointSize: 11
                }

                Label {
                    Layout.alignment: Qt.AlignBottom
                    text: timestamp
                    font.pointSize: 7
                    color: '#707070'
                }
            }

            Rectangle {
                id: contentRect
                radius: 3
                color: bgColour

                Layout.fillWidth: true
                implicitHeight: content.implicitHeight + 10

                Text {
                    id: content
                    anchors.margins: 5
                    anchors.fill: parent
                    width: parent.width
                    text: contents
                    color: fgColour
                    wrapMode: Text.WordWrap
                }
            }
        } // ColumnLayout
    } // RowLayout

    Rectangle {
        id: popupBox

        radius: 3
        color: '#339a9a9a'
        height: 42
        width: 74

        anchors {
            rightMargin: 5
            right: mainLayout.right
            top: parent.bottom
            topMargin: hoverBox.containsMouse ? -5 : -25
        }

        Behavior on anchors.topMargin {
            PropertyAnimation { duration: 250 }
        }

        opacity: hoverBox.containsMouse ? 1.0 : 0.0
        Behavior on opacity {
            PropertyAnimation { duration: 250 }
        }
    }

    MouseArea {
        id: hoverBox
        anchors {
            rightMargin: 5
            right: mainLayout.right
            top: parent.bottom
            topMargin: -10
        }
        height: containsMouse ? popupBox.height + 10 : 20
        width: popupBox.width + 10
        enabled: !outbound

        hoverEnabled: true
        onContainsMouseChanged: {
            console.log(`I do ${containsMouse ? '' : 'not '}contain the cursor.`);
        }
    }
}
