import QtQuick

RocketButton {
    id: control

    property bool current: false

    variant: "secondary"
    selected: current
    implicitHeight: 38
    labelPixelSize: 12
}
