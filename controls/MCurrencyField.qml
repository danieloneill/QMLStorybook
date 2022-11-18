import QtQuick

/* TODO/FIXME: Locale */

Item {
    implicitWidth: field.implicitWidth
    implicitHeight: field.implicitHeight
    property double value

    onValueChanged: {
        field.text = value.toFixed(2);
    }

    Text {
        id: symbol
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }
        text: Style.currencySymbol
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        bottomPadding: 10
    }

    MTextField {
        id: field
        anchors {
            left: symbol.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: 5
        }
        validator: DoubleValidator {}
        onEditingFinished: {
            parent.value = parseFloat(text);
        }
    }
}
