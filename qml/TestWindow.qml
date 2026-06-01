import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "components"

ApplicationWindow {
    id: root

    width: 900
    height: 520
    visible: true
    visibility: Window.Windowed
    title: "Chevel Rocket - QML Test"
    color: "#05070a"

    Component.onCompleted: {
        root.raise()
        root.requestActivate()
        console.log("Chevel Rocket test window loaded")
    }

    Rectangle {
        anchors.fill: parent
        color: "#05070a"

        Rectangle {
            anchors.centerIn: parent
            width: 620
            height: 260
            radius: 6
            color: "#111820"
            border.color: "#79e8ff"
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: 18

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Chevel Rocket"
                    color: "#eaf9f1"
                    font.pixelSize: 38
                    font.bold: true
                    font.letterSpacing: 2
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Qt/QML runtime window opened successfully"
                    color: "#8eeeff"
                    font.pixelSize: 18
                }

                SecondaryButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Close test"
                    onClicked: Qt.quit()
                }
            }
        }
    }
}
