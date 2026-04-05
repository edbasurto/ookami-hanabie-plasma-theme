import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: lockScreenRoot

    // Required property injected by kscreenlocker
    property var authenticator

    // kscreenlocker sets this when the view becomes visible/hidden
    property bool viewVisible: false

    // Focus the password field when the screen is shown
    onViewVisibleChanged: {
        if (viewVisible) {
            passwordField.forceActiveFocus();
        }
    }

    // --- Background ---
    Image {
        id: background
        anchors.fill: parent
        source: Qt.resolvedUrl("../wallpapers/hanabie-group-pic.jpg")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // Subtle dark overlay so the form is readable over the photo
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.45
    }

    // --- Center auth form ---
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        width: Math.min(360, parent.width * 0.9)

        // Clock
        Text {
            id: clockLabel
            Layout.alignment: Qt.AlignHCenter
            color: "#ffffff"
            font.pixelSize: 64
            font.bold: true
            text: Qt.formatTime(new Date(), "HH:mm")

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clockLabel.text = Qt.formatTime(new Date(), "HH:mm")
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            color: "#cccccc"
            font.pixelSize: 16
            text: Qt.formatDate(new Date(), "dddd, MMMM d yyyy")
        }

        // Spacer
        Item { Layout.preferredHeight: 24 }

        // Password field
        TextField {
            id: passwordField
            Layout.fillWidth: true
            placeholderText: "Password"
            echoMode: TextInput.Password
            color: "#ffffff"
            placeholderTextColor: "#aaaaaa"
            font.pixelSize: 16
            horizontalAlignment: TextInput.AlignHCenter
            leftPadding: 16
            rightPadding: 16
            topPadding: 12
            bottomPadding: 12

            background: Rectangle {
                color: "#33ffffff"
                radius: 8
                border.color: passwordField.activeFocus ? "#ff80e0" : "#555555"
                border.width: passwordField.activeFocus ? 2 : 1
            }

            Keys.onReturnPressed: lockScreenRoot.tryUnlock()
            Keys.onEnterPressed: lockScreenRoot.tryUnlock()

            // Clear field and show error shake on auth failure
            Connections {
                target: authenticator
                function onFailed() {
                    passwordField.text = "";
                    shakeAnim.start();
                }
            }
        }

        // Unlock button
        Button {
            Layout.fillWidth: true
            text: "Unlock"
            font.pixelSize: 15
            onClicked: lockScreenRoot.tryUnlock()

            contentItem: Text {
                text: parent.text
                color: "#ffffff"
                font: parent.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: parent.pressed ? "#8c1011" : (parent.hovered ? "#cc2060" : "#ff80e0")
                radius: 8
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }

        // Auth failure message
        Text {
            id: failMessage
            Layout.alignment: Qt.AlignHCenter
            color: "#ff4444"
            font.pixelSize: 13
            text: ""
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Connections {
                target: authenticator
                function onFailed() {
                    failMessage.text = "Incorrect password";
                    failMessage.opacity = 1;
                    fadeTimer.restart();
                }
            }

            Timer {
                id: fadeTimer
                interval: 3000
                onTriggered: failMessage.opacity = 0
            }
        }
    }

    // Shake animation on failure
    SequentialAnimation {
        id: shakeAnim
        property int delta: 12
        NumberAnimation { target: passwordField; property: "x"; to: passwordField.x + shakeAnim.delta; duration: 50 }
        NumberAnimation { target: passwordField; property: "x"; to: passwordField.x - shakeAnim.delta; duration: 50 }
        NumberAnimation { target: passwordField; property: "x"; to: passwordField.x + shakeAnim.delta / 2; duration: 40 }
        NumberAnimation { target: passwordField; property: "x"; to: passwordField.x; duration: 40 }
    }

    function tryUnlock() {
        if (passwordField.text.length > 0) {
            authenticator.tryUnlock(passwordField.text);
        }
    }
}
