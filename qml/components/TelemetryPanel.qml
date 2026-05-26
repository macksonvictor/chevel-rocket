import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var controller

    radius: 4
    color: "#0d1318"
    border.color: "#3f4c56"
    border.width: 1
    clip: true

    function fmt(value, digits, unit) {
        if (value === undefined)
            return "--"
        return Number(value).toLocaleString(Qt.locale(), "f", digits) + unit
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Text {
            text: "TELEMETRY"
            color: "#dce8e4"
            font.pixelSize: 15
            font.bold: true
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#36444e"
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 5

            Repeater {
                model: [
                    ["State", root.controller ? root.controller.robotState : "--"],
                    ["Pos X", root.controller ? root.fmt(root.controller.telemetry.positionX, 2, " m") : "--"],
                    ["Pos Y", root.controller ? root.fmt(root.controller.telemetry.positionY, 2, " m") : "--"],
                    ["Pos Z", root.controller ? root.fmt(root.controller.telemetry.positionZ, 2, " m") : "--"],
                    ["Roll", root.controller ? root.fmt(root.controller.telemetry.roll, 1, " deg") : "--"],
                    ["Pitch", root.controller ? root.fmt(root.controller.telemetry.pitch, 1, " deg") : "--"],
                    ["Yaw", root.controller ? root.fmt(root.controller.telemetry.yaw, 1, " deg") : "--"],
                    ["Linear", root.controller ? root.fmt(root.controller.telemetry.linearVelocity, 2, " m/s") : "--"],
                    ["Angular", root.controller ? root.fmt(root.controller.telemetry.angularVelocity, 2, " rad/s") : "--"],
                    ["Temp", root.controller ? root.fmt(root.controller.telemetry.temperature, 1, " C") : "--"],
                    ["Voltage", root.controller ? root.fmt(root.controller.telemetry.voltage, 2, " V") : "--"],
                    ["Current", root.controller ? root.fmt(root.controller.telemetry.current, 2, " A") : "--"],
                    ["Latency", root.controller ? root.fmt(root.controller.telemetry.latency, 0, " ms") : "--"]
                ]

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22

                    RowLayout {
                        anchors.fill: parent
                        spacing: 8

                        Text {
                            text: modelData[0]
                            color: "#7f9099"
                            font.pixelSize: 11
                            Layout.preferredWidth: 72
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData[1]
                            color: modelData[0] === "State" ? "#8eeeff" : "#d3e1df"
                            font.pixelSize: 12
                            font.family: "Consolas"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
