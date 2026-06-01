import QtQuick

Item {
    id: root

    property string iconSource: ""
    property int iconSize: 24

    implicitWidth: iconSize
    implicitHeight: iconSize
    width: iconSize
    height: iconSize

    Image {
        anchors.fill: parent
        source: root.iconSource.length === 0 ? "" :
            (root.iconSource.indexOf("qrc:/") === 0 || root.iconSource.indexOf("file:/") === 0 || root.iconSource.indexOf(":/") === 0
                ? root.iconSource
                : "qrc:/qt/qml/Chevel/Rocket/" + root.iconSource)
        fillMode: Image.PreserveAspectFit
        sourceSize.width: root.iconSize
        sourceSize.height: root.iconSize
        smooth: true
        mipmap: true
    }
}
