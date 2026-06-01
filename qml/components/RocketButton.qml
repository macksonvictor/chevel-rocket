import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control

    property string variant: "secondary"
    property string iconText: ""
    property string iconSource: ""
    property string previewState: ""
    property bool locked: false
    property bool selected: false
    property int labelPixelSize: 13
    property int cornerRadius: 8

    enabled: !locked && variant !== "disabled" && previewState !== "disabled"
    hoverEnabled: true
    implicitHeight: variant === "slim" ? 34 : 42
    implicitWidth: variant === "slim" ? 190 : 164
    opacity: enabled ? 1.0 : 0.46

    function tone() {
        if (variant === "normal")
            return "secondary"
        return variant
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

    function accentColor() {
        var t = tone()
        if (t === "danger" || t === "emergency")
            return "#EF4444"
        if (t === "warning")
            return "#F59E0B"
        if (t === "ready" || t === "success" || t === "safe")
            return "#22C55E"
        if (t === "cancel")
            return "#9AA3AF"
        return "#22D3EE"
    }

    function resolvedIconSource() {
        if (iconSource.length === 0)
            return ""
        if (iconSource.indexOf("qrc:/") === 0 || iconSource.indexOf("file:/") === 0 || iconSource.indexOf(":/") === 0)
            return iconSource
        return "qrc:/qt/qml/Chevel/Rocket/" + iconSource
    }

    function textColor() {
        var t = tone()
        if (!enabled)
            return "#9AA3AF"
        if (t === "danger" || t === "emergency")
            return "#FCA5A5"
        if (t === "warning")
            return "#F8D978"
        if (t === "ready" || t === "success" || t === "safe")
            return "#BFEFC4"
        if (t === "cancel")
            return "#D1D5DB"
        return "#E8EAED"
    }

    function borderColor() {
        var t = tone()
        if (!enabled)
            return "#2A313B"
        if (t === "danger" || t === "emergency")
            return hoveredState() || active() || pressedState() ? "#EF4444" : "#7F1D1D"
        if (t === "warning")
            return hoveredState() || active() || pressedState() ? "#F59E0B" : "#5F4717"
        if (t === "ready" || t === "success" || t === "safe")
            return hoveredState() || active() || pressedState() ? "#22C55E" : "#2F6D3D"
        if (hoveredState() || active() || pressedState() || t === "primary" || t === "confirm")
            return "#22D3EE"
        return "#2A313B"
    }

    function fillTop() {
        var t = tone()
        if (!enabled)
            return "#20252C"
        if (pressedState())
            return "#0E1218"
        if (t === "danger" || t === "emergency")
            return hoveredState() || active() ? "#321519" : "#251318"
        if (t === "warning")
            return hoveredState() || active() ? "#2A2111" : "#211B10"
        if (t === "ready" || t === "success" || t === "safe")
            return hoveredState() || active() ? "#17251B" : "#121D16"
        if (t === "outlined")
            return "#10151B"
        if (hoveredState() || active() || t === "primary" || t === "confirm")
            return "#1A2029"
        return "#151A21"
    }

    function fillBottom() {
        var t = tone()
        if (!enabled)
            return "#151A21"
        if (t === "danger" || t === "emergency")
            return "#180A0D"
        if (t === "warning")
            return "#151108"
        if (t === "ready" || t === "success" || t === "safe")
            return "#0E1710"
        return "#0E1218"
    }

    contentItem: RowLayout {
        spacing: (control.iconSource.length > 0 || control.iconText.length > 0) ? 9 : 0

        Item { Layout.fillWidth: true }

        Image {
            visible: control.iconSource.length > 0
            source: control.resolvedIconSource()
            Layout.preferredWidth: control.tone() === "emergency" ? 24 : 20
            Layout.preferredHeight: control.tone() === "emergency" ? 24 : 20
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: control.enabled ? 0.95 : 0.48
        }

        Text {
            visible: control.iconSource.length === 0 && control.iconText.length > 0
            text: control.iconText
            color: control.accentColor()
            opacity: control.enabled ? 0.92 : 0.52
            font.pixelSize: control.tone() === "danger" || control.tone() === "emergency" ? 22 : 16
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: control.text
            color: control.textColor()
            opacity: control.enabled ? 1.0 : 0.62
            font.pixelSize: control.tone() === "emergency" ? Math.max(control.labelPixelSize, 18) : control.labelPixelSize
            font.bold: true
            font.letterSpacing: 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            Layout.maximumWidth: Math.max(48, control.width - ((control.iconText.length > 0 || control.iconSource.length > 0) ? 66 : 28))
        }

        Item { Layout.fillWidth: true }
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: control.pressedState() ? 1 : 3
            radius: control.cornerRadius
            color: "#030508"
            opacity: control.enabled ? 0.34 : 0.12
        }

        Rectangle {
            x: 0
            y: control.pressedState() ? 1 : 0
            width: parent.width
            height: parent.height - 3
            radius: control.cornerRadius
            border.width: 1
            border.color: control.borderColor()
            gradient: Gradient {
                GradientStop { position: 0.0; color: control.fillTop() }
                GradientStop { position: 1.0; color: control.fillBottom() }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 2
                anchors.rightMargin: 2
                anchors.topMargin: 1
                height: 1
                color: "#ffffff"
                opacity: control.enabled ? 0.08 : 0.03
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 9
                anchors.rightMargin: 9
                anchors.bottomMargin: 2
                height: 1
                radius: 1
                color: control.accentColor()
                opacity: control.enabled ? (control.hoveredState() || control.active() ? 0.56 : 0.2) : 0.08
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                radius: Math.max(1, control.cornerRadius - 2)
                color: "transparent"
                border.width: 1
                border.color: control.accentColor()
                opacity: control.enabled && (control.hoveredState() || control.active() || control.tone() === "confirm") ? 0.14 : 0.05
            }
        }
    }
}
