// Time.Clock.Continuous.swift
// Clocks
//
// Clock that advances even during system sleep.

public import StandardTime

extension Time.Clock {
    /// A clock that measures elapsed time, continuing to advance while the system is asleep.
    ///
    /// Equivalent to Swift stdlib's `ContinuousClock` semantics:
    /// - **Darwin**: Uses `CLOCK_MONOTONIC`
    /// - **Linux**: Uses `CLOCK_BOOTTIME`
    /// - **Windows**: Uses `QueryPerformanceCounter`
    ///
    /// Use this clock when you need to measure total wall-clock time elapsed,
    /// including periods when the system was asleep.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let clock = Time.Clock.Continuous()
    /// let start = clock.now
    /// // ... perform work (system may sleep) ...
    /// let elapsed: Duration = clock.now - start
    /// ```
    public struct Continuous: Sendable {
        /// Creates a continuous clock instance.
        public init() {}
    }
}
