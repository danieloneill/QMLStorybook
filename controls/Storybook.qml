import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Item {
    id: storybook

    // This is relative to "storybook.qml" not "Storybook.qml" (this).
    property string sourcePath: '.'
    property variant otherAssets: []

    // The model of your controls.
    property variant sources: []

    property alias controlList: itemList

    /**************************************
     * The rest is for internal operation *
     **************************************/
    property variant currentSource

    property variant watcher: WASM.watcher()

    //onSourcePathChanged: updateWatchers();
    onOtherAssetsChanged: updateWatchers();

    Connections {
        target: watcher
        function onFileChanged(path) {
            console.log(`${path} changed, reloading...`);
            storybook.reloadCurrentSource();
            watcher.addPath(path);
        }
        function onDirectoryChanged(path) {
            console.log(`${path} changed, reloading...`);
            storybook.reloadCurrentSource();
            watcher.addPath(path);
        }
    }

    function updateWatchers() {
        for( let a=0; a < storybook.otherAssets.length; a++ )
        {
            const p = storybook.otherAssets[a];
            addWatcher(p['path']);
        }
    }

    function addWatcher(path)
    {
        console.log(`Adding path: ${path}`);
        watcher.addPath(path);
    }

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
    }

    Timer {
        id: reloadTimer
        property var callback
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

            console.log(qsTr('Reloading...'));
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
            const path = storybook.sourcePath + source['source'];

            //log(`Creating instance of ${controlName} with ${JSON.stringify(instance)} (${path})`);
            const component = Qt.createComponent(path);

            const incubator = component.incubateObject(controlContainer, instance['properties']);
            if( !incubator )
            {
                console.log(qsTr('Failed to load component at "%1". Verify the path is correct, and update "sourcePath" in Storybook.qml as needed.').arg(path));
            }
            else if( incubator.status !== Component.Ready )
            {
                incubator.onStatusChanged = function(status)
                {
                    if (status === Component.Ready)
                    {
                        let obj = incubator.object;
                        controlLoaded(source, obj, instance);
                    } else if(status === Component.Error) {
                        console.log(`Error: ${incubator.errorString}`);
                    }
                };
            } else {
                let obj = incubator.object;
                controlLoaded(source, obj, instance);
            }
        });

        updateSource(source);
        addWatcher(storybook.sourcePath + source['source']);
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
                            itemList.loadEntry(modelData);
                        }
                    }

                    function loadEntry(entry) {
                        storybook.clearCanvas();
                        storybook.loadSource(entry);
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
                                else
                                    notesPane.visible = false;
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
                        contentWidth: controlContainer.width + 20
                        contentHeight: controlContainer.height + 20

                        Column {
                            id: controlContainer
                            spacing: 10
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
