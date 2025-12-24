// ISO_8601.Duration+Swift.swift
// Time Standard
//
// Conversion from ISO 8601 Duration to Swift.Duration

public import ISO_8601

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension ISO_8601.Duration {
    /// Convert to Swift.Duration.
    ///
    /// Returns `nil` if the duration contains years or months, since these
    /// have variable lengths and cannot be represented as a fixed time span.
    ///
    /// Assumes 86400 seconds per day (ignores DST transitions).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let duration = try ISO_8601.Duration(days: 1, hours: 2, minutes: 30)
    /// if let swiftDuration = duration.swiftDuration {
    ///     // 1 day + 2 hours + 30 minutes = 95400 seconds
    /// }
    ///
    /// let ambiguous = try ISO_8601.Duration(months: 1)
    /// ambiguous.swiftDuration  // nil (month length varies)
    /// ```
    public var swiftDuration: Swift.Duration? {
        // Years and months have variable lengths
        guard years == 0, months == 0 else {
            return nil
        }

        let totalSeconds = days * 86400 + hours * 3600 + minutes * 60 + seconds
        return .seconds(totalSeconds) + .nanoseconds(nanoseconds)
    }

    /// Create an ISO 8601 Duration from a Swift Duration.
    ///
    /// The resulting duration will only have time components (hours, minutes, seconds, nanoseconds).
    /// Days, months, and years will be zero.
    ///
    /// - Parameter duration: The Swift Duration to convert
    public init(_ duration: Swift.Duration) throws {
        let (seconds, attoseconds) = duration.components
        let nanoseconds = Int(attoseconds / 1_000_000_000)

        // Break down seconds into hours, minutes, seconds
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let remainingAfterHours = totalSeconds % 3600
        let minutes = remainingAfterHours / 60
        let secs = remainingAfterHours % 60

        try self.init(
            years: 0,
            months: 0,
            days: 0,
            hours: hours,
            minutes: minutes,
            seconds: secs,
            nanoseconds: nanoseconds
        )
    }
}
