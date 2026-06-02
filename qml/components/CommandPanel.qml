import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var controller
    signal criticalCommand(string actionName, string message, string methodName)

    readonly property bool emergency: controller ? controller.emergencyActive : false
    readonly property bool armed: controller ? controller.armed : false

    radius: 4
    color: "#0c1115"
    border.color: emergency ? "#ff3838" : "#46535f"
    border.width: emergency ? 2 : 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 9

        Text {
            text: "ROBOT COMMANDS"
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

        PrimaryButton {
            text: "ARM ROBOT"
            locked: root.emergency || root.armed
            Layout.fillWidth: true
            onClicked: root.criticalCommand("ARM ROBOT",
                                            "This will arm the robot through USB serial when CHEVEL_ROBOT_SERIAL_PORT is configured. Type CONFIRMAR to continue.",
                                            "armRobot")
        }

        SecondaryButton {
            text: "DISARM ROBOT"
            iconText: "\u00d7"
            visible: root.armed && !root.emergency
            locked: root.emergency || !root.armed
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 42 : 0
            onClicked: root.controller.disarmRobot()
        }

        DisabledButton {
            text: "DISARM ROBOT"
            iconText: "\u00d7"
            visible: root.emergency || !root.armed
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 42 : 0
        }

        SecondaryButton {
            text: "START MISSION"
            iconText: "\u25b6"
            locked: root.emergency || !root.armed
            Layout.fillWidth: true
            onClicked: root.criticalCommand("START MISSION",
                                            "This starts the safe WIESEL Mini LIVE sequence through USB serial. Type CONFIRMAR to continue.",
                                            "startMission")
        }

        SecondaryButton {
            text: "PAUSE MISSION"
            iconText: "||"
            locked: root.emergency || !root.armed
            Layout.fillWidth: true
            onClicked: root.controller.pauseMission()
        }

        WarningButton {
            text: "RETURN HOME"
            locked: root.emergency || !root.armed
            Layout.fillWidth: true
            onClicked: root.controller.returnHome()
        }

        SecondaryButton {
            text: "CALIBRATE SENSORS"
            iconText: "\u25ce"
            locked: root.emergency
            Layout.fillWidth: true
            onClicked: root.controller.calibrateSensors()
        }

        WarningButton {
            text: "REBOOT SYSTEM"
            locked: root.emergency
            Layout.fillWidth: true
            onClicked: root.criticalCommand("REBOOT SYSTEM",
                                            "WIESEL Mini v1 does not reboot hardware from the cockpit. This logs a safe diagnostic action. Type CONFIRMAR to continue.",
                                            "rebootSystem")
        }

        Item { Layout.fillHeight: true }

        ReadyButton {
            text: "CLEAR EMERGENCY"
            visible: root.emergency
            locked: !root.emergency
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 48 : 0
            onClicked: root.controller.clearEmergency()
        }

        DangerButton {
            text: "EMERGENCY STOP"
            locked: root.emergency
            Layout.fillWidth: true
            Layout.preferredHeight: 88
            onClicked: root.criticalCommand("EMERGENCY STOP",
                                            "This latches emergency locally and sends STOP through USB serial when configured. Type CONFIRMAR to continue.",
                                            "emergencyStop")
        }
    }
}
