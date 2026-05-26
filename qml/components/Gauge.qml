import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: "Gauge"
    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property string unit: ""
    property real warningThreshold: 70
    property real dangerThreshold: 90
    property bool dangerBelow: false
    property real displayedValue: value

    radius: 4
    color: "#0c1115"
    border.color: "#3f4c56"
    border.width: 1
    clip: true

    onValueChanged: displayedValue = value

    Behavior on displayedValue {
        NumberAnimation { duration: 430; easing.type: Easing.OutCubic }
    }

    function clampValue(v) {
        return Math.max(minValue, Math.min(maxValue, v))
    }

    function severityColor() {
        if (dangerBelow) {
            if (displayedValue <= dangerThreshold)
                return "#ff3535"
            if (displayedValue <= warningThreshold)
                return "#f2c84b"
            return "#79e8ff"
        }

        if (displayedValue >= dangerThreshold)
            return "#ff3535"
        if (displayedValue >= warningThreshold)
            return "#f2c84b"
        return "#79e8ff"
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: 3
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1f2930" }
            GradientStop { position: 0.45; color: "#0d1216" }
            GradientStop { position: 1.0; color: "#050709" }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: "#8fa0aa"
        opacity: 0.5
    }

    Canvas {
        id: dial
        anchors.fill: parent
        anchors.margins: 8

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cx = width / 2
            var cy = height * 0.61
            var radius = Math.min(width, height) * 0.33
            if (width <= 0 || height <= 0 || radius <= 0)
                return

            var start = Math.PI * 0.75
            var end = Math.PI * 2.25
            var range = maxValue - minValue
            var normalized = range <= 0 ? 0 : (clampValue(displayedValue) - minValue) / range
            var angle = start + (end - start) * normalized

            ctx.lineCap = "round"
            ctx.lineWidth = Math.max(9, radius * 0.11)
            ctx.strokeStyle = "#1a252b"
            ctx.beginPath()
            ctx.arc(cx, cy, radius, start, end)
            ctx.stroke()

            ctx.lineWidth = Math.max(7, radius * 0.08)
            ctx.strokeStyle = "#1d5a6b"
            ctx.beginPath()
            ctx.arc(cx, cy, radius, start, start + (end - start) * 0.58)
            ctx.stroke()

            ctx.strokeStyle = "#9b7e28"
            ctx.beginPath()
            ctx.arc(cx, cy, radius, start + (end - start) * 0.58, start + (end - start) * 0.82)
            ctx.stroke()

            ctx.strokeStyle = "#922d31"
            ctx.beginPath()
            ctx.arc(cx, cy, radius, start + (end - start) * 0.82, end)
            ctx.stroke()

            ctx.lineWidth = Math.max(8, radius * 0.1)
            ctx.strokeStyle = severityColor()
            ctx.shadowColor = severityColor()
            ctx.shadowBlur = 12
            ctx.beginPath()
            ctx.arc(cx, cy, radius, start, angle)
            ctx.stroke()
            ctx.shadowBlur = 0

            ctx.strokeStyle = "#b7c4c9"
            ctx.lineWidth = 1
            for (var i = 0; i <= 10; ++i) {
                var tickAngle = start + (end - start) * (i / 10)
                var inner = radius * (i % 5 === 0 ? 0.77 : 0.83)
                var outer = radius * 0.96
                ctx.beginPath()
                ctx.moveTo(cx + Math.cos(tickAngle) * inner, cy + Math.sin(tickAngle) * inner)
                ctx.lineTo(cx + Math.cos(tickAngle) * outer, cy + Math.sin(tickAngle) * outer)
                ctx.stroke()
            }

            ctx.strokeStyle = severityColor()
            ctx.lineWidth = 3
            ctx.shadowColor = severityColor()
            ctx.shadowBlur = 8
            ctx.beginPath()
            ctx.moveTo(cx, cy)
            ctx.lineTo(cx + Math.cos(angle) * radius * 0.72, cy + Math.sin(angle) * radius * 0.72)
            ctx.stroke()
            ctx.shadowBlur = 0

            var hubGradient = ctx.createRadialGradient(cx, cy, 2, cx, cy, 13)
            hubGradient.addColorStop(0, "#e8f4ef")
            hubGradient.addColorStop(0.42, "#44525d")
            hubGradient.addColorStop(1, "#11171c")
            ctx.fillStyle = hubGradient
            ctx.beginPath()
            ctx.arc(cx, cy, 13, 0, Math.PI * 2)
            ctx.fill()
        }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 9
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.title
        color: "#cad8dd"
        font.pixelSize: 13
        font.bold: true
        elide: Text.ElideRight
        width: parent.width - 18
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        text: Number(root.displayedValue).toLocaleString(Qt.locale(), "f", root.maxValue <= 10 ? 2 : 0) + " " + root.unit
        color: root.severityColor()
        font.pixelSize: 22
        font.bold: true
        font.family: "Consolas"
    }

    onDisplayedValueChanged: dial.requestPaint()
    onWidthChanged: dial.requestPaint()
    onHeightChanged: dial.requestPaint()
}
