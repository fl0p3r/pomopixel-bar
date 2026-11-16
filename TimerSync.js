.pragma library

// Shared singleton state across all monitor widget instances in the quickshell process.
var lastCompletedTimestamp = 0
var lastNotificationTimestamp = 0
var lastAudioTimestamp = 0

function tryClaimCompletion(now) {
    var t = now || Date.now()
    if (t - lastCompletedTimestamp < 4000) {
        return false
    }
    lastCompletedTimestamp = t
    return true
}

function tryClaimNotification(now) {
    var t = now || Date.now()
    if (t - lastNotificationTimestamp < 3000) {
        return false
    }
    lastNotificationTimestamp = t
    return true
}

function tryClaimAudio(now) {
    var t = now || Date.now()
    if (t - lastAudioTimestamp < 1500) {
        return false
    }
    lastAudioTimestamp = t
    return true
}
