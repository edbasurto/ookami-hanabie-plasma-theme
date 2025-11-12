import QtQuick 2.15
import QtQuick.Window 2.15

Item {
    id: lockscreen
    width: Screen.width
    height: Screen.height

    // Background image
    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../wallpapers/hanabie-group-pic.jpg") // relative path in your theme
        fillMode: Image.PreserveAspectCrop
    }
}

