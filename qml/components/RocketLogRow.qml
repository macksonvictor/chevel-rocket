import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string timeText: "14:28:47.123"
    property string level: "INFO"
    property string moduleName: "MISSION CONTROL"
    property string description: ""
    property bool selected: false

    implicitHeight: 41
    radius: 4
    color: root.selected ? "#112733" : "transparent"
    border.width: root.selected ? 1 : 0
    border.color: "#22D3EE"

    function levelColor() {
        if (level === "ERROR")
            return "#EF4444"
        if (level === "WARNING" || level === "WARN")
            return "#F59E0B"
        return "#7CFF72"
    }

    function levelFill() {
        if (level === "ERROR")
            return "#2A1114"
        if (level === "WARNING" || level === "WARN")
            return "#241C0B"
        return "#112112"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 14

        Text {
            text: root.timeText
            color: "#B2BAC4"
            font.pixelSize: 12
            font.family: "Consolas"
            Layout.preferredWidth: 115
        }

        Rectangle {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 24
            radius: 4
            color: root.levelFill()
            border.width: 1
            border.color: root.levelColor()

            Text {
                anchors.centerIn: parent
                text: root.level
                color: root.levelColor()
                font.pixelSize: 11
                font.bold: true
            }
        }

        Text {
            text: root.moduleName
            color: root.moduleName.indexOf("MISSION") >= 0 ? "#22D3EE" : "#B8C0CA"
            font.pixelSize: 12
            font.bold: root.moduleName.indexOf("MISSION") >= 0
            Layout.preferredWidth: 150
            elide: Text.ElideRight
        }

        Text {
            text: root.description
            color: "#D6DCE3"
            font.pixelSize: 12
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Rectangle {
            Layout.preferredWidth: 10
            Layout.preferredHeight: 10
            radius: 5
            color: root.levelColor()
            opacity: 0.9
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#25313C"
        opacity: root.selected ? 0 : 0.45
    }
}
