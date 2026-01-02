// Time.Clock.Suspending Tests.swift
// Clocks Tests

import StandardsTestSupport
import Testing

@testable import Clocks

extension Time.Clock.Suspending {
    #TestSuites
}

// MARK: - Unit Tests

extension Time.Clock.Suspending.Test.Unit {
    @Test("now returns current time")
    func nowReturnsCurrent() {
        let clock = Time.Clock.Suspending()
        let instant = clock.now
        // Should return a value representing time since epoch
        // We verify by checking duration to a slightly later instant is positive
        let later = clock.now
        let duration = instant.duration(to: later)
        #expect(duration >= .zero)
    }

    @Test("now advances over time")
    func nowAdvances() async throws {
        let clock = Time.Clock.Suspending()
        let before = clock.now
        try await Task.sleep(for: .milliseconds(10))
        let after = clock.now
        #expect(after > before)
    }

    @Test("minimumResolution is one nanosecond")
    func minimumResolution() {
        let clock = Time.Clock.Suspending()
        #expect(clock.minimumResolution == .nanoseconds(1))
    }

    @Test("static Instant.now matches instance now")
    func staticNowMatchesInstance() {
        let clock = Time.Clock.Suspending()
        let instanceNow = clock.now
        let staticNow = Time.Clock.Suspending.Instant.now
        // Should be very close (within a millisecond)
        let diff = instanceNow.duration(to: staticNow)
        #expect(diff.components.seconds == 0)
        #expect(abs(diff.components.attoseconds) < 1_000_000_000_000_000)  // < 1ms
    }

    @Test("sleep completes after duration")
    func sleepCompletes() async throws {
        let clock = Time.Clock.Suspending()
        let before = clock.now
        let deadline = before.advanced(by: .milliseconds(50))
        try await clock.sleep(until: deadline)
        let after = clock.now
        // Should have waited at least 50ms
        let elapsed = before.duration(to: after)
        #expect(elapsed >= .milliseconds(50))
    }

    @Test("conforms to Clock protocol")
    func conformsToClock() async throws {
        let clock: any Clock = Time.Clock.Suspending()
        _ = clock.now
        _ = clock.minimumResolution
    }

    @Test("duration between instants is correct")
    func durationBetweenInstants() {
        let clock = Time.Clock.Suspending()
        let now = clock.now
        let later = now.advanced(by: .seconds(5))
        let duration = now.duration(to: later)
        #expect(duration == .seconds(5))
    }
}

// MARK: - Edge Cases

extension Time.Clock.Suspending.Test.EdgeCase {
    @Test("sleep with past deadline completes immediately")
    func sleepWithPastDeadline() async throws {
        let clock = Time.Clock.Suspending()
        let past = clock.now.advanced(by: .seconds(-10))
        let before = ContinuousClock.now
        try await clock.sleep(until: past)
        let elapsed = before.duration(to: ContinuousClock.now)
        // Should complete almost immediately
        #expect(elapsed < .milliseconds(100))
    }

    @Test("sleep with current time completes immediately")
    func sleepWithCurrentTime() async throws {
        let clock = Time.Clock.Suspending()
        let before = ContinuousClock.now
        try await clock.sleep(until: clock.now)
        let elapsed = before.duration(to: ContinuousClock.now)
        #expect(elapsed < .milliseconds(100))
    }

    @Test("cancelled sleep throws CancellationError")
    func cancelledSleep() async {
        let clock = Time.Clock.Suspending()
        let task = Task {
            try await clock.sleep(until: clock.now.advanced(by: .seconds(100)))
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
        let clock = Time.Clock.Suspending()
        let now = clock.now
        let earlier = now.advanced(by: .seconds(-5))
        #expect(earlier < now)
        #expect(now.duration(to: earlier) == .seconds(-5))
    }

    @Test("instant equality works")
    func instantEquality() {
        let clock = Time.Clock.Suspending()
        let now = clock.now
        let same = now.advanced(by: .zero)
        #expect(now == same)
    }

    @Test("multiple clocks share same time source")
    func multipleClocksShareTime() {
        let clock1 = Time.Clock.Suspending()
        let clock2 = Time.Clock.Suspending()
        let now1 = clock1.now
        let now2 = clock2.now
        // Should be extremely close
        let diff = now1.duration(to: now2)
        #expect(abs(diff.components.attoseconds) < 1_000_000_000_000_000)  // < 1ms
    }

    @Test("suspending clock differs from continuous clock type")
    func differentClockTypes() {
        // This is a compile-time check - the types should be distinct
        let suspending = Time.Clock.Suspending()
        let continuous = Time.Clock.Continuous()

        let suspendingNow = suspending.now
        let continuousNow = continuous.now

        // These are different types - can't compare directly
        // Just verify they both exist and have positive durations from their zeroes
        let suspendingLater = suspending.now
        let continuousLater = continuous.now
        #expect(suspendingNow.duration(to: suspendingLater) >= .zero)
        #expect(continuousNow.duration(to: continuousLater) >= .zero)
    }
}

// MARK: - Performance

extension Time.Clock.Suspending.Test.Performance {
    @Test("now access is fast", .timed(iterations: 1000, warmup: 100))
    func nowAccessSpeed() {
        let clock = Time.Clock.Suspending()
        for _ in 0..<1000 {
            _ = clock.now
        }
    }

    @Test("instant arithmetic", .timed(iterations: 1000, warmup: 100))
    func instantArithmetic() {
        let clock = Time.Clock.Suspending()
        var instant = clock.now
        for _ in 0..<1000 {
            instant = instant.advanced(by: .nanoseconds(1))
        }
    }
}
