// Time.Clock.Suspending.swift
// Clocks
//
// Clock that pauses during system sleep.

public import StandardTime

extension Time.Clock {
    /// A clock that measures elapsed time, pausing while the system is asleep.
    ///
    /// Equivalent to Swift stdlib's `SuspendingClock` semantics:
    /// - **Darwin**: Uses `CLOCK_UPTIME_RAW`
    /// - **Linux**: Uses `CLOCK_MONOTONIC`
    /// - **Windows**: Uses `QueryUnbiasedInterruptTime`
    ///
    /// Use this clock for measuring active execution time where system sleep
    /// should not count toward elapsed time.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let clock = Time.Clock.Suspending()
    /// let start = clock.now
    /// // ... perform work ...
    /// let elapsed: Duration = clock.now - start
    /// ```
    public struct Suspending: Sendable {
        /// Creates a suspending clock instance.
        public init() {}
    }
}
