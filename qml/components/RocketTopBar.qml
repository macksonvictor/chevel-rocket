import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string timeText: "14:28:47"
    property string dateText: "28/05/2025"
    property bool simulationMode: false
    property bool safeMode: true
    property bool emergencyActive: false
    property string connectionState: "LIVE STANDBY"

    signal safeModeToggleRequested()
    signal menuRequested()

    implicitHeight: 116
    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 16

        Item {
            Layout.preferredWidth: 444
            Layout.maximumWidth: 444
            Layout.fillHeight: true

            Image {
                id: logoImage
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 0
                anchors.topMargin: 2
                width: 430
                height: 82
                source: "qrc:/qt/qml/Chevel/Rocket/assets/ui/branding/chevel-rocket-topbar.png"
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignLeft
                verticalAlignment: Image.AlignVCenter
                smooth: true
                mipmap: true
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.top: logoImage.bottom
                anchors.topMargin: -2
                text: "Mission & Robot Control"
                color: "#B8C5D8"
                font.pixelSize: 15
                font.weight: Font.Medium
            }
        }

        Item { Layout.preferredWidth: 32 }

        RocketStatusPill {
            valueText: root.connectionState
            status: root.emergencyActive ? "OFFLINE" : root.connectionState
            iconText: ""
            iconSource: "assets/ui/icons/single/live-wave.png"
            Layout.preferredWidth: 222
            Layout.minimumWidth: 222
            Layout.maximumWidth: 222
            Layout.preferredHeight: 46
        }

        Item { Layout.preferredWidth: 34 }

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

