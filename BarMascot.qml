import QtQuick
import "MascotSprites.js" as SpriteData

Item {
    id: root

    property string mascotType: "blob" // "blob", "tux", "claude_critter", "ghost"
    property bool isResting: false
    property bool isRunning: false
    property color primaryColor: "#957fb8"
    property color secondaryColor: "#dcd7ba"
    property color darkEyeColor: "#111116"
    property color redColor: "#c34043"
    property color greenColor: "#76946a"
    property color yellowColor: "#c0a36e"
    property color orangeColor: "#c17158"
    property color blueColor: "#7e9cd8"
    property color cyanColor: "#6a9589"

    // Display dimensions in bar
    property real targetSize: 22
    implicitWidth: targetSize
    implicitHeight: targetSize

    property int animFrame: 0

    // Ultra-lightweight animation timer:
    // Only runs when the Pomodoro timer is running or resting.
    // When paused/idle, stays on frame 0 to save 100% CPU/GPU resources.
    Timer {
        id: animTimer
        interval: root.isResting ? 550 : 380
        running: root.isRunning || root.isResting
        repeat: true
        onTriggered: {
            root.animFrame = (root.animFrame + 1) % 4
        }
    }

    onIsRunningChanged: {
        if (!root.isRunning && !root.isResting) {
            root.animFrame = 0
        }
    }

    onMascotTypeChanged: {
        root.animFrame = 0
        spriteSheetCanvas.requestPaint()
    }
    onIsRestingChanged: {
        root.animFrame = 0
        spriteSheetCanvas.requestPaint()
    }
    onPrimaryColorChanged: spriteSheetCanvas.requestPaint()
    onSecondaryColorChanged: spriteSheetCanvas.requestPaint()

    // Viewport with clipping: hides all frames except current
    Item {
        id: viewport
        anchors.centerIn: parent
        width: root.targetSize
        height: root.targetSize
        clip: true

        // Scale 32x32 sprite down to targetSize
        Item {
            id: scaler
            width: 32
            height: 32
            scale: root.targetSize / 32.0
            transformOrigin: Item.TopLeft

            // Pre-rendered 4-frame spritesheet (128x32).
            // Canvas renders ONLY ONCE when theme/mascot changes, NEVER during animation!
            // Animating is pure GPU vertex translate (x offset), zero GPU overhead.
            Canvas {
                id: spriteSheetCanvas
                width: 128
                height: 32
                x: -root.animFrame * 32
                y: 0
                renderTarget: Canvas.Image
                renderStrategy: Canvas.Immediate

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.imageSmoothingEnabled = false
                    ctx.clearRect(0, 0, width, height)

                    var m = root.mascotType
                    var rest = root.isResting

                    var pal = {
                        '.': null,
                        'P': root.primaryColor,
                        'D': Qt.darker(root.primaryColor, 1.25),
                        'L': Qt.lighter(root.primaryColor, 1.3),
                        'R': root.redColor,
                        'E': root.secondaryColor,
                        'W': "#F8F8FF",
                        'K': root.darkEyeColor,
                        'B': "#20202C",
                        'Y': root.yellowColor,
                        'O': Qt.darker(root.yellowColor, 1.25),
                        'C': root.cyanColor,
                        'T': "#4A4A5E",
                        'Z': root.secondaryColor,
                        'A': root.orangeColor,
                        'G': root.blueColor
                    }

                    // Draw all 4 animation frames side by side (x = frame * 32)
                    for (var f = 0; f < 4; f++) {
                        var key = m + "_" + (rest ? "rest" : "focus") + "_" + f
                        var sprite = SpriteData.Sprites[key]
                        if (!sprite) {
                            key = m + "_" + (rest ? "rest" : "focus") + "_0"
                            sprite = SpriteData.Sprites[key]
                        }
                        if (!sprite) continue

                        var xOffset = f * 32

                        for (var y = 0; y < 32; y++) {
                            var row = sprite[y]
                            if (!row) continue
                            for (var x = 0; x < 32; x++) {
                                var ch = row[x]
                                if (ch !== '.') {
                                    var col = pal[ch]
                                    if (col) {
                                        ctx.fillStyle = col
                                        ctx.fillRect(xOffset + x, y, 1, 1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
