import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    default property alias contentData: body.data
    property string title: ""
    property string subtitle: ""
    property string iconText: ""
    property string iconSource: ""
    property int iconSize: 24
    property bool compact: false
    property color accent: "#22D3EE"

    radius: 8
    color: "#0D141A"
    border.width: 1
    border.color: "#1E2A35"
    clip: true

    function resolvedIconSource() {
        if (iconSource.length === 0)
            return ""
        if (iconSource.indexOf("qrc:/") === 0 || iconSource.indexOf("file:/") === 0 || iconSource.indexOf(":/") === 0)
            return iconSource
        return "qrc:/qt/qml/Chevel/Rocket/" + iconSource
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#111922" }
            GradientStop { position: 1.0; color: "#090E13" }
        }
        opacity: 0.92
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: "#FFFFFF"
        opacity: 0.08
    }

    ColumnLayout {
        id: body
        anchors.fill: parent
        anchors.margins: root.compact ? 10 : 14
        spacing: root.compact ? 7 : 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 9
            visible: root.title.length > 0 || root.iconText.length > 0 || root.iconSource.length > 0

            Image {
                visible: root.iconSource.length > 0
                source: root.resolvedIconSource()
                Layout.preferredWidth: visible ? root.iconSize : 0
                Layout.preferredHeight: visible ? root.iconSize : 0
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.95
            }

            Text {
                visible: root.iconSource.length === 0 && root.iconText.length > 0
                text: root.iconText
                color: root.accent
                font.pixelSize: 19
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: visible ? root.iconSize : 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: root.title
                    color: "#D7DEE6"
                    font.pixelSize: root.compact ? 13 : 15
                    font.bold: true
                    font.letterSpacing: 0
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: root.subtitle.length > 0
                    text: root.subtitle
                    color: "#8D98A5"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }
}
