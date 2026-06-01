import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string label: ""
    property string status: "OK"
    property string valueText: status
    property string iconText: ""
    property string iconSource: ""

    implicitHeight: 46
    implicitWidth: 176
    clip: true

    function resolvedIconSource() {
        if (iconSource.length === 0)
            return ""
        if (iconSource.indexOf("qrc:/") === 0 || iconSource.indexOf("file:/") === 0 || iconSource.indexOf(":/") === 0)
            return iconSource
        return "qrc:/qt/qml/Chevel/Rocket/" + iconSource
    }

    function statusTone() {
        if (status === "OK" || status === "CONNECTED" || status === "ONLINE" || status === "READY" || status === "SAFE MODE" || status === "ACTIVE" || status === "ATIVO" || status === "STABLE")
            return "ready"
        if (status === "SIMULATED" || status === "SIMULATION" || status === "MODEL")
            return "cyan"
        if (status === "WARNING" || status === "WARN")
            return "warning"
        if (status === "ERROR" || status === "EMERGENCY")
            return "danger"
        return "offline"
    }

    function accentColor() {
        var t = statusTone()
        if (t === "ready")
            return "#22C55E"
        if (t === "cyan")
            return "#22D3EE"
        if (t === "warning")
            return "#F59E0B"
        if (t === "danger")
            return "#EF4444"
        return "#9AA3AF"
    }

    function fillColor() {
        var t = statusTone()
        if (t === "ready")
            return "#111D14"
        if (t === "cyan")
            return "#0B1E26"
        if (t === "warning")
            return "#211B10"
        if (t === "danger")
            return "#251318"
        return "#151A21"
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: root.fillColor()
        border.width: 1
        border.color: root.accentColor()
        opacity: 0.96

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 9
            color: "transparent"
            border.width: 1
            border.color: "#FFFFFF"
            opacity: 0.05
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            radius: 7
            color: "transparent"
            border.width: 1
            border.color: root.accentColor()
            opacity: 0.18
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.bottomMargin: 3
            height: 2
            radius: 1
            color: root.accentColor()
            opacity: 0.28
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 12
            spacing: 9

            AppIcon {
                visible: root.iconSource.length > 0
                iconSource: root.iconSource
                iconSize: 25
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                Layout.maximumWidth: 25
                Layout.maximumHeight: 25
                opacity: 0.98
            }

            Text {
                visible: root.iconSource.length === 0 && root.iconText.length > 0
                text: root.iconText
                color: root.accentColor()
                font.pixelSize: 17
                font.bold: true
            }

            Text {
                text: root.label
                color: "#9AA3AF"
                font.pixelSize: 11
                font.bold: true
                visible: root.label.length > 0
                Layout.preferredWidth: visible ? 58 : 0
                elide: Text.ElideRight
            }

            Text {
                text: root.valueText
                color: root.accentColor()
                font.pixelSize: 13
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                radius: 4
                color: root.accentColor()
                opacity: 0.88
            }
        }
    }
}
