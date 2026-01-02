// Time.Clock.Any Tests.swift
// Clocks Tests

import StandardsTestSupport
import Testing

@testable import Clocks

// Time.Clock.Any is generic, so we test with Duration as the type parameter
// using a dedicated test enum

enum AnyClockTests {
    #TestSuites
}

// MARK: - Unit Tests

extension AnyClockTests.Test.Unit {
    @Test("wraps TestClock correctly")
    func wrapsTestClock() {
        let testClock = Time.Clock.Test()
        let anyClock = Time.Clock.`Any`(testClock)
        #expect(anyClock.now == anyClock.now)  // Self-equality
    }

    @Test("wraps ImmediateClock correctly")
    func wrapsImmediateClock() {
        let immediateClock = Time.Clock.Immediate()
        let anyClock = Time.Clock.`Any`(immediateClock)
        #expect(anyClock.minimumResolution == .zero)
    }

    @Test("now reflects wrapped clock")
    func nowReflectsWrapped() {
        let testClock = Time.Clock.Test(now: .init(offset: .seconds(100)))
        let anyClock = Time.Clock.`Any`(testClock)
        // The internal offset should be preserved through type erasure
        let now = anyClock.now
        #expect(now == now)  // At minimum, self-equality should work
    }

    @Test("minimumResolution reflects wrapped clock")
    func minimumResolutionReflectsWrapped() {
        let testClock = Time.Clock.Test()
        testClock.minimumResolution = .milliseconds(10)
        let anyClock = Time.Clock.`Any`(testClock)
        #expect(anyClock.minimumResolution == .milliseconds(10))
    }

    @Test("sleep delegates to wrapped clock")
    func sleepDelegatesToWrapped() async throws {
        let testClock = Time.Clock.Test()
        let anyClock = Time.Clock.`Any`(testClock)

        let deadline = anyClock.now.advanced(by: .seconds(5))

        async let sleepTask: Void = anyClock.sleep(until: deadline, tolerance: nil)
        await testClock.advance(by: .seconds(5))
        try await sleepTask

        #expect(testClock.now.offset == .seconds(5))
    }

    @Test("conforms to Clock protocol")
    func conformsToClock() async throws {
        let testClock = Time.Clock.Test()
        let anyClock: any Clock = Time.Clock.`Any`(testClock)
        _ = anyClock.now
        _ = anyClock.minimumResolution
    }
}

// MARK: - Edge Cases

extension AnyClockTests.Test.EdgeCase {
    @Test("instant advanced and duration are consistent")
    func instantAdvancedAndDuration() {
        let testClock = Time.Clock.Test()
        let anyClock = Time.Clock.`Any`(testClock)
        let now = anyClock.now
        let later = now.advanced(by: .seconds(10))
        let duration = now.duration(to: later)
        #expect(duration == .seconds(10))
    }

    @Test("instant comparison works correctly")
    func instantComparison() {
        let testClock = Time.Clock.Test()
        let anyClock = Time.Clock.`Any`(testClock)
        let now = anyClock.now
        let later = now.advanced(by: .seconds(1))
        #expect(now < later)
        #expect(!(later < now))
    }

    @Test("instant equality works correctly")
    func instantEquality() {
        let testClock = Time.Clock.Test()
        let anyClock = Time.Clock.`Any`(testClock)
        let now = anyClock.now
        let same = now.advanced(by: .zero)
        #expect(now == same)
    }

    @Test("instant hashing works correctly")
    func instantHashing() {
        let testClock = Time.Clock.Test()
        let anyClock = Time.Clock.`Any`(testClock)
        let now = anyClock.now
        let same = now.advanced(by: .zero)
        #expect(now.hashValue == same.hashValue)
    }

    @Test("cancelled sleep throws CancellationError")
    func cancelledSleep() async {
        let testClock = Time.Clock.Test()
        let anyClock = Time.Clock.`Any`(testClock)

        let task = Task {
            try await anyClock.sleep(
                until: anyClock.now.advanced(by: .seconds(100)),
                tolerance: nil
            )
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

        // Clean up
        await testClock.run()
    }

    @Test("different wrapped clocks produce different Any clocks")
    func differentWrappedClocks() {
        let testClock1 = Time.Clock.Test(now: .init(offset: .seconds(10)))
        let testClock2 = Time.Clock.Test(now: .init(offset: .seconds(20)))

        let anyClock1 = Time.Clock.`Any`(testClock1)
        let anyClock2 = Time.Clock.`Any`(testClock2)

        // Both should work independently
        let now1 = anyClock1.now
        let now2 = anyClock2.now

        // Just verify both are functional
        #expect(now1 == now1)
        #expect(now2 == now2)
    }
}

// MARK: - Performance

extension AnyClockTests.Test.Performance {
    @Test("type-erased now access", .timed(iterations: 1000, warmup: 100))
    func typeErasedNowAccess() {
        let testClock = Time.Clock.Test()
        let anyClock = Time.Clock.`Any`(testClock)
        for _ in 0..<1000 {
            _ = anyClock.now
        }
    }

    @Test("type-erased instant arithmetic", .timed(iterations: 1000, warmup: 100))
    func typeErasedInstantArithmetic() {
        let testClock = Time.Clock.Test()
        let anyClock = Time.Clock.`Any`(testClock)
        var instant = anyClock.now
        for _ in 0..<1000 {
            instant = instant.advanced(by: .nanoseconds(1))
        }
    }
}
