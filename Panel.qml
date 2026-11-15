import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Panel {
    id: root
    moduleName: "pomopixel-bar"
    ipcTarget: "pomopixel-bar"
    manageIpc: true

    property var anchorItem: null
    property var hostWidget: null
    readonly property var barIdentity: hostWidget || root

    property var timer: null

    FontLoader {
        id: retroFont
        source: Qt.resolvedUrl("assets/PressStart2P.ttf")
    }

    readonly property string pixelFontName: retroFont.name ? retroFont.name : "Press Start 2P"

    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem
        owner: root.barIdentity
        bar: root.bar
        open: root.opened
        centerOnBar: false
        focusTarget: panel.loadedContent
        contentWidth: panel.fittedContentWidth(Style.space(340))
        contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

        content: PanelKeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            implicitHeight: mainCol.implicitHeight

            onCloseRequested: root.close()
            onActivateRequested: if (root.timer) root.timer.toggle()
            onTextKey: function(t, modifiers) {
                if (!root.timer) return
                if (t === " ") {
                    root.timer.toggle()
                } else if (t === "r" || t === "R") {
                    root.timer.reset()
                } else if (t === "s" || t === "S") {
                    root.timer.skip()
                } else if (t === "m" || t === "M") {
                    root.timer.nextMascot()
                    root.timer.playClick()
                } else if (t === "1") {
                    root.timer.setMode(0)
                } else if (t === "2") {
                    root.timer.setMode(1)
                } else if (t === "3") {
                    root.timer.setMode(2)
                }
            }

            Column {
                id: mainCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 10

                // 1. Header Title
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "POMODORO"
                    textFormat: Text.PlainText
                    font.family: root.pixelFontName
                    font.pixelSize: 16
                    font.bold: true
                    color: root.timer ? root.timer.magenta : Commons.Color.accent
                    renderType: Text.NativeRendering
                }

                // 2. Mode Tabs (FOCUS, BREAK, LONG)
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    PixelButton {
                        text: "FOCUS"
                        fontSize: 7
                        fontFamily: root.pixelFontName
                        implicitWidth: 76
                        implicitHeight: 26
                        isActive: root.timer ? root.timer.mode === 0 : true
                        activeColor: root.timer ? root.timer.currentAccentColor : Commons.Color.accent
                        activeTextColor: root.timer ? root.timer.darkerBackground : "#111116"
                        inactiveColor: root.timer ? root.timer.darkBackground : "#17171e"
                        inactiveTextColor: root.timer ? root.timer.foreground : "#dcd7ba"
                        borderColor: root.timer ? root.timer.muted : "#54546D"
                        onClicked: if (root.timer) root.timer.setMode(0)
                    }

                    PixelButton {
                        text: "BREAK"
                        fontSize: 7
                        fontFamily: root.pixelFontName
                        implicitWidth: 76
                        implicitHeight: 26
                        isActive: root.timer ? root.timer.mode === 1 : false
                        activeColor: root.timer ? root.timer.currentAccentColor : Commons.Color.accent
                        activeTextColor: root.timer ? root.timer.darkerBackground : "#111116"
                        inactiveColor: root.timer ? root.timer.darkBackground : "#17171e"
                        inactiveTextColor: root.timer ? root.timer.foreground : "#dcd7ba"
                        borderColor: root.timer ? root.timer.muted : "#54546D"
                        onClicked: if (root.timer) root.timer.setMode(1)
                    }

                    PixelButton {
                        text: "LONG"
                        fontSize: 7
                        fontFamily: root.pixelFontName
                        implicitWidth: 76
                        implicitHeight: 26
                        isActive: root.timer ? root.timer.mode === 2 : false
                        activeColor: root.timer ? root.timer.currentAccentColor : Commons.Color.accent
                        activeTextColor: root.timer ? root.timer.darkerBackground : "#111116"
                        inactiveColor: root.timer ? root.timer.darkBackground : "#17171e"
                        inactiveTextColor: root.timer ? root.timer.foreground : "#dcd7ba"
                        borderColor: root.timer ? root.timer.muted : "#54546D"
                        onClicked: if (root.timer) root.timer.setMode(2)
                    }
                }

                // 3. Central Retro Card
                Rectangle {
                    width: parent.width
                    implicitHeight: cardCol.implicitHeight + 16
                    color: root.timer ? root.timer.darkerBackground : "#111116"
                    border.color: root.timer ? root.timer.currentAccentColor : Commons.Color.accent
                    border.width: 1

                    Column {
                        id: cardCol
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.timer ? root.timer.modeName : "FOCUS TIME"
                            textFormat: Text.PlainText
                            font.family: root.pixelFontName
                            font.pixelSize: 9
                            color: root.timer ? root.timer.foreground : "#dcd7ba"
                            renderType: Text.NativeRendering
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.timer ? root.timer.formattedTime : "25:00"
                            textFormat: Text.PlainText
                            font.family: root.pixelFontName
                            font.pixelSize: 24
                            font.bold: true
                            color: root.timer ? root.timer.brightForeground : "#dcd7ba"
                            renderType: Text.NativeRendering
                        }

                        PixelProgressBar {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 20
                            progress: root.timer ? root.timer.progress : 0.0
                            activeColor: root.timer ? root.timer.currentAccentColor : Commons.Color.accent
                            inactiveColor: root.timer ? root.timer.darkBackground : "#17171e"
                            borderColor: root.timer ? root.timer.muted : "#54546D"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "TODAY: " + (root.timer ? root.timer.completedCycles : 0)
                            textFormat: Text.PlainText
                            font.family: root.pixelFontName
                            font.pixelSize: 8
                            color: root.timer ? root.timer.muted : "#54546D"
                            renderType: Text.NativeRendering
                        }

                        // Mascot Area (Click to cycle mascot)
                        Item {
                            width: parent.width
                            height: 136

                            Mascot {
                                anchors.centerIn: parent
                                mascotType: root.timer ? root.timer.mascot : "blob"
                                isResting: root.timer ? root.timer.isMascotResting : false
                                pixelScale: 4
                                primaryColor: root.timer ? root.timer.magenta : "#957fb8"
                                secondaryColor: root.timer ? root.timer.currentAccentColor : "#dcd7ba"
                                darkEyeColor: root.timer ? root.timer.darkerBackground : "#111116"
                                redColor: root.timer ? root.timer.red : "#c34043"
                                greenColor: root.timer ? root.timer.green : "#76946a"
                                yellowColor: root.timer ? root.timer.yellow : "#c0a36e"
                                orangeColor: root.timer ? root.timer.orange : "#c17158"
                                blueColor: root.timer ? root.timer.blue : "#7e9cd8"
                                cyanColor: root.timer ? root.timer.cyan : "#6a9589"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.timer) {
                                        root.timer.nextMascot()
                                        root.timer.playClick()
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.timer ? (root.timer.isMascotResting ? "ZZZ... REST" : (root.timer.isRunning ? "FOCUSING..." : "READY TO WORK")) : "READY TO WORK"
                            textFormat: Text.PlainText
                            font.family: root.pixelFontName
                            font.pixelSize: 8
                            color: root.timer ? (root.timer.isMascotResting ? root.timer.accent : (root.timer.isRunning ? root.timer.green : root.timer.foreground)) : Commons.Color.foreground
                            renderType: Text.NativeRendering
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "[click mascot or 'M' to switch]"
                            textFormat: Text.PlainText
                            font.family: root.pixelFontName
                            font.pixelSize: 6
                            color: root.timer ? root.timer.muted : "#54546D"
                            renderType: Text.NativeRendering
                        }
                    }
                }

                // 4. Control Buttons (START, RESET, SKIP)
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    PixelButton {
                        text: (root.timer && root.timer.isRunning) ? "PAUSE" : "START"
                        fontSize: 8
                        fontFamily: root.pixelFontName
                        implicitWidth: 84
                        implicitHeight: 30
                        isActive: true
                        activeColor: root.timer ? root.timer.currentAccentColor : Commons.Color.accent
                        activeTextColor: root.timer ? root.timer.darkerBackground : "#111116"
                        onClicked: if (root.timer) root.timer.toggle()
                    }

                    PixelButton {
                        text: "RESET"
                        fontSize: 8
                        fontFamily: root.pixelFontName
                        implicitWidth: 76
                        implicitHeight: 30
                        isActive: false
                        inactiveColor: root.timer ? root.timer.darkBackground : "#17171e"
                        inactiveTextColor: root.timer ? root.timer.foreground : "#dcd7ba"
                        borderColor: root.timer ? root.timer.muted : "#54546D"
                        onClicked: if (root.timer) root.timer.reset()
                    }

                    PixelButton {
                        text: "SKIP"
                        fontSize: 8
                        fontFamily: root.pixelFontName
                        implicitWidth: 70
                        implicitHeight: 30
                        isActive: false
                        inactiveColor: root.timer ? root.timer.darkBackground : "#17171e"
                        inactiveTextColor: root.timer ? root.timer.foreground : "#dcd7ba"
                        borderColor: root.timer ? root.timer.muted : "#54546D"
                        onClicked: if (root.timer) root.timer.skip()
                    }
                }

                // 5. Keyboard shortcuts footer
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Space: Play/Pause  R: Reset  S: Skip  1-3: Mode"
                    textFormat: Text.PlainText
                    font.family: root.pixelFontName
                    font.pixelSize: 5
                    color: root.timer ? root.timer.muted : "#54546D"
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
