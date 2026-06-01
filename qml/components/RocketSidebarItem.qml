import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control

    property string iconText: ""
    property string iconSource: ""
    property bool current: false

    implicitHeight: 64
    hoverEnabled: true

    function resolvedIconSource() {
        if (iconSource.length === 0)
            return ""
        if (iconSource.indexOf("qrc:/") === 0 || iconSource.indexOf("file:/") === 0 || iconSource.indexOf(":/") === 0)
            return iconSource
        return "qrc:/qt/qml/Chevel/Rocket/" + iconSource
    }

    contentItem: RowLayout {
        spacing: 14

        Image {
            visible: control.iconSource.length > 0
            source: control.resolvedIconSource()
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: control.current ? 1.0 : 0.78
        }

        Text {
            visible: control.iconSource.length === 0
            text: control.iconText
            color: control.current ? "#22D3EE" : "#D5DAE0"
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.preferredWidth: 34
        }

        Text {
            text: control.text
            color: control.current ? "#2FE6FF" : "#C5CCD4"
            font.pixelSize: 16
            font.bold: control.current
            elide: Text.ElideRight
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Rectangle {
        radius: 7
        color: control.current ? "#0C2630" : (control.hovered ? "#111A22" : "transparent")
        border.width: control.current ? 1 : 0
        border.color: control.current ? "#22D3EE" : "transparent"

        Rectangle {
            visible: control.current
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 3
            radius: 2
            color: "#22D3EE"
        }
    }
}
