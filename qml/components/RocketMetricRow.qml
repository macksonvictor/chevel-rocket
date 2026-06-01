import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string label: ""
    property string value: ""
    property string iconText: ""
    property string iconSource: ""
    property color valueColor: "#D7DEE6"
    property bool divider: true

    implicitHeight: 28

    function resolvedIconSource() {
        if (iconSource.length === 0)
            return ""
        if (iconSource.indexOf("qrc:/") === 0 || iconSource.indexOf("file:/") === 0 || iconSource.indexOf(":/") === 0)
            return iconSource
        return "qrc:/qt/qml/Chevel/Rocket/" + iconSource
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Image {
            visible: root.iconSource.length > 0
            source: root.resolvedIconSource()
            Layout.preferredWidth: 19
            Layout.preferredHeight: 19
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: 0.9
        }

        Text {
            visible: root.iconSource.length === 0 && root.iconText.length > 0
            text: root.iconText
            color: "#A9B4C2"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: visible ? 20 : 0
        }

        Text {
            text: root.label
            color: "#A2ABB5"
            font.pixelSize: 12
            elide: Text.ElideNone
            Layout.preferredWidth: Math.min(140, Math.max(96, root.width - 136))
        }

        Text {
            text: root.value
            color: root.valueColor
            font.pixelSize: 12
            font.bold: root.valueColor !== "#D7DEE6"
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    Rectangle {
        visible: root.divider
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#25313C"
        opacity: 0.55
    }
}
