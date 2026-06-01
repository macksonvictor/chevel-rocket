import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property var controller

    width: Math.min(980, parent ? parent.width * 0.72 : 980)
    height: Math.min(720, parent ? parent.height * 0.78 : 720)
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0
    modal: true
    dim: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 18

    function statusColor(status) {
        if (status === "READY")
            return "#7CFF72"
        if (status === "PARTIAL")
            return "#FFB020"
        if (status === "ERROR" || status === "MISSING" || status === "OFFLINE")
            return "#EF4444"
        return "#22D3EE"
    }

    onOpened: {
        if (controller)
            controller.runVoiceDiagnostics()
    }

    background: Rectangle {
        radius: 12
        color: "#081018"
        border.width: 1
        border.color: "#22D3EE"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 11
            color: "transparent"
            border.width: 1
            border.color: "#1F2A35"
        }
    }

    contentItem: ColumnLayout {
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            AppIcon { iconSource: "assets/ui/icons/single/active-voice.png"; iconSize: 42 }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "AI / VOICE DIAGNOSTICS"
                    color: "#E6EDF3"
                    font.pixelSize: 24
                    font.bold: true
                }
                Text {
                    text: "Whisper, FFmpeg, Piper e saida de audio do Chevel Rocket."
                    color: "#9AA3AF"
                    font.pixelSize: 12
                }
            }
            Text {
                text: controller ? controller.voiceStatus : "OFFLINE"
                color: root.statusColor(controller ? controller.voiceStatus : "OFFLINE")
                font.pixelSize: 14
                font.bold: true
            }
            RocketIconButton {
                iconText: "X"
                Layout.preferredWidth: 42
                Layout.preferredHeight: 36
                onClicked: root.close()
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 10
            columnSpacing: 10

            ToolStatusCard {
                title: "FFmpeg"
                status: controller ? controller.ffmpegStatus : "OFFLINE"
                pathText: controller ? controller.ffmpegPath : ""
                iconSource: "assets/ui/icons/single/terminal.png"
                Layout.fillWidth: true
            }
            ToolStatusCard {
                title: "Whisper STT"
                status: controller ? controller.whisperStatus : "OFFLINE"
                pathText: controller ? controller.whisperPath : ""
                iconSource: "assets/ui/icons/single/voice.png"
                Layout.fillWidth: true
            }
            ToolStatusCard {
                title: "Piper TTS"
                status: controller ? controller.piperStatus : "MISSING"
                pathText: controller ? controller.piperPath : ""
                iconSource: "assets/ui/icons/single/active-voice.png"
                Layout.fillWidth: true
            }
            ToolStatusCard {
                title: "Piper model .onnx"
                status: controller ? controller.piperModelStatus : "MISSING"
                pathText: controller ? controller.piperModelPath : ""
                iconSource: "assets/ui/icons/single/ai-chip.png"
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            RocketButton { text: "TESTAR WHISPER"; iconSource: "assets/ui/icons/single/voice.png"; variant: "primary"; Layout.preferredWidth: 168; Layout.preferredHeight: 40; onClicked: if (controller) controller.testWhisper() }
            RocketButton { text: "TESTAR PIPER"; iconSource: "assets/ui/icons/single/active-voice.png"; variant: "secondary"; Layout.preferredWidth: 150; Layout.preferredHeight: 40; onClicked: if (controller) controller.testPiper() }
            RocketButton { text: "ABRIR PASTA DE SAIDA"; iconSource: "assets/ui/icons/single/folder-logs.png"; variant: "outlined"; Layout.preferredWidth: 210; Layout.preferredHeight: 40; onClicked: if (controller) controller.openVoiceOutputFolder() }
            Item { Layout.fillWidth: true }
            RocketButton { text: "RELOAD"; iconSource: "assets/ui/icons/single/terminal.png"; variant: "outlined"; Layout.preferredWidth: 112; Layout.preferredHeight: 40; onClicked: if (controller) controller.runVoiceDiagnostics() }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "Output:"; color: "#9AA3AF"; font.pixelSize: 12 }
            Text { text: controller ? controller.voiceOutputDir : ""; color: "#22D3EE"; font.pixelSize: 12; font.family: "Consolas"; Layout.fillWidth: true; elide: Text.ElideMiddle }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            TextArea {
                readOnly: true
                wrapMode: TextEdit.Wrap
                color: "#CFEAF2"
                selectedTextColor: "#061015"
                selectionColor: "#22D3EE"
                font.family: "Consolas"
                font.pixelSize: 12
                text: controller ? controller.voiceDiagnosticsOutput : ""
                background: Rectangle {
                    radius: 8
                    color: "#05090E"
                    border.width: 1
                    border.color: "#1F2A35"
                }
            }
        }
    }
}
