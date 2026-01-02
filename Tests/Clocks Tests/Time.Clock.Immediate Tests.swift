// Time.Clock.Immediate Tests.swift
// Clocks Tests

import StandardsTestSupport
import Testing

@testable import Clocks

extension Time.Clock.Immediate {
    #TestSuites
}

// MARK: - Unit Tests

extension Time.Clock.Immediate.Test.Unit {
    @Test("initial now is zero offset")
    func initialNow() {
        let clock = Time.Clock.Immediate()
        #expect(clock.now.offset == .zero)
    }

    @Test("init with custom offset")
    func initWithCustomOffset() {
        let clock = Time.Clock.Immediate(now: .init(offset: .seconds(100)))
        #expect(clock.now.offset == .seconds(100))
    }

    @Test("minimumResolution is zero")
    func minimumResolution() {
        let clock = Time.Clock.Immediate()
        #expect(clock.minimumResolution == .zero)
    }

    @Test("sleep advances now to deadline immediately")
    func sleepAdvancesNow() async throws {
        let clock = Time.Clock.Immediate()
        let deadline = clock.now.advanced(by: .seconds(100))
        try await clock.sleep(until: deadline, tolerance: nil)
        #expect(clock.now == deadline)
    }

    @Test("sleep does not actually suspend")
    func sleepDoesNotSuspend() async throws {
        let clock = Time.Clock.Immediate()
        let start = ContinuousClock.now
        try await clock.sleep(until: clock.now.advanced(by: .seconds(1000)), tolerance: nil)
        let elapsed = start.duration(to: ContinuousClock.now)
        // Should complete in well under a second (not 1000 seconds)
        #expect(elapsed < .seconds(1))
    }

    @Test("multiple sleeps advance sequentially")
    func multipleSleepsAdvance() async throws {
        let clock = Time.Clock.Immediate()
        try await clock.sleep(until: clock.now.advanced(by: .seconds(10)), tolerance: nil)
        #expect(clock.now.offset == .seconds(10))
        try await clock.sleep(until: clock.now.advanced(by: .seconds(5)), tolerance: nil)
        #expect(clock.now.offset == .seconds(15))
    }

    @Test("conforms to Clock protocol")
    func conformsToClock() async throws {
        let clock: any Clock = Time.Clock.Immediate()
        _ = clock.now
        _ = clock.minimumResolution
    }
}

// MARK: - Edge Cases

extension Time.Clock.Immediate.Test.EdgeCase {
    @Test("sleep with past deadline still updates now")
    func sleepWithPastDeadline() async throws {
        let clock = Time.Clock.Immediate(now: .init(offset: .seconds(100)))
        let pastDeadline = Time.Clock.Immediate.Instant(offset: .seconds(50))
        try await clock.sleep(until: pastDeadline, tolerance: nil)
        // now should be set to the deadline even if it's in the past
        #expect(clock.now.offset == .seconds(50))
    }

    @Test("cancelled sleep throws CancellationError")
    func cancelledSleep() async {
        let clock = Time.Clock.Immediate()

        let task = Task {
            // First cancel, then sleep - checkCancellation should throw
            try await Task.sleep(for: .zero)  // yield point
            try Task.checkCancellation()
            try await clock.sleep(until: clock.now.advanced(by: .seconds(1)), tolerance: nil)
        }
        task.cancel()

        do {
            try await task.value
            Issue.record("Expected CancellationError")
        } catch is CancellationError {
            // Expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("instant advanced by negative duration goes backward")
    func instantAdvancedByNegative() {
        let instant = Time.Clock.Immediate.Instant(offset: .seconds(10))
        let earlier = instant.advanced(by: .seconds(-5))
        #expect(earlier.offset == .seconds(5))
    }

    @Test("instant duration to earlier instant is negative")
    func durationToEarlierInstant() {
        let later = Time.Clock.Immediate.Instant(offset: .seconds(10))
        let earlier = Time.Clock.Immediate.Instant(offset: .seconds(5))
        let duration = later.duration(to: earlier)
        #expect(duration == .seconds(-5))
    }

    @Test("instant comparison works correctly")
    func instantComparison() {
        let a = Time.Clock.Immediate.Instant(offset: .seconds(5))
        let b = Time.Clock.Immediate.Instant(offset: .seconds(10))
        #expect(a < b)
        #expect(!(b < a))
        #expect(!(a < a))
    }

    @Test("concurrent sleeps are thread-safe")
    func concurrentSleeps() async throws {
        let clock = Time.Clock.Immediate()

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask {
                    try? await clock.sleep(
                        until: clock.now.advanced(by: .milliseconds(i)),
                        tolerance: nil
                    )
                }
            }
        }
        // Should complete without crashes
    }
}

// MARK: - Performance

extension Time.Clock.Immediate.Test.Performance {
    @Test("rapid sleeps", .timed(iterations: 100, warmup: 10))
    func rapidSleeps() async throws {
        let clock = Time.Clock.Immediate()
        for _ in 0..<100 {
            try await clock.sleep(until: clock.now.advanced(by: .milliseconds(1)), tolerance: nil)
        }
    }
}
