import QtQuick 2.15
import QtQuick.Window 2.15

import 'controls'

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Storybook")

    Storybook {
        id: storybook
        anchors.fill: parent
        anchors.margins: 10

        /**
         * Point this to your project root, or QMLStorybook's root (where main.qml is)
         */
        property string rootPath: '..'

        otherAssets: [
            { 'callback':function(path){}, 'path':rootPath+'/main.qml' },
            { 'callback':function(path){}, 'path':rootPath+'/controls/MCalendarDayDelegate.qml' },
            { 'callback':function(path){}, 'path':rootPath+'/controls/Style.qml' }
        ]
        sourcePath: rootPath+'/controls/'
        sources: [
            { 'name': 'MButton',
              'source': 'MButton.qml',
              'instances': [
                    { 'properties': {'text':'Sample text'} },
                    { 'properties': {'text':'Padded Button', 'leftPadding':20} },
                    { 'properties': {'image.source': 'https://cdn.iconscout.com/icon/free/png-256/testing-2-456361.png'} },
                    { 'properties': {'text':'Checkable', 'checkable':true}, 'bindSignals': function(obj) {
                        obj.checkedChanged.connect( function() { storybook.log(`Button checked: ${obj.checked}`); } );
                    } },
                    { 'properties': {'text':'Checkable Decorated', 'checkable':true, 'checked':true, 'decoratorPosition':Qt.RightEdge}, 'bindSignals': function(obj) {
                        obj.checkedChanged.connect( function() { storybook.log(`Button checked: ${obj.checked}`); } );
                    } }
              ],
              'bindSignals': function(obj) {
                  obj.clicked.connect( function() { storybook.log("Button clicked."); } );
              }
            },
            { 'name':'MCalendar',
              'source':'MCalendar.qml',
              'instances': [
                    { 'properties':{'height':320, 'width':240} }
              ],
              'bindSignals': function(obj) {
                  obj.timestampChanged.connect( function() { storybook.log(`Calendar is now set to ${obj.timestamp}`); } );
              }
            },
            { 'name':'MCheckBox',
                'source':'MCheckBox.qml',
                'instances': [
                    { 'properties':{'text':'I am MCheckBox'} }
                ],
                'bindSignals': function(obj) {
                    obj.checkedChanged.connect( function() { storybook.log(`Checkbox checked: ${obj.checked}`); } );
                },
                'notes': "**MCheckBox** inherits **MButton** and reuses the signals and properties therein."
            },
            {
                'name':'ChatMessage',
                'source':'ChatMessage.qml',
                'instances': [
                    { 'properties':{ 'username':'Vaultgirl', 'timestamp':'Tue, Nov 8 @ 12:43pm', 'contents':"Well well well, what do we have here? Now I'm going to fill this out so that it wraps, but that's a lot of words (and letters) so this is taking a little while to think of (and type) things.", 'avatar':'https://avatarfiles.alphacoders.com/185/185110.jpg', 'width':600, 'outbound':false } },
                    { 'properties':{ 'username':'You', 'timestamp':'Tue, Nov 8 @ 12:45pm', 'contents':"Well well well, what do we have here? Now I'm going to fill this out so that it wraps, but that's a lot of words (and letters) so this is taking a little while to think of (and type) things.", 'avatar':'https://avatarfiles.alphacoders.com/917/91786.jpg', 'width':600 } }
                ]
            }
        ]
    }

    Component.onCompleted: {
        storybook.controlList.currentIndex = 0;
        storybook.controlList.loadEntry(storybook.sources[0]);
    }
}
