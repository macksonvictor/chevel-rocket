import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string status: "MISSING"
    property string pathText: ""
    property string iconSource: "assets/ui/icons/single/settings.png"

    function accent() {
        if (status === "READY")
            return "#7CFF72"
        if (status === "PARTIAL")
            return "#FFB020"
        if (status === "ERROR" || status === "MISSING" || status === "OFFLINE")
            return "#EF4444"
        return "#22D3EE"
    }

    implicitHeight: 92
    radius: 8
    color: "#0B1219"
    border.width: 1
    border.color: root.accent()

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        AppIcon {
            iconSource: root.iconSource
            iconSize: 38
            opacity: 0.95
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.title
                    color: "#E6EDF3"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: root.status
                    color: root.accent()
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            Text {
                text: root.pathText
                color: "#9AA3AF"
                font.pixelSize: 11
                font.family: "Consolas"
                elide: Text.ElideMiddle
                Layout.fillWidth: true
            }
        }
    }
}
