import QtQuick

Item {
    id: root

    property real progress: 0.0 // 0.0 to 1.0
    property int blockCount: 20
    property color activeColor: "#dcd7ba"
    property color inactiveColor: "#17171e"
    property color borderColor: "#54546D"

    implicitWidth: 260
    implicitHeight: 16

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: root.borderColor
        border.width: 1

        Row {
            id: blockRow
            anchors.fill: parent
            anchors.margins: 2
            spacing: 2
            readonly property real blockWidth: Math.max(2, (width - (root.blockCount - 1) * 2) / root.blockCount)

            Repeater {
                model: root.blockCount
                Rectangle {
                    width: blockRow.blockWidth
                    height: parent.height
                    color: (index / root.blockCount) < root.progress ? root.activeColor : root.inactiveColor
                }
            }
        }
    }
}
