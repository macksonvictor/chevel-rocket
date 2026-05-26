import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: root

    x: 80
    y: 80
    width: 1360
    height: 820
    minimumWidth: 1280
    minimumHeight: 720

    visible: true
    visibility: Window.Windowed

    color: "#07090b"
    title: "CHEVEL ROCKET"

    property string currentTimeText: Qt.formatTime(new Date(), "HH:mm:ss")
    property string pendingMethod: ""

    Component.onCompleted: {
        root.visible = true
        root.visibility = Window.Windowed
        root.raise()
        root.requestActivate()
        console.log("CHEVEL ROCKET interface loaded")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTimeText = Qt.formatTime(new Date(), "HH:mm:ss")
    }

    function openCritical(name, message, methodName) {
        pendingMethod = methodName
        confirmModal.openFor(name, message, true)
    }

    function executePending() {
        if (pendingMethod === "armRobot")
            robotController.armRobot()
        else if (pendingMethod === "startMission")
            robotController.startMission()
        else if (pendingMethod === "rebootSystem")
            robotController.rebootSystem()
        else if (pendingMethod === "emergencyStop")
            robotController.emergencyStop()

        pendingMethod = ""
    }

    background: Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#10151a" }
            GradientStop { position: 0.48; color: "#06080a" }
            GradientStop { position: 1.0; color: "#111317" }
        }

        Canvas {
            anchors.fill: parent
            opacity: 0.28

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                ctx.strokeStyle = "#25313a"
                ctx.lineWidth = 1

                for (var x = -height; x < width; x += 22) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x + height, height)
                    ctx.stroke()
                }

                ctx.strokeStyle = "#0d1418"

                for (var y = 0; y < height; y += 18) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            color: "#111820"
            radius: 4
            border.color: "#4b5964"
            border.width: 1

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 3
                opacity: 0.62

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#27313a" }
                    GradientStop { position: 0.4; color: "#111820" }
                    GradientStop { position: 1.0; color: "#07090c" }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 18

                ColumnLayout {
                    spacing: 0
                    Layout.preferredWidth: 320

                    Text {
                        text: "CHEVEL"
                        color: "#eaf9f1"
                        font.pixelSize: 30
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Text {
                        text: "ROCKET CONTROL CENTER"
                        color: "#7df7b1"
                        font.pixelSize: 13
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 188
                    Layout.preferredHeight: 38
                    radius: 3
                    color: "#0c1114"
                    border.color: "#31ff8d"

                    Text {
                        anchors.centerIn: parent
                        text: "SIMULATION MODE"
                        color: "#31ff8d"
                        font.pixelSize: 15
                        font.bold: true
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                StatusLight {
                    label: "LINK"
                    status: robotController.connectionState === "SIMULATED" ? "WARNING" : robotController.connectionState
                    valueText: robotController.connectionState
                    Layout.preferredWidth: 210
                }

                Rectangle {
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 42
                    radius: 3
                    color: "#05080a"
                    border.color: "#3e4d59"

                    Text {
                        anchors.centerIn: parent
                        text: root.currentTimeText
                        color: "#d9efe6"
                        font.pixelSize: 22
                        font.family: "Consolas"
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            ColumnLayout {
                Layout.preferredWidth: 275
                Layout.fillHeight: true
                spacing: 10

                RobotHealthPanel {
                    controller: robotController
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                }

                TelemetryPanel {
                    controller: robotController
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 350
                    radius: 4
                    color: "#10161c"
                    border.color: "#46535f"

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        columns: 3
                        rowSpacing: 10
                        columnSpacing: 10

                        Gauge {
                            title: "Battery"
                            value: robotController.batteryLevel
                            minValue: 0
                            maxValue: 100
                            unit: "%"
                            warningThreshold: 35
                            dangerThreshold: 18
                            dangerBelow: true
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        Gauge {
                            title: "Motor Temp"
                            value: robotController.motorTemperature
                            minValue: 0
                            maxValue: 120
                            unit: "C"
                            warningThreshold: 70
                            dangerThreshold: 90
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        Gauge {
                            title: "Speed"
                            value: robotController.speed
                            minValue: 0
                            maxValue: 5
                            unit: "m/s"
                            warningThreshold: 3.4
                            dangerThreshold: 4.4
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        Gauge {
                            title: "Signal"
                            value: robotController.signalStrength
                            minValue: 0
                            maxValue: 100
                            unit: "%"
                            warningThreshold: 45
                            dangerThreshold: 25
                            dangerBelow: true
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        Gauge {
                            title: "CPU Load"
                            value: robotController.cpuLoad
                            minValue: 0
                            maxValue: 100
                            unit: "%"
                            warningThreshold: 70
                            dangerThreshold: 90
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        Gauge {
                            title: "Mission Risk"
                            value: robotController.missionRisk
                            minValue: 0
                            maxValue: 100
                            unit: "%"
                            warningThreshold: 45
                            dangerThreshold: 75
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }

                CameraMapPanel {
                    controller: robotController
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }

            CommandPanel {
                controller: robotController
                Layout.preferredWidth: 306
                Layout.fillHeight: true

                onCriticalCommand: function(actionName, message, methodName) {
                    root.openCritical(actionName, message, methodName)
                }
            }
        }

        LogConsole {
            logs: robotController.logs
            Layout.fillWidth: true
            Layout.preferredHeight: 152
        }
    }

    ConfirmModal {
        id: confirmModal
        onConfirmed: root.executePending()
    }
}