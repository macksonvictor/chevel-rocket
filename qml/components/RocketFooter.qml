import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string pageIndex: "1 / 8"
    property string pageName: "HOME / OVERVIEW"
    property real batteryLevel: 78
    property string communication: "ESTAVEL"
    property string voice: "ONLINE"

    implicitHeight: 70
    radius: 8
    color: "#0B1218"
    border.width: 1
    border.color: "#1E2A35"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        spacing: 18

        StatusBlock { iconSource: "assets/ui/icons/single/robot.png"; iconText: "\u25c9"; label: "DUM-E"; value: "ONLINE"; valueColor: "#7CFF72" }
        Divider {}
        StatusBlock { iconSource: "assets/ui/icons/single/sensors.png"; iconText: "\u224b"; label: "SENSORES"; value: "OK"; valueColor: "#7CFF72" }
        Divider {}
        StatusBlock {
            iconSource: "assets/ui/icons/single/battery.png"
            iconText: "\u25af"
            label: "BATERIA"
            value: Math.round(root.batteryLevel) + "%"
            valueColor: "#7CFF72"
            progress: root.batteryLevel
        }
        Divider {}
        StatusBlock { iconSource: "assets/ui/icons/single/communication.png"; iconText: "\u25cc"; label: "COMUNICACAO"; value: root.communication; valueColor: "#7CFF72" }
        Divider {}
        StatusBlock { iconSource: "assets/ui/icons/single/brain.png"; iconText: "\u273a"; label: "MODELO IA"; value: "QWEN3 8B"; valueColor: "#D7DEE6"; wide: true }
        Divider {}
        StatusBlock { iconSource: "assets/ui/icons/single/wave.png"; iconText: "\u258c"; label: "VOZ"; value: root.voice; valueColor: "#7CFF72" }

        Item { Layout.fillWidth: true }

        ColumnLayout {
            spacing: 2
            Layout.preferredWidth: 150

            Text {
                text: root.pageIndex
                color: "#E2E8F0"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Text {
                text: root.pageName
                color: "#A9B4C2"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }

    component Divider: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 42
        color: "#25313C"
    }

    component StatusBlock: RowLayout {
        property string iconText: ""
        property string iconSource: ""
        property string label: ""
        property string value: ""
        property color valueColor: "#7CFF72"
        property real progress: -1
        property bool wide: false

        spacing: 10
        Layout.preferredWidth: wide ? 200 : 150

        function resolvedIconSource() {
            if (iconSource.length === 0)
                return ""
            if (iconSource.indexOf("qrc:/") === 0 || iconSource.indexOf("file:/") === 0 || iconSource.indexOf(":/") === 0)
                return iconSource
            return "qrc:/qt/qml/Chevel/Rocket/" + iconSource
        }

        Image {
            visible: iconSource.length > 0
            source: resolvedIconSource()
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: 0.95
        }

        Text {
            visible: iconSource.length === 0
            text: iconText
            color: valueColor
            font.pixelSize: 25
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: 28
        }

        ColumnLayout {
            spacing: 2
            Layout.fillWidth: true

            Text {
                text: label
                color: "#AAB3BE"
                font.pixelSize: 11
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: value
                    color: valueColor
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                RocketProgressBar {
                    visible: progress >= 0
                    value: progress
                    accent: "#7CFF72"
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 8
                }
            }
        }
    }
}
