import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQml

Item {
    id: storybook

    // This is relative to "storybook.qml" not "Storybook.qml" (this).
    property variant currentSource
    property string sourcePath: './controls/'
    property variant sources: [
        { 'name': 'MButton',
          'source': 'MButton.qml',
          'instances': [
                { 'properties': {'text':'Sample text'} },
                { 'properties': {'text':'Padded Button', 'leftPadding':20} },
                { 'properties': {'image.source': 'https://cdn.iconscout.com/icon/free/png-256/testing-2-456361.png'} },
                { 'properties': {'text':'Checkable', 'checkable':true}, 'bindSignals': function(obj) {
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
                { 'properties':{'text':'MCheckBox'} }
            ],
            'bindSignals': function(obj) {
                obj.checkedChanged.connect( function() { storybook.log(`Checkbox checked: ${obj.checked}`); } );
            },
            'notes': "**MCheckBox** inherits **MButton** and reuses the signals and properties therein."
        },
        { 'name':'MClippedLabel',
          'source':'MClippedLabel.qml',
          'instances': [
            { 'properties':{ 'text':'Test label that should clip, and scroll right to left, then back again.', 'width':180 } }
          ],
        },
        { 'name':'MCurrencyField',
            'source':'MCurrencyField.qml',
            'instances': [
                { 'properties':{ 'value':1.23 } }
            ]
        },
        { 'name':'MFrame',
          'source':'MFrame.qml',
          'instances': [
                { 'properties':{'width':330, 'height':250} }
          ]
        },
    ]

    function controlLoaded(source, obj, instance)
    {
        if( source['bindSignals'] )
            source['bindSignals'](obj);

        if( instance['bindSignals'] )
            instance['bindSignals'](obj);

        notesEdit.text = '';
        if( source['notes'] )
            notesEdit.text = source['notes'];

        if( instance['notes'] )
            notesEdit.text += instance['notes'];

        updateSource(source);

        let w = WASM.watcher();
        w.watch(storybook.sourcePath + source['source']);
        w.fileChanged.connect( function(path) {
            storybook.log(qsTr("File modified. Reloading source..."));
            reloadCurrentSource();
            delete w;
        } );
    }

    Timer {
        id: reloadTimer
        property variant callback
        repeat: false
        onTriggered: function() { callback(); }
        function setTimeout(interval, callback)
        {
            reloadTimer.interval = interval;
            reloadTimer.callback = callback;
            reloadTimer.start();
        }
    }

    function reloadCurrentSource()
    {
        reloadTimer.setTimeout(500, function() {
            storybook.clearCanvas();
            WASM.clearComponentCache();
            storybook.loadSource(storybook.currentSource);
        } );
    }

    function updateSource(source)
    {
        sourceView.text = WASM.readFile(storybook.sourcePath + source['source']);
    }

    function log(str)
    {
        console.log(str);
        logModel.append({'message':str});
        if( logModel.count > 100 )
            logModel.remove(0, logModel.count-100);

        logView.positionViewAtEnd();
    }

    function clearCanvas()
    {
        for( let i=controlContainer.visibleChildren.length; i > 0; i-- )
        {
            let c = controlContainer.visibleChildren[i-1];
            c.destroy();
        }
    }

    function loadSource(source)
    {
        storybook.currentSource = source;

        const controlName = source['name'];
        const instances = source['instances'];
        const bindSignals = source['bindSignals'];

        instances.forEach( function(instance)
        {
            log(`Creating instance of ${controlName} with ${JSON.stringify(instance)}`);
            const component = Qt.createComponent(source['source']);

            const incubator = component.incubateObject(controlContainer, instance['properties']);
            if (incubator.status !== Component.Ready)
            {
                incubator.onStatusChanged = function(status)
                {
                    if (status === Component.Ready)
                    {
                        let obj = incubator.object;
                        controlLoaded(source, obj, instance);
                    }
                };
            } else {
                let obj = incubator.object;
                controlLoaded(source, obj, instance);
            }
        });
    }

    SplitView {
        id: splitter
        anchors.fill: parent

        Item {
            height: splitter.height
            SplitView.preferredWidth: 300
            Pane {
                anchors.fill: parent
                anchors.margins: 5
                Material.elevation: 2

                ListView {
                    id: itemList
                    anchors.fill: parent
                    model: storybook.sources
                    delegate: MenuItem {
                        width: itemList.width
                        text: modelData.name
                        onTriggered: {
                            itemList.currentIndex = index;
                            storybook.clearCanvas();
                            storybook.loadSource(modelData);
                        }
                    }
                }
            }
        }

        SplitView {
            height: splitter.height
            orientation: Qt.Vertical

            Item {
                id: canvas
                SplitView.fillHeight: true

                Pane {
                    id: notesPane
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 5
                    }
                    Material.elevation: 2
                    height: 100
                    visible: false

                    ScrollView {
                        anchors.fill: parent
                        contentWidth: notesEdit.width + 20
                        contentHeight: notesEdit.height + 20

                        TextEdit {
                            id: notesEdit
                            textFormat: TextEdit.MarkdownText
                            readOnly: true
                            onTextChanged: {
                                if( text.length > 0 )
                                    notesPane.visible = true;
                            }
                        }
                    }

                    Button {
                        anchors {
                            top: parent.top
                            right: parent.right
                        }
                        text: '❌'
                        width: height
                        onClicked: notesPane.visible = false;
                    }
                }

                Pane {
                    anchors {
                        top: notesPane.visible ? notesPane.bottom : parent.top
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        margins: 5
                    }
                    Material.elevation: 2

                    ScrollView {
                        anchors.fill: parent
			anchors.margins: 10
                        //flickableDirection: Flickable.HorizontalAndVerticalFlick
                        contentWidth: controlContainer.width + 20
                        contentHeight: controlContainer.height + 20

                        Column {
                            id: controlContainer
                            spacing: 10
                            //anchors.centerIn: parent
                            width: childrenRect.width
                            height: childrenRect.height
                        }
                    }
                }
            }

            Item {
                SplitView.preferredHeight: 300
                Pane {
                    anchors.fill: parent
                    anchors.margins: 5
                    Material.elevation: 2

                    ColumnLayout {
                        anchors.fill: parent
                        TabBar {
                            id: tabBar
                            Layout.fillWidth: true
                            TabButton {
                                text: qsTr('Console')
                            }
                            TabButton {
                                text: qsTr('Source')
                            }
                        }

                        StackLayout {
                            id: stack
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            currentIndex: tabBar.currentIndex
                            Item {
                                ListView {
                                    id: logView
                                    clip: true
                                    anchors.fill: parent
                                    flickableDirection: Flickable.HorizontalAndVerticalFlick
                                    contentWidth: contentItem.childrenRect.width + 20
                                    contentHeight: contentItem.childrenRect.height
                                    model: logModel
                                    delegate: Text {
                                        text: message || 'undefined'
                                    }

                                    ScrollBar.vertical: scrollVertical
                                    ScrollBar.horizontal: scrollHorizontal
                                }

                                ScrollBar {
                                    id: scrollVertical
                                    anchors {
                                        top: parent.top
                                        right: parent.right
                                        bottom: parent.bottom
                                    }
                                }
                                ScrollBar {
                                    id: scrollHorizontal
                                    anchors {
                                        right: parent.right
                                        left: parent.left
                                        bottom: parent.bottom
                                    }
                                }
                            }
                            ScrollView {
                                implicitWidth: stack.width
                                implicitHeight: stack.height
                                contentWidth: sourceView.width+20
                                contentHeight: sourceView.height
                                TextEdit {
                                    id: sourceView
                                }
                            }
                        } // StackLayout
                    } // ColumnLayout
                } // Pane
            } // Item
        } // SplitView
    } // SplitView

    ListModel {
        id: logModel
    }
}
