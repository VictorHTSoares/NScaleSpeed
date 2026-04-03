import SwiftUI
import Combine

private class DisplayLinkProxy: NSObject {
    weak var target: SpeedViewModel?
    init(_ target: SpeedViewModel) { self.target = target }
    @objc func tick(_ link: CADisplayLink) { target?.tick(link) }
}

class SpeedViewModel: ObservableObject {
    @Published var phase: TimerPhase = .idle
    @Published var elapsed: TimeInterval = 0
    @Published var result: SpeedResult?
    @Published var history: [SpeedResult] = []
    @Published var selectedScale: ScaleOption = scaleOptions[0]
    @Published var selectedTrack: TrackOption = scaleOptions[0].tracks[0]
    @Published var triggerMode: TriggerMode = .classic

    private var startTime: Date?
    private var displayLink: CADisplayLink?
    private let historyKey = "speedHistory"

    init() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let saved = try? JSONDecoder().decode([SpeedResult].self, from: data) {
            history = saved
        }
    }

    var canChangeSettings: Bool {
        phase == .idle || phase == .result
    }

    var trackRealM: Double {
        (selectedTrack.mm / 1000.0) * selectedScale.ratio
    }

    deinit {
        displayLink?.invalidate()
    }

    // MARK: - Timer

    private func startTimer() {
        startTime = Date()
        elapsed = 0
        result = nil
        phase = .running
        hapticImpact(.medium)

        displayLink?.invalidate()
        let link = CADisplayLink(target: DisplayLinkProxy(self), selector: #selector(DisplayLinkProxy.tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    @objc fileprivate func tick(_ link: CADisplayLink) {
        guard let start = startTime else { return }
        elapsed = Date().timeIntervalSince(start)
    }

    private func stopTimer() {
        guard let start = startTime else { return }
        displayLink?.invalidate()
        displayLink = nil
        let final = Date().timeIntervalSince(start)
        startTime = nil

        guard final >= 0.05 else {
            elapsed = 0
            phase = .idle
            return
        }

        elapsed = final
        phase = .result
        hapticImpact(.heavy)

        let r = computeResult(elapsed: final, trackMM: selectedTrack.mm, scaleRatio: selectedScale.ratio, scaleLabel: "1:\(Int(selectedScale.ratio))")
        result = r
        history.insert(r, at: 0)
        if history.count > 10 { history = Array(history.prefix(10)) }
        saveHistory()
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    // MARK: - Public Actions

    func reset() {
        displayLink?.invalidate()
        displayLink = nil
        startTime = nil
        elapsed = 0
        result = nil
        phase = .idle
    }

    func clearHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: historyKey)
    }

    // MARK: - Gesture Handlers

    func onPressDown() {
        switch triggerMode {
        case .classic:
            if phase == .idle || phase == .result {
                startTimer()
            } else if phase == .running {
                stopTimer()
            }
        case .release:
            if phase == .idle || phase == .result {
                phase = .armed
                result = nil
                elapsed = 0
                hapticImpact(.light)
            } else if phase == .running {
                stopTimer()
            }
        case .hold:
            if phase == .idle || phase == .result {
                startTimer()
            }
        }
    }

    func onPressUp() {
        switch triggerMode {
        case .classic:
            break
        case .release:
            if phase == .armed {
                startTimer()
            }
        case .hold:
            if phase == .running {
                stopTimer()
            }
        }
    }

    // MARK: - Haptics

    private func hapticImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
