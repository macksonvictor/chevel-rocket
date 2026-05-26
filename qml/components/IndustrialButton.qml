import QtQuick
import QtQuick.Controls

Button {
    id: control

    property string variant: "normal"
    property bool locked: false

    enabled: !locked && variant !== "disabled"
    implicitHeight: 46
    hoverEnabled: true

    function accentColor() {
        if (variant === "danger")
            return "#ff3b3b"
        if (variant === "warning")
            return "#f2c84b"
        return "#79e8ff"
    }

    function baseTop() {
        if (!enabled)
            return "#242a2f"
        if (variant === "danger")
            return control.down ? "#7b1115" : "#4c1216"
        if (variant === "warning")
            return control.down ? "#5d4812" : "#3d3518"
        return control.down ? "#123922" : "#142820"
    }

    function baseBottom() {
        if (!enabled)
            return "#111417"
        if (variant === "danger")
            return "#210609"
        if (variant === "warning")
            return "#161308"
        return "#07100d"
    }

    contentItem: Text {
        text: control.text
        color: control.enabled ? (control.variant === "warning" ? "#fff6c7" : "#edf8f2") : "#778088"
        font.pixelSize: control.variant === "danger" ? 18 : 13
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        leftPadding: 8
        rightPadding: 8
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            radius: 5
            color: "#020303"
            opacity: 0.8
        }

        Rectangle {
            x: 0
            y: control.down ? 3 : 0
            width: parent.width
            height: parent.height - 4
            radius: 5
            border.width: 1
            border.color: control.enabled ? control.accentColor() : "#3c444c"
            opacity: control.enabled ? 1.0 : 0.62
            gradient: Gradient {
                GradientStop { position: 0.0; color: control.baseTop() }
                GradientStop { position: 0.55; color: "#10161a" }
                GradientStop { position: 1.0; color: control.baseBottom() }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 2
                height: 1
                color: "#ffffff"
                opacity: control.enabled ? 0.18 : 0.07
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 3
                color: control.accentColor()
                opacity: control.enabled ? (control.hovered ? 0.85 : 0.46) : 0.1
            }
        }
    }
}
