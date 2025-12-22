// Time.Clock.Continuous+Instant.swift
// Clocks
//
// Instant typealias for the continuous clock.

public import StandardTime

extension Time.Clock.Continuous {
    /// A point in time relative to the continuous clock's epoch.
    ///
    /// Instants from this clock include time elapsed while the system was asleep.
    /// The raw value is nanoseconds since the clock's epoch as `Int64`.
    ///
    /// Compare instants only from the same clock type - comparing
    /// `Continuous.Instant` with `Suspending.Instant` is a compile-time error.
    public typealias Instant = Time.Clock.Instant<Time.Clock.Continuous>
}
