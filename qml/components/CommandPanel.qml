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

        IndustrialButton {
            text: "ARM ROBOT"
            variant: "normal"
            locked: root.emergency || root.armed
            Layout.fillWidth: true
            onClicked: root.criticalCommand("ARM ROBOT",
                                            "This will arm the robot in simulation mode. Type CONFIRMAR to continue.",
                                            "armRobot")
        }

        IndustrialButton {
            text: "DISARM ROBOT"
            variant: "normal"
            locked: root.emergency || !root.armed
            Layout.fillWidth: true
            onClicked: root.controller.disarmRobot()
        }

        IndustrialButton {
            text: "START MISSION"
            variant: "warning"
            locked: root.emergency || !root.armed
            Layout.fillWidth: true
            onClicked: root.criticalCommand("START MISSION",
                                            "This starts the simulated mission profile. Type CONFIRMAR to continue.",
                                            "startMission")
        }

        IndustrialButton {
            text: "PAUSE MISSION"
            variant: "normal"
            locked: root.emergency || !root.armed
            Layout.fillWidth: true
            onClicked: root.controller.pauseMission()
        }

        IndustrialButton {
            text: "RETURN HOME"
            variant: "warning"
            locked: root.emergency || !root.armed
            Layout.fillWidth: true
            onClicked: root.controller.returnHome()
        }

        IndustrialButton {
            text: "CALIBRATE SENSORS"
            variant: "normal"
            locked: root.emergency
            Layout.fillWidth: true
            onClicked: root.controller.calibrateSensors()
        }

        IndustrialButton {
            text: "REBOOT SYSTEM"
            variant: "warning"
            locked: root.emergency
            Layout.fillWidth: true
            onClicked: root.criticalCommand("REBOOT SYSTEM",
                                            "This performs a simulated controller reboot. Type CONFIRMAR to continue.",
                                            "rebootSystem")
        }

        Item { Layout.fillHeight: true }

        IndustrialButton {
            text: "CLEAR EMERGENCY"
            variant: "warning"
            visible: root.emergency
            locked: !root.emergency
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 48 : 0
            onClicked: root.controller.clearEmergency()
        }

        IndustrialButton {
            text: "EMERGENCY STOP"
            variant: "danger"
            locked: root.emergency
            Layout.fillWidth: true
            Layout.preferredHeight: 88
            onClicked: root.criticalCommand("EMERGENCY STOP",
                                            "This engages the simulated emergency stop and blocks all commands. Type CONFIRMAR to continue.",
                                            "emergencyStop")
        }
    }
}
