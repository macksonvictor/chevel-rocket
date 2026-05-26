import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var logs: []

    radius: 4
    color: "#080d10"
    border.color: "#3f4c56"
    border.width: 1
    clip: true

    function levelColor(line) {
        if (line.indexOf("CRITICAL") >= 0)
            return "#ff4a4a"
        if (line.indexOf("ERROR") >= 0)
            return "#ff7474"
        if (line.indexOf("WARNING") >= 0)
            return "#f2c84b"
        return "#9defff"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "EVENT LOG"
                color: "#dce8e4"
                font.pixelSize: 14
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "LIVE"
                color: "#3cff98"
                font.pixelSize: 12
                font.bold: true
            }
        }

        ListView {
            id: logView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.logs
            clip: true
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            onCountChanged: Qt.callLater(positionViewAtEnd)

            delegate: Text {
                width: logView.width
                text: modelData
                color: root.levelColor(modelData)
                font.pixelSize: 12
                font.family: "Consolas"
                elide: Text.ElideRight
            }
        }
    }
}
