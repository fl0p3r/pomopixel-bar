import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons

Item {
    id: root

    // ==========================================
    // 1. THEME PALETTE (Synced with Omarchy colors.toml)
    // ==========================================
    property color background: Commons.Color.background
    property color foreground: Commons.Color.foreground
    property color accent: Commons.Color.accent
    property color urgent: Commons.Color.urgent
    property color muted: Commons.Color.muted

    property color darkBackground: "#17171e"
    property color darkerBackground: "#111116"
    property color brightForeground: "#dcd7ba"

    property color red: Commons.Color.urgent
    property color green: "#76946a"
    property color yellow: "#c0a36e"
    property color orange: "#c17158"
    property color blue: "#7e9cd8"
    property color magenta: "#957fb8"
    property color cyan: "#6a9589"

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string themeColorsPath: homeDir + "/.local/state/omarchy/current/theme/colors.toml"
    readonly property string configFilePath: homeDir + "/.config/pomopixel/config.json"

    FileView {
        id: themeWatcher
        path: root.themeColorsPath
        watchChanges: true
        printErrors: false
        onLoaded: root.loadTheme(text())
        onFileChanged: reload()
    }

    function loadTheme(raw) {
        if (!raw) return
        var lines = String(raw).split("\n")
        for (var i = 0; i < lines.length; i++) {
            var m = lines[i].match(/^\s*([A-Za-z0-9_-]+)\s*=\s*["']?(#[0-9A-Fa-f]{6})/)
            if (!m) continue
            var k = m[1]
            var c = m[2]
            if (k === "accent") root.accent = c
            else if (k === "background") root.background = c
            else if (k === "dark_background") root.darkBackground = c
            else if (k === "darker_background") root.darkerBackground = c
            else if (k === "foreground") root.foreground = c
            else if (k === "bright_foreground") root.brightForeground = c
            else if (k === "muted") root.muted = c
            else if (k === "red") root.red = c
            else if (k === "green") root.green = c
            else if (k === "yellow") root.yellow = c
            else if (k === "orange") root.orange = c
            else if (k === "blue") root.blue = c
            else if (k === "magenta") root.magenta = c
            else if (k === "cyan") root.cyan = c
        }
    }

    // ==========================================
    // 2. CONFIGURATION (pomopixel config.json)
    // ==========================================
    property int focusDuration: 25
    property int shortBreakDuration: 5
    property int longBreakDuration: 15
    property int longBreakInterval: 4
    property bool soundEnabled: true
    property real volume: 1.0
    property bool notificationsEnabled: true
    property string mascot: "blob"
    property string customAccent: ""

    FileView {
        id: configWatcher
        path: root.configFilePath
        watchChanges: true
        printErrors: false
        onLoaded: root.loadConfig(text())
        onFileChanged: reload()
    }

    function loadConfig(raw) {
        if (!raw) return
        try {
            var data = JSON.parse(raw)
            if (data.focusDuration !== undefined) root.focusDuration = data.focusDuration
            if (data.shortBreakDuration !== undefined) root.shortBreakDuration = data.shortBreakDuration
            if (data.longBreakDuration !== undefined) root.longBreakDuration = data.longBreakDuration
            if (data.longBreakInterval !== undefined) root.longBreakInterval = data.longBreakInterval
            if (data.soundEnabled !== undefined) root.soundEnabled = data.soundEnabled
            if (data.volume !== undefined) root.volume = data.volume
            if (data.notificationsEnabled !== undefined) root.notificationsEnabled = data.notificationsEnabled
            if (data.mascot !== undefined) root.mascot = data.mascot
            if (data.customAccent !== undefined) root.customAccent = data.customAccent

            if (!root.isRunning) {
                root.totalSeconds = root.getDurationForMode(root.mode) * 60
                root.remainingSeconds = root.totalSeconds
            }
        } catch(e) {}
    }

    function saveConfig() {
        var cfg = {
            "focusDuration": root.focusDuration,
            "shortBreakDuration": root.shortBreakDuration,
            "longBreakDuration": root.longBreakDuration,
            "longBreakInterval": root.longBreakInterval,
            "soundEnabled": root.soundEnabled,
            "volume": root.volume,
            "notificationsEnabled": root.notificationsEnabled,
            "mascot": root.mascot,
            "customAccent": root.customAccent
        }
        var jsonStr = JSON.stringify(cfg, null, 2)
        var cmd = "mkdir -p " + root.homeDir + "/.config/pomopixel && cat << 'EOF' > " + root.configFilePath + "\n" + jsonStr + "\nEOF"
        Quickshell.execDetached(["bash", "-c", cmd])
    }

    function nextMascot() {
        var list = ["blob", "tux", "claude_critter", "ghost"]
        var idx = list.indexOf(root.mascot)
        var nextIdx = (idx + 1) % list.length
        root.mascot = list[nextIdx]
        saveConfig()
    }

    // ==========================================
    // 3. TIMER STATE MACHINE
    // ==========================================
    property int mode: 0 // 0 = Focus, 1 = Short Break, 2 = Long Break
    property int remainingSeconds: 25 * 60
    property int totalSeconds: 25 * 60
    property bool isRunning: false
    property int completedCycles: 0
    property int todayCycles: 0

    readonly property string modeName: mode === 0 ? "FOCUS TIME" : (mode === 1 ? "SHORT BREAK" : "LONG BREAK")
    readonly property bool isMascotResting: mode === 1 || mode === 2
    readonly property real progress: totalSeconds > 0 ? (1.0 - (remainingSeconds / totalSeconds)) : 0.0

    readonly property string formattedTime: {
        var m = Math.floor(remainingSeconds / 60)
        var s = remainingSeconds % 60
        var mStr = (m < 10 ? "0" : "") + m
        var sStr = (s < 10 ? "0" : "") + s
        return mStr + ":" + sStr
    }

    readonly property string barText: {
        var icon = mode === 0 ? "🍅 " : (mode === 1 ? "☕ " : "🌴 ")
        return icon + formattedTime
    }

    readonly property color currentAccentColor: customAccent !== "" ? customAccent : accent

    function getDurationForMode(m) {
        if (m === 0) return focusDuration
        if (m === 1) return shortBreakDuration
        if (m === 2) return longBreakDuration
        return 25
    }

    function setMode(newMode) {
        mode = newMode
        isRunning = false
        totalSeconds = getDurationForMode(mode) * 60
        remainingSeconds = totalSeconds
        playClick()
    }

    function toggle() {
        if (isRunning) {
            isRunning = false
            playClick()
        } else {
            isRunning = true
            playStart()
        }
    }

    function reset() {
        isRunning = false
        remainingSeconds = totalSeconds
        playClick()
    }

    function skip() {
        if (mode === 0) {
            completedCycles++
            todayCycles++
            if (completedCycles % longBreakInterval === 0) {
                setMode(2)
            } else {
                setMode(1)
            }
        } else {
            setMode(0)
        }
    }

    Timer {
        id: secondTimer
        interval: 1000
        repeat: true
        running: root.isRunning
        onTriggered: {
            if (root.remainingSeconds > 0) {
                root.remainingSeconds--
            } else {
                root.handleSessionCompleted()
            }
        }
    }

    function handleSessionCompleted() {
        root.isRunning = false
        playFinish()

        if (root.mode === 0) {
            root.completedCycles++
            root.todayCycles++
            sendNotification("Pomopixel Focus Complete!", "Great job! Time to take a well-deserved break.")
            if (root.completedCycles % root.longBreakInterval === 0) {
                root.mode = 2
            } else {
                root.mode = 1
            }
        } else {
            sendNotification("Pomopixel Break Finished!", "Break is over. Ready to jump back into focus?")
            root.mode = 0
        }

        root.totalSeconds = root.getDurationForMode(root.mode) * 60
        root.remainingSeconds = root.totalSeconds
    }

    // ==========================================
    // 4. AUDIO & NOTIFICATIONS
    // ==========================================
    function playAudio(filename) {
        if (!soundEnabled) return
        var soundPath = Qt.resolvedUrl("assets/" + filename).toString().replace("file://", "")
        Quickshell.execDetached(["pw-play", "--volume", String(root.volume), soundPath])
    }

    function playClick() { playAudio("click.wav") }
    function playStart() { playAudio("start.wav") }
    function playFinish() { playAudio("finish.wav") }

    function sendNotification(title, message) {
        if (!notificationsEnabled) return
        var iconPath = Qt.resolvedUrl("assets/pomopixel-desktop.png").toString().replace("file://", "")
        Quickshell.execDetached(["notify-send", "-a", "Pomopixel", "-i", iconPath, title, message])
    }
}
