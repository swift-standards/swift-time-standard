// Clock+Timer.swift
// Clocks
//
// Timer extension for Clock protocol.

public import StandardTime

extension Clock {
    /// Creates an asynchronous sequence that emits the current instant on an interval.
    ///
    /// - Parameters:
    ///   - interval: The duration between emissions.
    ///   - tolerance: The allowed timing variance. Defaults to `nil`.
    /// - Returns: An async sequence that emits the current instant at each interval.
    ///
    /// ## Example
    ///
    /// ```swift
    /// for await instant in clock.timer(interval: .seconds(1)) {
    ///     print("Tick at \(instant)")
    /// }
    /// ```
    public func timer(
        interval: Duration,
        tolerance: Duration? = nil
    ) -> Time.Clock.Timer<Self>.Sequence {
        Time.Clock.Timer.Sequence(interval: interval, tolerance: tolerance, clock: self)
    }
}
