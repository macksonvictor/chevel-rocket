import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var controller

    radius: 4
    color: "#070b0d"
    border.color: "#46535f"
    border.width: 1
    clip: true

    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = "#071014"
            ctx.fillRect(0, 0, width, height)

            ctx.strokeStyle = "#15313a"
            ctx.lineWidth = 1
            for (var x = 0; x < width; x += 28) {
                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.stroke()
            }
            for (var y = 0; y < height; y += 28) {
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }

            ctx.strokeStyle = "#79e8ff"
            ctx.globalAlpha = 0.28
            ctx.beginPath()
            ctx.moveTo(width / 2, 0)
            ctx.lineTo(width / 2, height)
            ctx.moveTo(0, height / 2)
            ctx.lineTo(width, height / 2)
            ctx.stroke()
            ctx.globalAlpha = 1.0
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        radius: 3
        color: "transparent"
        border.color: "#264551"
        border.width: 1
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: "CAMERA / MAP FEED"
            color: "#dce8e4"
            font.pixelSize: 28
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "SIMULATED INPUT BUS"
            color: "#8eeeff"
            font.pixelSize: 13
            font.family: "Consolas"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 18
        text: controller ? "X " + Number(controller.telemetry.positionX).toLocaleString(Qt.locale(), "f", 2)
                         + " / Y " + Number(controller.telemetry.positionY).toLocaleString(Qt.locale(), "f", 2)
                         + " / Z " + Number(controller.telemetry.positionZ).toLocaleString(Qt.locale(), "f", 2) : "X -- / Y -- / Z --"
        color: "#9defff"
        font.pixelSize: 13
        font.family: "Consolas"
    }

    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        text: "GRID LOCK: SIM"
        color: "#f2c84b"
        font.pixelSize: 12
        font.bold: true
    }
}
