import QtQuick

import 'controls'

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Storybook")

    Storybook {
        anchors.fill: parent
        anchors.margins: 10
        sourcePath: ':/controls/'
    }
}
