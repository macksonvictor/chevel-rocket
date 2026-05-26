import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string label: ""
    property string status: "OK"
    property string valueText: status

    implicitHeight: 28
    implicitWidth: 180

    function statusColor() {
        if (status === "OK" || status === "CONNECTED")
            return "#79e8ff"
        if (status === "WARNING" || status === "SIMULATED")
            return "#f2c84b"
        if (status === "ERROR" || status === "EMERGENCY")
            return "#ff4040"
        return "#64707a"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Item {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22

            Rectangle {
                anchors.centerIn: parent
                width: 22
                height: 22
                radius: 11
                color: root.statusColor()
                opacity: 0.18
            }

            Rectangle {
                anchors.centerIn: parent
                width: 13
                height: 13
                radius: 7
                color: root.statusColor()
                border.color: "#eaf7f0"
                border.width: 1
            }
        }

        Text {
            text: root.label
            color: "#91a2aa"
            font.pixelSize: 11
            font.bold: true
            Layout.preferredWidth: root.label.length > 0 ? 52 : 0
            elide: Text.ElideRight
        }

        Text {
            text: root.valueText
            color: root.statusColor()
            font.pixelSize: 13
            font.bold: true
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }
}
