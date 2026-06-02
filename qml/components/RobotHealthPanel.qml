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

    function tempStatus() {
        if (!controller)
            return "OFFLINE"
        if (controller.emergencyActive || controller.motorTemperature >= 90)
            return "ERROR"
        if (controller.motorTemperature >= 70)
            return "WARNING"
        return "OK"
    }

    function signalStatus() {
        if (!controller)
            return "OFFLINE"
        if (controller.signalStrength < 25)
            return "ERROR"
        if (controller.signalStrength < 45 || controller.connectionState === "SIM FALLBACK")
            return "WARNING"
        return "OK"
    }

    function powerStatus() {
        if (!controller)
            return "OFFLINE"
        if (controller.batteryLevel < 18)
            return "ERROR"
        if (controller.batteryLevel < 35)
            return "WARNING"
        return "OK"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Text {
            text: "ROBOT HEALTH"
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

        StatusPill { label: "Motors"; valueText: tempStatus(); status: tempStatus(); Layout.fillWidth: true }
        StatusPill { label: "Sensors"; valueText: controller && controller.emergencyActive ? "OFFLINE" : "OK"; status: valueText; Layout.fillWidth: true }
        StatusPill { label: "Camera"; valueText: "OFFLINE"; status: "OFFLINE"; Layout.fillWidth: true }
        StatusPill { label: "Lidar"; valueText: "WARNING"; status: "WARNING"; Layout.fillWidth: true }
        StatusPill { label: "GPS/Pos"; valueText: controller && controller.connectionState === "SIM FALLBACK" ? "FALLBACK" : "OK"; status: valueText; Layout.fillWidth: true }
        StatusPill { label: "Control"; valueText: signalStatus(); status: signalStatus(); Layout.fillWidth: true }
        StatusPill { label: "Power"; valueText: powerStatus(); status: powerStatus(); Layout.fillWidth: true }

        Item { Layout.fillHeight: true }
    }
}
