// Time.Clock.Suspending+Instant.swift
// Clocks
//
// Instant typealias for the suspending clock.

public import StandardTime

extension Time.Clock.Suspending {
    /// A point in time relative to the suspending clock's epoch.
    ///
    /// Instants from this clock exclude time elapsed while the system was asleep.
    /// The raw value is nanoseconds since the clock's epoch as `Int64`.
    ///
    /// Compare instants only from the same clock type - comparing
    /// `Suspending.Instant` with `Continuous.Instant` is a compile-time error.
    public typealias Instant = Time.Clock.Instant<Time.Clock.Suspending>
}
