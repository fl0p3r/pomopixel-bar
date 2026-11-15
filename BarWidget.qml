import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
    id: root
    moduleName: "pomopixel-bar"

    TimerCore {
        id: timerCore
        hostWidget: root
    }

    function reloadTimerState() {
        if (timerCore) timerCore.reloadState()
    }

    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

    function open() {
        if (panelLoader.item) panelLoader.item.open()
    }

    function close() {
        if (panelLoader.item) panelLoader.item.close()
    }

    function togglePanel() {
        if (panelLoader.item) panelLoader.item.toggle()
    }

    readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

    function closeForPopoutSwitch() {
        if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
    }

    readonly property real openPanelIndicatorWidth: contentRow.implicitWidth

    function injectPanel() {
        var target = panelLoader.item
        if (!target) return
        if ("bar" in target) target.bar = root.bar
        if ("settings" in target) target.settings = root.settings
        if ("anchorItem" in target) target.anchorItem = button
        if ("hostWidget" in target) target.hostWidget = root
        if ("timer" in target) target.timer = timerCore
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    onBarChanged: injectPanel()
    onSettingsChanged: injectPanel()

    Loader {
        id: panelLoader
        active: true
        source: Qt.resolvedUrl("Panel.qml")
        visible: false
        onLoaded: {
            root.injectPanel()
            Qt.callLater(root.injectPanel)
        }
    }

    WidgetButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        text: timerCore.formattedTime
        keepSpace: true
        labelVisible: false
        fixedWidth: contentRow.implicitWidth + Style.space(16)
        tooltipText: "Pomopixel: " + timerCore.modeName + " [" + timerCore.formattedTime + "]\n• Click: Open Panel\n• Right-click: Play/Pause\n• Middle-click: Reset"
        foreground: timerCore.isRunning
            ? (timerCore.mode === 0 ? timerCore.currentAccentColor : timerCore.green)
            : Commons.Color.foreground
        active: root.opened || timerCore.isRunning
        activeColor: timerCore.currentAccentColor

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: Style.space(6)
            scale: button.pressScale

            BarMascot {
                id: barMascot
                anchors.verticalCenter: parent.verticalCenter
                targetSize: 20
                mascotType: timerCore.mascot
                isResting: timerCore.isMascotResting
                isRunning: timerCore.isRunning
                primaryColor: timerCore.currentAccentColor
                secondaryColor: timerCore.foreground
                darkEyeColor: timerCore.darkerBackground
                redColor: timerCore.red
                greenColor: timerCore.green
                yellowColor: timerCore.yellow
                orangeColor: timerCore.orange
                blueColor: timerCore.blue
                cyanColor: timerCore.cyan
            }

            Text {
                id: timeLabel
                anchors.verticalCenter: parent.verticalCenter
                text: timerCore.formattedTime
                color: button.active && button.useActiveColor ? button.activeColor : button.foreground
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.body
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        onPressed: function(b) {
            if (b === Qt.RightButton) {
                timerCore.toggle()
            } else if (b === Qt.MiddleButton) {
                timerCore.reset()
            } else {
                root.togglePanel()
            }
        }
    }
}
