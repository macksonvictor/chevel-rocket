import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string timeText: "14:28:47"
    property string dateText: "28/05/2025"
    property bool simulationMode: true
    property bool safeMode: true
    property bool emergencyActive: false
    property string connectionState: "SIMULATED"

    signal simulationModeRequested(bool simulation)
    signal safeModeToggleRequested()
    signal menuRequested()

    implicitHeight: 94
    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 16

        Item {
            Layout.preferredWidth: 420
            Layout.maximumWidth: 420
            Layout.fillHeight: true

            Image {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 0
                width: 420
                height: 88
                source: "qrc:/qt/qml/Chevel/Rocket/assets/ui/branding/chevel-rocket-header.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 98
                anchors.top: parent.top
                anchors.topMargin: 72
                text: "Mission & Robot Control"
                color: "#A9B4C2"
                font.pixelSize: 14
                font.letterSpacing: 0.4
            }
        }

        Item { Layout.preferredWidth: 14 }

        RocketStatusPill {
            valueText: root.connectionState
            status: root.emergencyActive ? "OFFLINE" : root.connectionState
            iconText: "\u25ad"
            iconSource: root.simulationMode ? "assets/ui/icons/single/simulated.png" : "assets/ui/icons/single/live.png"
            Layout.preferredWidth: 178
            Layout.minimumWidth: 178
            Layout.maximumWidth: 178
            Layout.preferredHeight: 46
        }

        RocketSegmentedToggle {
            segments: ["SIMULATION", "LIVE"]
            iconSources: ["assets/ui/icons/single/simulation.png", "assets/ui/icons/single/live.png"]
            selectedIndex: root.simulationMode ? 0 : 1
            interactive: true
            onSelected: function(index) {
                root.simulationModeRequested(index === 0)
            }
            Layout.preferredWidth: 324
            Layout.minimumWidth: 324
            Layout.maximumWidth: 324
            Layout.preferredHeight: 46
        }

        Item { Layout.preferredWidth: 20 }

        RocketStatusPill {
            valueText: root.safeMode ? "SAFE MODE" : "MANUAL MODE"
            status: root.emergencyActive ? "OFFLINE" : (root.safeMode ? "SAFE MODE" : "WARNING")
            iconText: "\u25c7"
            iconSource: "assets/ui/icons/single/safe-mode.png"
            Layout.preferredWidth: 170
            Layout.minimumWidth: 170
            Layout.maximumWidth: 170
            Layout.preferredHeight: 46

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.safeModeToggleRequested()
            }
        }

        Item { Layout.fillWidth: true }

        ColumnLayout {
            spacing: 2
            Layout.preferredWidth: 132
            Layout.minimumWidth: 132
            Layout.maximumWidth: 132

            Text {
                text: root.timeText
                color: "#D5D8DE"
                font.pixelSize: 23
                font.family: "Consolas"
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Text {
                text: root.dateText
                color: "#AAB0BA"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 48
            color: "#202B36"
        }

        Rectangle {
            Layout.preferredWidth: 44
            Layout.maximumWidth: 44
            Layout.preferredHeight: 44
            radius: 7
            color: menuMouse.containsMouse ? "#111A22" : "transparent"
            border.width: 1
            border.color: menuMouse.containsMouse ? "#22D3EE" : "transparent"

            AppIcon {
                anchors.centerIn: parent
                iconSource: "assets/ui/icons/single/menu.png"
                iconSize: 25
                width: 25
                height: 25
                opacity: 0.92
            }

            MouseArea {
                id: menuMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.menuRequested()
            }
        }
    }
}

