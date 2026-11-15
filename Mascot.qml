import QtQuick
import "MascotSprites.js" as SpriteData

Item {
    id: root

    property string mascotType: "blob" // "blob", "tux", "claude_critter", "ghost"
    property bool isResting: false
    property color primaryColor: "#957fb8"
    property color secondaryColor: "#dcd7ba"
    property color darkEyeColor: "#111116"
    property color redColor: "#c34043"
    property color greenColor: "#76946a"
    property color yellowColor: "#c0a36e"
    property color orangeColor: "#c17158"
    property color blueColor: "#7e9cd8"
    property color cyanColor: "#6a9589"
    property int pixelScale: 4
    property int animFrame: 0

    implicitWidth: 32 * pixelScale
    implicitHeight: 32 * pixelScale

    Timer {
        id: animTimer
        interval: root.isResting ? 450 : 250
        running: root.visible && root.opacity > 0
        repeat: true
        onTriggered: {
            root.animFrame = (root.animFrame + 1) % 4
            canvas.requestPaint()
        }
    }

    onMascotTypeChanged: {
        root.animFrame = 0
        canvas.requestPaint()
    }
    onIsRestingChanged: {
        root.animFrame = 0
        canvas.requestPaint()
    }
    onPrimaryColorChanged: canvas.requestPaint()
    onSecondaryColorChanged: canvas.requestPaint()
    onPixelScaleChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.centerIn: parent
        width: 32 * root.pixelScale
        height: 32 * root.pixelScale
        renderTarget: Canvas.Image
        renderStrategy: Canvas.Immediate

        onPaint: {
            var ctx = getContext("2d")
            ctx.imageSmoothingEnabled = false
            ctx.clearRect(0, 0, width, height)

            var m = root.mascotType
            var rest = root.isResting
            var f = root.animFrame % 4

            var key = m + "_" + (rest ? "rest" : "focus") + "_" + f
            var sprite = SpriteData.Sprites[key]
            if (!sprite) {
                key = m + "_" + (rest ? "rest" : "focus") + "_0"
                sprite = SpriteData.Sprites[key]
            }
            if (!sprite) return

            var ps = root.pixelScale

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

            for (var y = 0; y < 32; y++) {
                var row = sprite[y]
                if (!row) continue
                var startX = -1
                var lastCh = '.'
                for (var x = 0; x <= 32; x++) {
                    var ch = x < 32 ? row[x] : '.'
                    if (ch !== lastCh) {
                        if (lastCh !== '.' && pal[lastCh]) {
                            ctx.fillStyle = pal[lastCh]
                            ctx.fillRect(startX * ps, y * ps, (x - startX) * ps, ps)
                        }
                        startX = x
                        lastCh = ch
                    }
                }
            }
        }
    }
}
