import QtQuick

Rectangle {
    required property var model
    property Item monthGrid: parent
    property alias label: dayLabel
    signal clicked()
    color: 'transparent'
    border.width: 1

    implicitWidth: dayLabel.implicitWidth
    implicitHeight: dayLabel.implicitHeight + 4
    property variant timestamp: new Date(model.year, model.month, model.day, 12, 0, 0, 0)
    Text {
        id: dayLabel
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: model.month === monthGrid.month ? 1 : 0.33
        text: model.day
    }
    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}
