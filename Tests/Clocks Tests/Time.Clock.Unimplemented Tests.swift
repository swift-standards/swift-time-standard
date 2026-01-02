// Time.Clock.Unimplemented Tests.swift
// Clocks Tests

import StandardsTestSupport
import Testing

@testable import Clocks

extension Time.Clock.Unimplemented {
    #TestSuites
}

// MARK: - Unit Tests

extension Time.Clock.Unimplemented.Test.Unit {
    @Test("now returns zero offset instant")
    func nowReturnsZero() {
        let clock = Time.Clock.Unimplemented()
        #expect(clock.now.offset == .zero)
    }

    @Test("now always returns same value")
    func nowAlwaysSame() {
        let clock = Time.Clock.Unimplemented()
        let now1 = clock.now
        let now2 = clock.now
        #expect(now1 == now2)
    }

    @Test("minimumResolution is zero")
    func minimumResolution() {
        let clock = Time.Clock.Unimplemented()
        #expect(clock.minimumResolution == .zero)
    }

    @Test("is Sendable")
    func isSendable() {
        let clock = Time.Clock.Unimplemented()
        let _: Sendable = clock
    }

    @Test("conforms to Clock protocol")
    func conformsToClock() {
        let clock: any Clock = Time.Clock.Unimplemented()
        _ = clock.now
        _ = clock.minimumResolution
    }

    @Test("instant can be created with offset")
    func instantWithOffset() {
        let instant = Time.Clock.Unimplemented.Instant(offset: .seconds(100))
        #expect(instant.offset == .seconds(100))
    }

    @Test("instant advanced correctly")
    func instantAdvanced() {
        let instant = Time.Clock.Unimplemented.Instant(offset: .seconds(10))
        let advanced = instant.advanced(by: .seconds(5))
        #expect(advanced.offset == .seconds(15))
    }

    @Test("instant duration to other")
    func instantDuration() {
        let earlier = Time.Clock.Unimplemented.Instant(offset: .seconds(10))
        let later = Time.Clock.Unimplemented.Instant(offset: .seconds(25))
        let duration = earlier.duration(to: later)
        #expect(duration == .seconds(15))
    }

    @Test("instant comparison")
    func instantComparison() {
        let a = Time.Clock.Unimplemented.Instant(offset: .seconds(5))
        let b = Time.Clock.Unimplemented.Instant(offset: .seconds(10))
        #expect(a < b)
        #expect(!(b < a))
        #expect(!(a < a))
    }

    @Test("instant equality")
    func instantEquality() {
        let a = Time.Clock.Unimplemented.Instant(offset: .seconds(5))
        let b = Time.Clock.Unimplemented.Instant(offset: .seconds(5))
        #expect(a == b)
    }
}

// MARK: - Edge Cases

extension Time.Clock.Unimplemented.Test.EdgeCase {
    @Test("instant advanced by zero")
    func instantAdvancedByZero() {
        let instant = Time.Clock.Unimplemented.Instant(offset: .seconds(10))
        let same = instant.advanced(by: .zero)
        #expect(same == instant)
    }

    @Test("instant advanced by negative")
    func instantAdvancedByNegative() {
        let instant = Time.Clock.Unimplemented.Instant(offset: .seconds(10))
        let earlier = instant.advanced(by: .seconds(-5))
        #expect(earlier.offset == .seconds(5))
    }

    @Test("default instant offset is zero")
    func defaultInstantOffset() {
        let instant = Time.Clock.Unimplemented.Instant()
        #expect(instant.offset == .zero)
    }

    // Note: We cannot test that sleep() triggers preconditionFailure
    // in Swift Testing framework as it would crash the test process.
    // The sleep() method is tested indirectly by verifying it exists
    // and has the correct signature through the Clock conformance.
}

// MARK: - Performance

extension Time.Clock.Unimplemented.Test.Performance {
    @Test("now access is fast", .timed(iterations: 10000, warmup: 1000))
    func nowAccessSpeed() {
        let clock = Time.Clock.Unimplemented()
        for _ in 0..<10000 {
            _ = clock.now
        }
    }

    @Test("instant creation", .timed(iterations: 10000, warmup: 1000))
    func instantCreation() {
        for i in 0..<10000 {
            _ = Time.Clock.Unimplemented.Instant(offset: .nanoseconds(i))
        }
    }
}
