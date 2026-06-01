import QtQuick
import QtQuick.Controls

Button {
    id: control

    property string iconText: "\u25ce"
    property string variant: "secondary"
    property string previewState: ""
    property bool selected: false
    property bool locked: false

    enabled: !locked && previewState !== "disabled"
    hoverEnabled: true
    implicitWidth: 44
    implicitHeight: 44
    opacity: enabled ? 1.0 : 0.45

    function accentColor() {
        if (variant === "warning")
            return "#F59E0B"
        if (variant === "ready")
            return "#22C55E"
        if (variant === "danger")
            return "#EF4444"
        return "#22D3EE"
    }

    function active() {
        return selected || previewState === "selected"
    }

    function hoveredState() {
        return hovered || previewState === "hover"
    }

    function pressedState() {
        return down || previewState === "pressed"
    }

    contentItem: Text {
        text: control.iconText
        color: control.enabled ? control.accentColor() : "#9AA3AF"
        font.pixelSize: 18
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: 8
        color: control.pressedState() ? "#0E1218" : (control.hoveredState() || control.active() ? "#1A2029" : "#151A21")
        border.width: 1
        border.color: control.hoveredState() || control.active() ? control.accentColor() : "#2A313B"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            radius: 6
            color: "transparent"
            border.width: 1
            border.color: control.accentColor()
            opacity: control.enabled ? (control.hoveredState() || control.active() ? 0.18 : 0.06) : 0.04
        }
    }
}
