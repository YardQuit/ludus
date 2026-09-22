// The Ludus login screen: Omarchy's minimal SDDM theme - one password
// field, the user taken as given - redrawn in the ao-dark palette with
// shapes instead of Omarchy's images and logo. Omarchy is MIT-licensed;
// its notice is at /usr/share/licenses/ludus/Omarchy-LICENSE.

import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
  id: root
  width: 640
  height: 480
  color: "#080d15" // deep-abyss

  readonly property color fieldColor: "#0d1526"  // midnight-thunder
  readonly property color accent: "#ff9000"      // blaze-orange
  readonly property color failColor: "#fa7970"   // ruby-glow
  readonly property color textColor: "#dadada"   // ao-white

  // The last user to log in; on a fresh machine nobody has yet, so fall
  // back to the first account SDDM lists (NameRole is Qt.UserRole + 1).
  property string currentUser: userModel.lastUser !== ""
    ? userModel.lastUser
    : (userModel.count > 0 ? userModel.data(userModel.index(0, 0), Qt.UserRole + 1) : "")
  property bool loginFailed: false
  // Omarchy's choice: the uwsm-managed Hyprland session when there is one.
  property int sessionIndex: {
    for (var i = 0; i < sessionModel.rowCount(); i++) {
      var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
      if (name.indexOf("uwsm") !== -1)
        return i
    }
    return sessionModel.lastIndex
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      root.loginFailed = true
      password.text = ""
      password.focus = true
    }
    function onLoginSucceeded() {
      root.loginFailed = false
    }
  }

  Column {
    anchors.centerIn: parent
    spacing: 40

    Text {
      text: "ludus"
      color: root.accent
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 64
      font.bold: true
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
      text: root.currentUser
      color: root.textColor
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 20
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 15

      Text {
        text: "" // nf-fa-lock
        color: root.loginFailed ? root.failColor : root.accent
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 34
        anchors.verticalCenter: parent.verticalCenter
      }

      Rectangle {
        id: entry
        width: 420
        height: 56
        color: root.fieldColor
        border.width: 2
        border.color: root.loginFailed ? root.failColor : root.accent

        Row {
          anchors.left: parent.left
          anchors.leftMargin: 20
          anchors.verticalCenter: parent.verticalCenter
          spacing: 5

          Repeater {
            model: Math.min(password.text.length, 21)

            Rectangle {
              width: 7
              height: 7
              color: root.textColor
            }
          }
        }

        TextInput {
          id: password
          anchors.fill: parent
          anchors.leftMargin: 20
          anchors.rightMargin: 20
          verticalAlignment: TextInput.AlignVCenter
          echoMode: TextInput.Password
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 24
          font.letterSpacing: 5
          passwordCharacter: "•"
          color: "transparent"
          selectionColor: "transparent"
          selectedTextColor: "transparent"
          cursorDelegate: Item {}
          focus: true

          onTextChanged: root.loginFailed = false

          Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              sddm.login(root.currentUser, password.text, root.sessionIndex)
              event.accepted = true
            }
          }
        }
      }
    }
  }

  Component.onCompleted: password.forceActiveFocus()
}
