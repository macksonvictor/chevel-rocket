import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {
    id: root

    clip: true

    ColumnLayout {
        width: root.availableWidth
        spacing: 18

        Text {
            text: "UI Kit"
            color: "#E8EAED"
            font.pixelSize: 20
            font.bold: true
            Layout.fillWidth: true
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 5
            columnSpacing: 12
            rowSpacing: 12

            Repeater {
                model: [
                    { label: "PRIMARY NORMAL", variant: "primary", state: "", icon: "\u25c7" },
                    { label: "PRIMARY HOVER", variant: "primary", state: "hover", icon: "\u25c7" },
                    { label: "PRIMARY PRESSED", variant: "primary", state: "pressed", icon: "\u25c7" },
                    { label: "PRIMARY DISABLED", variant: "primary", state: "disabled", icon: "\u25c7" },
                    { label: "PRIMARY SELECTED", variant: "primary", state: "selected", icon: "\u25c7" },
                    { label: "SECONDARY", variant: "secondary", state: "", icon: "\u25b6" },
                    { label: "OUTLINED", variant: "outlined", state: "", icon: "\u25ce" },
                    { label: "SLIM TOOLBAR", variant: "slim", state: "", icon: "\u2630" },
                    { label: "CONFIRM", variant: "confirm", state: "", icon: "\u2713" },
                    { label: "CANCEL", variant: "cancel", state: "", icon: "\u00d7" },
                    { label: "WARNING", variant: "warning", state: "", icon: "!" },
                    { label: "READY", variant: "ready", state: "", icon: "\u2713" },
                    { label: "SAFE MODE", variant: "safe", state: "", icon: "\u2713" },
                    { label: "DISABLED", variant: "disabled", state: "disabled", icon: "" },
                    { label: "START MISSION", variant: "secondary", state: "selected", icon: "\u25b6" }
                ]

                RocketButton {
                    required property var modelData

                    text: modelData.label
                    variant: modelData.variant
                    previewState: modelData.state
                    iconText: modelData.icon
                    selected: modelData.state === "selected"
                    Layout.fillWidth: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            RocketIconButton { iconText: "\u25c7"; previewState: ""; Layout.preferredWidth: 44 }
            RocketIconButton { iconText: "\u25c7"; previewState: "hover"; Layout.preferredWidth: 44 }
            RocketIconButton { iconText: "\u25ce"; previewState: "pressed"; Layout.preferredWidth: 44 }
            RocketIconButton { iconText: "\u25ce"; previewState: "disabled"; Layout.preferredWidth: 44 }
            RocketIconButton { iconText: "\u25c7"; previewState: "selected"; selected: true; Layout.preferredWidth: 44 }
            RocketSegmentedToggle { segments: ["SIMULATION", "LIVE"]; selectedIndex: 0; Layout.preferredWidth: 260 }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            RocketDangerButton { text: "EMERGENCY STOP"; Layout.preferredWidth: 280 }
            RocketDialogButton { role: "confirm"; text: "CONFIRM"; Layout.preferredWidth: 170 }
            RocketDialogButton { role: "cancel"; text: "CANCEL"; Layout.preferredWidth: 160 }
            RocketDialogButton { role: "warning"; text: "WARNING"; Layout.preferredWidth: 170 }
            RocketDialogButton { role: "ready"; text: "READY"; Layout.preferredWidth: 150 }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            RocketStatusPill { valueText: "SAFE MODE"; status: "SAFE MODE"; iconText: "\u2713"; Layout.preferredWidth: 190 }
            RocketStatusPill { valueText: "WARNING"; status: "WARNING"; iconText: "!"; Layout.preferredWidth: 170 }
            RocketStatusPill { valueText: "OFFLINE"; status: "OFFLINE"; iconText: "\u00d7"; Layout.preferredWidth: 170 }
            RocketStatusPill { valueText: "ONLINE"; status: "ONLINE"; iconText: "\u25cf"; Layout.preferredWidth: 170 }
        }
    }
}
