import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    signal overviewRequested()
    signal voiceDiagnosticsRequested()
    signal settingsRequested()
    signal logsRequested()
    signal aboutRequested()
    signal fullscreenRequested()
    signal reloadDiagnosticsRequested()
    signal exitRequested()

    width: 310
    height: content.implicitHeight + 28
    modal: false
    dim: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 14

    background: Rectangle {
        radius: 10
        color: "#081018"
        border.width: 1
        border.color: "#22D3EE"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 9
            color: "transparent"
            border.width: 1
            border.color: "#1F2A35"
            opacity: 0.7
        }
    }

    contentItem: ColumnLayout {
        id: content
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            AppIcon { iconSource: "assets/ui/icons/single/settings.png"; iconSize: 26 }
            Text {
                text: "CHEVEL MENU"
                color: "#E6EDF3"
                font.pixelSize: 15
                font.bold: true
                Layout.fillWidth: true
            }
            Text {
                text: "\u2715"
                color: "#9AA3AF"
                font.pixelSize: 14
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.close()
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#22313D" }

        Repeater {
            model: [
                ["System Overview", "assets/ui/icons/single/mission.png", "overview"],
                ["AI / Voice Diagnostics", "assets/ui/icons/single/active-voice.png", "voice"],
                ["Settings", "assets/ui/icons/single/settings.png", "settings"],
                ["Logs", "assets/ui/icons/single/logs.png", "logs"],
                ["About Chevel Rocket", "assets/ui/icons/single/rocket.png", "about"],
                ["Toggle fullscreen/windowed", "assets/ui/icons/single/details.png", "fullscreen"],
                ["Reload diagnostics", "assets/ui/icons/single/terminal.png", "reload"],
                ["Exit", "assets/ui/icons/single/cancel.png", "exit"]
            ]

            RocketButton {
                required property var modelData
                text: modelData[0]
                iconSource: modelData[1]
                variant: modelData[2] === "exit" ? "cancel" : "secondary"
                labelPixelSize: 12
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                onClicked: {
                    root.close()
                    if (modelData[2] === "overview")
                        root.overviewRequested()
                    else if (modelData[2] === "voice")
                        root.voiceDiagnosticsRequested()
                    else if (modelData[2] === "settings")
                        root.settingsRequested()
                    else if (modelData[2] === "logs")
                        root.logsRequested()
                    else if (modelData[2] === "about")
                        root.aboutRequested()
                    else if (modelData[2] === "fullscreen")
                        root.fullscreenRequested()
                    else if (modelData[2] === "reload")
                        root.reloadDiagnosticsRequested()
                    else if (modelData[2] === "exit")
                        root.exitRequested()
                }
            }
        }
    }
}
