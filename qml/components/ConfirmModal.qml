import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property string actionName: ""
    property string message: ""
    property string confirmWord: "CONFIRMAR"
    property bool requiresTypedConfirmation: true

    signal confirmed()

    width: Math.min(560, parent ? parent.width * 0.44 : 560)
    height: 310
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0
    modal: true
    dim: true
    closePolicy: Popup.NoAutoClose

    function openFor(action, body, typedConfirmation) {
        actionName = action
        message = body
        requiresTypedConfirmation = typedConfirmation
        confirmInput.text = ""
        open()
        confirmInput.forceActiveFocus()
    }

    background: Rectangle {
        radius: 8
        color: "#0d1216"
        border.width: 1
        border.color: root.actionName === "EMERGENCY STOP" ? "#7F1D1D" : "#2A313B"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 7
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#151A21" }
                GradientStop { position: 1.0; color: "#0E1218" }
            }
        }
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 14

        Text {
            text: root.actionName
            color: root.actionName === "EMERGENCY STOP" ? "#FCA5A5" : "#E8EAED"
            font.pixelSize: 24
            font.bold: true
            Layout.fillWidth: true
        }

        Text {
            text: root.message
            color: "#dce8e4"
            font.pixelSize: 14
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            text: "Type CONFIRMAR to unlock this action."
            color: "#8fa0aa"
            font.pixelSize: 12
            visible: root.requiresTypedConfirmation
            Layout.fillWidth: true
        }

        TextField {
            id: confirmInput
            visible: root.requiresTypedConfirmation
            Layout.fillWidth: true
            height: 42
            color: "#effaf5"
            selectedTextColor: "#050709"
            selectionColor: "#3cff98"
            placeholderText: root.confirmWord
            placeholderTextColor: "#66747d"
            font.pixelSize: 16
            font.family: "Consolas"
            background: Rectangle {
                radius: 3
                color: "#05080a"
                border.color: confirmInput.text === root.confirmWord ? "#3cff98" : "#53616b"
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            CancelButton {
                text: "CANCEL"
                Layout.fillWidth: true
                onClicked: root.close()
            }

            ConfirmButton {
                text: "CONFIRM"
                visible: root.actionName !== "EMERGENCY STOP"
                locked: root.requiresTypedConfirmation && confirmInput.text !== root.confirmWord
                Layout.fillWidth: true
                onClicked: {
                    root.close()
                    root.confirmed()
                }
            }

            DangerButton {
                text: "CONFIRM"
                visible: root.actionName === "EMERGENCY STOP"
                locked: root.requiresTypedConfirmation && confirmInput.text !== root.confirmWord
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                onClicked: {
                    root.close()
                    root.confirmed()
                }
            }
        }
    }
}
