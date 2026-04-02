import Foundation

// MARK: - Scale Options

struct ScaleOption: Identifiable, Hashable {
    let id: String
    let label: String
    let ratio: Double
    let brand: String
    let tracks: [TrackOption]
}

struct TrackOption: Identifiable, Hashable {
    let id: String
    let label: String
    let sublabel: String
    let mm: Double
}

let scaleOptions: [ScaleOption] = [
    ScaleOption(
        id: "n", label: "N Scale", ratio: 160, brand: "Bachmann E-Z Track",
        tracks: [
            TrackOption(id: "44810", label: "124mm", sublabel: "#44810 · 4.875\"", mm: 124),
            TrackOption(id: "44819", label: "222mm", sublabel: "#44819 · 8.75\"", mm: 222.25),
        ]
    ),
    ScaleOption(
        id: "o", label: "O Scale", ratio: 48, brand: "Lionel FasTrack",
        tracks: [
            TrackOption(id: "6-12014", label: "10\"", sublabel: "#6-12014 · 254mm", mm: 254),
            TrackOption(id: "6-12042", label: "30\"", sublabel: "#6-12042 · 762mm", mm: 762),
        ]
    ),
]

// MARK: - Trigger Modes

enum TriggerMode: String, CaseIterable, Identifiable {
    case classic
    case release
    case hold

    var id: String { rawValue }

    var label: String {
        switch self {
        case .classic: return "Tap / Tap"
        case .release: return "Release Start"
        case .hold: return "Hold"
        }
    }

    var icon: String {
        switch self {
        case .classic: return "◉ ◉"
        case .release: return "◎ ◉"
        case .hold: return "◉━◉"
        }
    }

    var desc: String {
        switch self {
        case .classic: return "Tap to start, tap to stop"
        case .release: return "Hold to arm, release to start, tap to stop"
        case .hold: return "Press to start, release to stop"
        }
    }
}

// MARK: - Timer Phase

enum TimerPhase {
    case idle
    case armed
    case running
    case result
}

// MARK: - Speed Result

struct SpeedResult: Identifiable {
    let id = UUID()
    let elapsed: TimeInterval // seconds
    let modelSpeed_mps: Double
    let scaleSpeed_kph: Double
    let realSpeed_kph: Double
    let realSpeed_mph: Double
    let realSpeed_mps: Double
    let trackMM: Double
    let trackRealM: Double
    let scaleLabel: String
}

// MARK: - Helpers

func formatTime(_ seconds: TimeInterval) -> String {
    let ms = seconds * 1000
    if ms < 1000 {
        return String(format: "%.0fms", ms)
    } else if ms < 60000 {
        return String(format: "%.2fs", seconds)
    } else {
        let m = Int(ms / 60000)
        let s = (ms.truncatingRemainder(dividingBy: 60000)) / 1000
        return String(format: "%dm %.1fs", m, s)
    }
}

func computeResult(elapsed: TimeInterval, trackMM: Double, scaleRatio: Double, scaleLabel: String) -> SpeedResult {
    let trackRealM = (trackMM / 1000.0) * scaleRatio
    let modelSpeed_mps = (trackMM / 1000.0) / elapsed
    let realSpeed_mps = trackRealM / elapsed
    let realSpeed_kph = realSpeed_mps * 3.6
    let realSpeed_mph = realSpeed_kph * 0.621371
    let scaleSpeed_kph = modelSpeed_mps * 3.6

    return SpeedResult(
        elapsed: elapsed,
        modelSpeed_mps: modelSpeed_mps,
        scaleSpeed_kph: scaleSpeed_kph,
        realSpeed_kph: realSpeed_kph,
        realSpeed_mph: realSpeed_mph,
        realSpeed_mps: realSpeed_mps,
        trackMM: trackMM,
        trackRealM: trackRealM,
        scaleLabel: scaleLabel
    )
}
