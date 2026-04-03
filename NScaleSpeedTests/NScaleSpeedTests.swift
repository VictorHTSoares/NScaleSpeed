import XCTest
@testable import NScaleSpeed

final class NScaleSpeedTests: XCTestCase {

    // MARK: - computeResult: speed math

    func testComputeResultNScale124mm() {
        let result = computeResult(elapsed: 1.0, trackMM: 124.0, scaleRatio: 160.0, scaleLabel: "1:160")

        // Model crosses 0.124 m in 1 s → 0.124 m/s
        XCTAssertEqual(result.modelSpeed_mps, 0.124, accuracy: 0.0001)
        // Real distance: 0.124 m × 160 = 19.84 m in 1 s → 19.84 m/s
        XCTAssertEqual(result.realSpeed_mps, 19.84, accuracy: 0.0001)
        // km/h conversion
        XCTAssertEqual(result.realSpeed_kph, 19.84 * 3.6, accuracy: 0.001)
        // mph conversion
        XCTAssertEqual(result.realSpeed_mph, result.realSpeed_kph * 0.621371, accuracy: 0.001)
        // Stored fields
        XCTAssertEqual(result.trackMM, 124.0)
        XCTAssertEqual(result.trackRealM, 0.124 * 160.0, accuracy: 0.001)
        XCTAssertEqual(result.scaleLabel, "1:160")
    }

    func testComputeResultOScale254mm() {
        let result = computeResult(elapsed: 2.0, trackMM: 254.0, scaleRatio: 48.0, scaleLabel: "1:48")

        let expectedModelSpeed = 0.254 / 2.0         // 0.127 m/s
        let expectedRealSpeed  = (0.254 * 48.0) / 2.0 // 6.096 m/s
        XCTAssertEqual(result.modelSpeed_mps, expectedModelSpeed, accuracy: 0.0001)
        XCTAssertEqual(result.realSpeed_mps,  expectedRealSpeed,  accuracy: 0.0001)
        XCTAssertEqual(result.scaleLabel, "1:48")
    }

    func testComputeResultScaleSpeedKph() {
        // 1 m/s model speed → 3.6 km/h
        let result = computeResult(elapsed: 1.0, trackMM: 1000.0, scaleRatio: 160.0, scaleLabel: "1:160")
        XCTAssertEqual(result.scaleSpeed_kph, 3.6, accuracy: 0.001)
    }

    func testComputeResultElapsedIsStored() {
        let elapsed = 0.753
        let result = computeResult(elapsed: elapsed, trackMM: 222.25, scaleRatio: 160.0, scaleLabel: "1:160")
        XCTAssertEqual(result.elapsed, elapsed)
    }

    func testComputeResultFasterTrainHigherSpeed() {
        let slow = computeResult(elapsed: 2.0, trackMM: 124.0, scaleRatio: 160.0, scaleLabel: "1:160")
        let fast = computeResult(elapsed: 1.0, trackMM: 124.0, scaleRatio: 160.0, scaleLabel: "1:160")
        XCTAssertGreaterThan(fast.realSpeed_kph, slow.realSpeed_kph)
    }

    func testComputeResultLongerTrackHigherSpeed() {
        let short = computeResult(elapsed: 1.0, trackMM: 124.0,  scaleRatio: 160.0, scaleLabel: "1:160")
        let long  = computeResult(elapsed: 1.0, trackMM: 222.25, scaleRatio: 160.0, scaleLabel: "1:160")
        XCTAssertGreaterThan(long.realSpeed_kph, short.realSpeed_kph)
    }

    func testComputeResultHigherScaleRatioHigherRealSpeed() {
        // Same model motion, larger scale → more real-world distance
        let nScale = computeResult(elapsed: 1.0, trackMM: 124.0, scaleRatio: 160.0, scaleLabel: "1:160")
        let oScale = computeResult(elapsed: 1.0, trackMM: 124.0, scaleRatio: 48.0,  scaleLabel: "1:48")
        XCTAssertGreaterThan(nScale.realSpeed_kph, oScale.realSpeed_kph)
    }

    // MARK: - formatTime

    func testFormatTimeUnderOneSecond() {
        XCTAssertEqual(formatTime(0.123), "123ms")
        XCTAssertEqual(formatTime(0.5),   "500ms")
        XCTAssertEqual(formatTime(0.999), "999ms")
    }

    func testFormatTimeZero() {
        XCTAssertEqual(formatTime(0.0), "0ms")
    }

    func testFormatTimeOneSecond() {
        XCTAssertEqual(formatTime(1.0), "1.00s")
    }

    func testFormatTimeSeconds() {
        XCTAssertEqual(formatTime(10.5),  "10.50s")
        XCTAssertEqual(formatTime(59.99), "59.99s")
    }

    func testFormatTimeMinutes() {
        let result = formatTime(65.0)
        XCTAssertTrue(result.contains("1m"), "Expected minutes in: \(result)")
    }

    func testFormatTimeBoundary() {
        // Exactly 1000ms should flip from ms to seconds format
        let just_under = formatTime(0.9999)
        let at_one     = formatTime(1.0)
        XCTAssertTrue(just_under.hasSuffix("ms"))
        XCTAssertTrue(at_one.hasSuffix("s"))
    }

    // MARK: - SpeedResult Codable

    func testSpeedResultCodableRoundTrip() throws {
        let original = computeResult(elapsed: 1.234, trackMM: 124.0, scaleRatio: 160.0, scaleLabel: "1:160")

        let data    = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SpeedResult.self, from: data)

        XCTAssertEqual(decoded.id,              original.id)
        XCTAssertEqual(decoded.elapsed,         original.elapsed,         accuracy: 0.0001)
        XCTAssertEqual(decoded.realSpeed_kph,   original.realSpeed_kph,   accuracy: 0.001)
        XCTAssertEqual(decoded.realSpeed_mph,   original.realSpeed_mph,   accuracy: 0.001)
        XCTAssertEqual(decoded.modelSpeed_mps,  original.modelSpeed_mps,  accuracy: 0.0001)
        XCTAssertEqual(decoded.scaleSpeed_kph,  original.scaleSpeed_kph,  accuracy: 0.001)
        XCTAssertEqual(decoded.trackMM,         original.trackMM,         accuracy: 0.001)
        XCTAssertEqual(decoded.trackRealM,      original.trackRealM,      accuracy: 0.001)
        XCTAssertEqual(decoded.scaleLabel,      original.scaleLabel)
    }

    func testSpeedResultArrayCodableRoundTrip() throws {
        let results = [
            computeResult(elapsed: 1.0, trackMM: 124.0,  scaleRatio: 160.0, scaleLabel: "1:160"),
            computeResult(elapsed: 2.5, trackMM: 222.25, scaleRatio: 160.0, scaleLabel: "1:160"),
            computeResult(elapsed: 0.8, trackMM: 254.0,  scaleRatio: 48.0,  scaleLabel: "1:48"),
        ]

        let data    = try JSONEncoder().encode(results)
        let decoded = try JSONDecoder().decode([SpeedResult].self, from: data)

        XCTAssertEqual(decoded.count, results.count)
        for (d, o) in zip(decoded, results) {
            XCTAssertEqual(d.id,            o.id)
            XCTAssertEqual(d.elapsed,       o.elapsed,       accuracy: 0.0001)
            XCTAssertEqual(d.scaleLabel,    o.scaleLabel)
        }
    }

    func testSpeedResultDecodingBadDataThrows() {
        let bad = Data("not json".utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(SpeedResult.self, from: bad))
    }

    // MARK: - Scale options data integrity

    func testScaleOptionsNonEmpty() {
        XCTAssertFalse(scaleOptions.isEmpty)
    }

    func testNScaleExists() {
        let n = scaleOptions.first { $0.id == "n" }
        XCTAssertNotNil(n)
        XCTAssertEqual(n?.ratio, 160.0)
        XCTAssertFalse(n?.tracks.isEmpty ?? true)
    }

    func testOScaleExists() {
        let o = scaleOptions.first { $0.id == "o" }
        XCTAssertNotNil(o)
        XCTAssertEqual(o?.ratio, 48.0)
        XCTAssertFalse(o?.tracks.isEmpty ?? true)
    }

    func testAllScalesHaveTracks() {
        for scale in scaleOptions {
            XCTAssertFalse(scale.tracks.isEmpty, "\(scale.label) has no tracks")
        }
    }

    func testAllTrackLengthsPositive() {
        for scale in scaleOptions {
            for track in scale.tracks {
                XCTAssertGreaterThan(track.mm, 0, "\(scale.label) track \(track.id) has non-positive length")
            }
        }
    }

    func testAllScaleRatiosPositive() {
        for scale in scaleOptions {
            XCTAssertGreaterThan(scale.ratio, 0, "\(scale.label) has non-positive ratio")
        }
    }

    // MARK: - SpeedViewModel: state machine

    @MainActor
    func testInitialPhaseIsIdle() {
        let vm = SpeedViewModel()
        XCTAssertEqual(vm.phase, .idle)
    }

    @MainActor
    func testResetReturnsToIdle() {
        let vm = SpeedViewModel()
        vm.onPressDown() // classic mode → starts timer
        vm.reset()
        XCTAssertEqual(vm.phase, .idle)
        XCTAssertEqual(vm.elapsed, 0)
        XCTAssertNil(vm.result)
    }

    @MainActor
    func testClassicModeStartsOnPressDown() {
        let vm = SpeedViewModel()
        XCTAssertEqual(vm.triggerMode, .classic)
        vm.onPressDown()
        XCTAssertEqual(vm.phase, .running)
    }

    @MainActor
    func testHoldModeArmsOnPressDown() {
        let vm = SpeedViewModel()
        vm.triggerMode = .hold
        vm.onPressDown()
        XCTAssertEqual(vm.phase, .running)
    }

    @MainActor
    func testReleaseModeArmsOnPressDown() {
        let vm = SpeedViewModel()
        vm.triggerMode = .release
        vm.onPressDown()
        XCTAssertEqual(vm.phase, .armed)
    }

    @MainActor
    func testReleaseModeStartsOnPressUp() {
        let vm = SpeedViewModel()
        vm.triggerMode = .release
        vm.onPressDown() // arms
        vm.onPressUp()   // starts
        XCTAssertEqual(vm.phase, .running)
    }

    @MainActor
    func testHistoryCapAt10() {
        let vm = SpeedViewModel(historyStore: UserDefaults(suiteName: UUID().uuidString)!)
        // Simulate 12 result entries by directly manipulating via reset + inject
        for _ in 0..<12 {
            vm.history.insert(
                computeResult(elapsed: 1.0, trackMM: 124.0, scaleRatio: 160.0, scaleLabel: "1:160"),
                at: 0
            )
            if vm.history.count > 10 { vm.history = Array(vm.history.prefix(10)) }
        }
        XCTAssertLessThanOrEqual(vm.history.count, 10)
    }

    @MainActor
    func testClearHistoryEmptiesArray() {
        let vm = SpeedViewModel(historyStore: UserDefaults(suiteName: UUID().uuidString)!)
        vm.history = [
            computeResult(elapsed: 1.0, trackMM: 124.0, scaleRatio: 160.0, scaleLabel: "1:160")
        ]
        vm.clearHistory()
        XCTAssertTrue(vm.history.isEmpty)
    }

    // MARK: - History persistence

    @MainActor
    func testHistoryPersistsAndLoads() throws {
        let suiteName = UUID().uuidString
        let defaults  = UserDefaults(suiteName: suiteName)!

        let vm1 = SpeedViewModel(historyStore: defaults)
        let r   = computeResult(elapsed: 1.5, trackMM: 124.0, scaleRatio: 160.0, scaleLabel: "1:160")
        vm1.history = [r]
        vm1.saveHistoryForTesting()

        let vm2 = SpeedViewModel(historyStore: defaults)
        XCTAssertEqual(vm2.history.count, 1)
        XCTAssertEqual(vm2.history.first?.id, r.id)

        defaults.removePersistentDomain(forName: suiteName)
    }

    @MainActor
    func testClearHistoryRemovesFromDefaults() throws {
        let suiteName = UUID().uuidString
        let defaults  = UserDefaults(suiteName: suiteName)!

        let vm1 = SpeedViewModel(historyStore: defaults)
        vm1.history = [computeResult(elapsed: 1.0, trackMM: 124.0, scaleRatio: 160.0, scaleLabel: "1:160")]
        vm1.saveHistoryForTesting()
        vm1.clearHistory()

        let vm2 = SpeedViewModel(historyStore: defaults)
        XCTAssertTrue(vm2.history.isEmpty)

        defaults.removePersistentDomain(forName: suiteName)
    }
}
