import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

import Qt.labs.calendar 1.0

ColumnLayout {
    id: calendar

    property alias day: gridMonth.selectedDay
    property alias month: comboMonth.currentIndex
    property alias year: spinYear.value
    property alias timestamp: gridMonth.timestamp
    property alias dayDelegate: gridMonth.delegate

    onTimestampChanged: {
        day = timestamp.getDate();
        month = timestamp.getMonth();
        year = timestamp.getFullYear();
    }

    SpinBox {
        id: spinYear
        from: 1971
        to: 2276
        value: 2022
        Layout.fillWidth: true
        textFromValue: function(v){return v}
    }

    RowLayout {
        Layout.fillWidth: true
        ToolButton {
            text: '←'
            onClicked: {
                if( comboMonth.currentIndex > 0 )
                    comboMonth.currentIndex--;
                else
                {
                    comboMonth.currentIndex = 11;
                    spinYear.value--;
                }
            }
        }
        ComboBox {
            id: comboMonth
            Layout.fillWidth: true
            model: [
                { 'name':qsTr('January'), 'value':Calendar.January },
                { 'name':qsTr('February'), 'value':Calendar.February },
                { 'name':qsTr('March'), 'value':Calendar.March },
                { 'name':qsTr('April'), 'value':Calendar.April },
                { 'name':qsTr('May'), 'value':Calendar.May },
                { 'name':qsTr('June'), 'value':Calendar.June },
                { 'name':qsTr('July'), 'value':Calendar.July },
                { 'name':qsTr('August'), 'value':Calendar.August },
                { 'name':qsTr('September'), 'value':Calendar.September },
                { 'name':qsTr('October'), 'value':Calendar.October },
                { 'name':qsTr('November'), 'value':Calendar.November },
                { 'name':qsTr('December'), 'value':Calendar.December },
            ]
            textRole: 'name'
            valueRole: 'value'
            currentIndex: gridMonth.month
        }
        ToolButton {
            text: '→'
            onClicked: {
                if( comboMonth.currentIndex < 11 )
                    comboMonth.currentIndex++;
                else
                {
                    comboMonth.currentIndex = 0;
                    spinYear.value++;
                }
            }
        }
    }

    DayOfWeekRow {
        id: weekday
        locale: gridMonth.locale
        Layout.fillWidth: true
        delegate: Text {
            text: narrowName
            color: Material.foreground
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            width: gridMonth.width * 0.12
            height: width * 0.66

            Rectangle {
                anchors.fill: parent
                color: 'transparent'
                radius: 3
                border.color: Material.accent
            }
        }
    }

    MonthGrid {
        id: gridMonth
        property int selectedDay: 1
        property variant timestamp: new Date(year, month, selectedDay, 12, 0, 0, 0);
        Layout.fillWidth: true
        Layout.fillHeight: true
        month: comboMonth.currentValue
        year: spinYear.value
        locale: Qt.locale("en_US")
        delegate: MCalendarDayDelegate {
            monthGrid: calendar
            onClicked: {
                calendar.day = model.day;
                calendar.timestamp = new Date(model.year, model.month, model.day, 12, 0, 0, 0);
            }
        }
    }
}
