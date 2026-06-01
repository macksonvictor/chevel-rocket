import QtQuick

Item {
    id: root

    property real value: 0
    property real maximum: 100
    property color accent: "#22D3EE"
    property color trackColor: "#222A32"

    implicitWidth: 130
    implicitHeight: 8

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.trackColor
        opacity: 0.95
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Math.max(0, Math.min(parent.width, parent.width * root.value / root.maximum))
        radius: height / 2
        color: root.accent

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "#FFFFFF"
            opacity: 0.18
        }
    }
}
