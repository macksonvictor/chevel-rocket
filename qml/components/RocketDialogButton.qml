import QtQuick

RocketButton {
    property string role: "confirm"

    variant: role
    iconText: role === "confirm" || role === "ready" ? "\u2713" : (role === "cancel" ? "\u00d7" : "!")
}
