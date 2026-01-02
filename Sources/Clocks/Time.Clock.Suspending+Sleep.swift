// Time.Clock.Suspending+Sleep.swift
// Clocks
//
// Clock protocol conformance for suspending clock.

public import StandardTime

extension Time.Clock.Suspending: Clock {
    public var minimumResolution: Duration {
        .nanoseconds(1)
    }

    public func sleep(until deadline: Instant, tolerance: Duration? = nil) async throws {
        let remaining = now.duration(to: deadline)

        if remaining <= .zero { return }

        try await Task.sleep(for: remaining, tolerance: tolerance ?? .zero)
    }
}
