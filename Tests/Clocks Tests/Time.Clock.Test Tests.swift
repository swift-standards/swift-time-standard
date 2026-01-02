// Time.Clock.Test Tests.swift
// Clocks Tests

import StandardsTestSupport
import Testing

@testable import Clocks

extension Time.Clock.Test {
    #TestSuites
}

// MARK: - Unit Tests

extension Time.Clock.Test.Test.Unit {
    @Test("initial now is zero offset")
    func initialNow() {
        let clock = Time.Clock.Test()
        #expect(clock.now.offset == .zero)
    }

    @Test("init with custom offset")
    func initWithCustomOffset() {
        let clock = Time.Clock.Test(now: .init(offset: .seconds(100)))
        #expect(clock.now.offset == .seconds(100))
    }

    @Test("minimumResolution is zero")
    func minimumResolution() {
        let clock = Time.Clock.Test()
        #expect(clock.minimumResolution == .zero)
    }

    @Test("advance by duration updates now")
    func advanceByDuration() async {
        let clock = Time.Clock.Test()
        await clock.advance(by: .seconds(5))
        #expect(clock.now.offset == .seconds(5))
    }

    @Test("advance to deadline updates now")
    func advanceToDeadline() async {
        let clock = Time.Clock.Test()
        let target = Time.Clock.Test.Instant(offset: .seconds(10))
        await clock.advance(to: target)
        #expect(clock.now == target)
    }

    @Test("sleep completes when clock advances past deadline")
    @MainActor
    func sleepCompletesOnAdvance() async throws {
        try await withSerialExecutor {
            let clock = Time.Clock.Test()
            let deadline = clock.now.advanced(by: .seconds(1))

            let task = Task {
                try await clock.sleep(until: deadline)
            }

            await clock.advance(by: .seconds(1))
            try await task.value

            #expect(clock.now.offset == .seconds(1))
        }
    }

    @Test("multiple sleeps complete in order")
    @MainActor
    func multipleSleepsCompleteInOrder() async throws {
        try await withSerialExecutor {
            let clock = Time.Clock.Test()

            let deadline1 = clock.now.advanced(by: .seconds(1))
            let deadline2 = clock.now.advanced(by: .seconds(2))

            let task1 = Task {
                try await clock.sleep(until: deadline1)
            }
            let task2 = Task {
                try await clock.sleep(until: deadline2)
            }

            await clock.advance(by: .seconds(3))
            try await task1.value
            try await task2.value

            #expect(clock.now.offset >= .seconds(2))
        }
    }

    @Test("run completes all pending sleeps")
    @MainActor
    func runCompletesAllSleeps() async throws {
        try await withSerialExecutor {
            let clock = Time.Clock.Test()
            let deadline = clock.now.advanced(by: .seconds(10))

            let task = Task {
                try await clock.sleep(until: deadline)
            }

            await clock.run()
            try await task.value

            #expect(clock.now.offset >= .seconds(10))
        }
    }

    @Test("checkSuspension succeeds when no active sleeps")
    func checkSuspensionSucceeds() async throws {
        let clock = Time.Clock.Test()
        try await clock.checkSuspension()
    }
}

// MARK: - Edge Cases

extension Time.Clock.Test.Test.EdgeCase {
    @Test("advance by zero does not change time")
    func advanceByZero() async {
        let clock = Time.Clock.Test()
        let before = clock.now
        await clock.advance(by: .zero)
        #expect(clock.now == before)
    }

    @Test("sleep with deadline in past completes immediately")
    func sleepWithPastDeadline() async throws {
        let clock = Time.Clock.Test(now: .init(offset: .seconds(10)))
        let pastDeadline = Time.Clock.Test.Instant(offset: .seconds(5))
        try await clock.sleep(until: pastDeadline)
        // Should complete without blocking
    }

    @Test("sleep with current time deadline completes immediately")
    func sleepWithCurrentDeadline() async throws {
        let clock = Time.Clock.Test()
        try await clock.sleep(until: clock.now)
        // Should complete without blocking
    }

    @Test("cancelled sleep throws CancellationError")
    func cancelledSleep() async {
        let clock = Time.Clock.Test()
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

    @Test("checkSuspension throws when sleeps are active")
    @MainActor
    func checkSuspensionThrowsWhenActive() async throws {
        try await withSerialExecutor {
            let clock = Time.Clock.Test()

            let task = Task {
                try await clock.sleep(until: clock.now.advanced(by: .seconds(100)))
            }

            // Let the task register its sleep
            await Task.yield()

            do {
                try await clock.checkSuspension()
                Issue.record("Expected Suspension.Error")
            } catch is Time.Clock.Test.Suspension.Error {
                // Expected
            } catch {
                Issue.record("Unexpected error: \(error)")
            }

            // Clean up
            await clock.run()
            try? await task.value
        }
    }

    @Test("instant advanced by negative duration goes backward")
    func instantAdvancedByNegative() {
        let instant = Time.Clock.Test.Instant(offset: .seconds(10))
        let earlier = instant.advanced(by: .seconds(-5))
        #expect(earlier.offset == .seconds(5))
    }

    @Test("instant duration to earlier instant is negative")
    func durationToEarlierInstant() {
        let later = Time.Clock.Test.Instant(offset: .seconds(10))
        let earlier = Time.Clock.Test.Instant(offset: .seconds(5))
        let duration = later.duration(to: earlier)
        #expect(duration == .seconds(-5))
    }

    @Test("instant comparison works correctly")
    func instantComparison() {
        let a = Time.Clock.Test.Instant(offset: .seconds(5))
        let b = Time.Clock.Test.Instant(offset: .seconds(10))
        #expect(a < b)
        #expect(!(b < a))
        #expect(!(a < a))
    }
}

// MARK: - Performance

extension Time.Clock.Test.Test.Performance {
    @Test("rapid advances", .timed(iterations: 100, warmup: 10))
    func rapidAdvances() async {
        let clock = Time.Clock.Test()
        for _ in 0..<100 {
            await clock.advance(by: .milliseconds(1))
        }
    }
}
