import QtQuick

Item {
    id: root

    property string text: ""
    property bool isActive: false
    property color activeColor: "#dcd7ba"
    property color activeTextColor: "#111116"
    property color inactiveColor: "#17171e"
    property color inactiveTextColor: "#dcd7ba"
    property color borderColor: isActive ? activeColor : "#54546D"
    property color hoverColor: "#223249"
    property string fontFamily: "Press Start 2P"
    property int fontSize: 8

    signal clicked()

    implicitWidth: btnText.implicitWidth + 20
    implicitHeight: 30

    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.topMargin: mouseArea.pressed ? 2 : 0
        anchors.leftMargin: mouseArea.pressed ? 1 : 0
        color: root.isActive ? root.activeColor : (mouseArea.containsMouse ? root.hoverColor : root.inactiveColor)
        border.color: root.borderColor
        border.width: 2
        radius: 0 // Pixel art sharp corners

        Text {
            id: btnText
            anchors.centerIn: parent
            text: root.text
            textFormat: Text.PlainText
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            font.bold: true
            color: root.isActive ? root.activeTextColor : root.inactiveTextColor
            renderType: Text.NativeRendering
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
