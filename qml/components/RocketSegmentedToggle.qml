import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property int selectedIndex: 0
    property var segments: ["SIMULATION", "LIVE"]
    property var iconSources: []
    property bool interactive: true

    signal selected(int index)

    implicitWidth: 300
    implicitHeight: 46
    radius: 7
    color: "#0A1016"
    border.width: 1
    border.color: "#2A313B"
    clip: true

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.segments

            Rectangle {
                id: segment

                required property int index
                required property var modelData

                Layout.fillWidth: true
                Layout.fillHeight: true
                color: index === root.selectedIndex ? "#12202A" : "#0E131A"
                border.width: index === root.selectedIndex ? 1 : 0
                border.color: "#22D3EE"
                clip: true

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    height: 2
                    radius: 1
                    color: "#22D3EE"
                    opacity: index === root.selectedIndex ? 0.72 : 0.06
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 9

                    AppIcon {
                        visible: root.iconSources.length > segment.index
                        iconSource: visible ? root.iconSources[segment.index] : ""
                        iconSize: segment.index === root.selectedIndex ? 24 : 21
                        Layout.preferredWidth: segment.index === root.selectedIndex ? 24 : 21
                        Layout.preferredHeight: segment.index === root.selectedIndex ? 24 : 21
                        Layout.maximumWidth: segment.index === root.selectedIndex ? 24 : 21
                        Layout.maximumHeight: segment.index === root.selectedIndex ? 24 : 21
                        opacity: segment.index === root.selectedIndex ? 1.0 : 0.62
                    }

                    Text {
                        text: segment.modelData
                        color: segment.index === root.selectedIndex ? "#E8FAFF" : "#9AA3AF"
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.interactive
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        root.selectedIndex = segment.index
                        root.selected(segment.index)
                    }
                }
            }
        }
    }
}
