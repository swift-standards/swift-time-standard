public import ISO_8601

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension ISO_8601.Duration {

    public var swiftDuration: Swift.Duration? {

        guard years == 0, months == 0 else {
            return nil
        }

        let totalSeconds = days * 86400 + hours * 3600 + minutes * 60 + seconds
        return .seconds(totalSeconds) + .nanoseconds(nanoseconds)
    }

    public init(_ duration: Swift.Duration) throws(ISO_8601.Date.Error) {
        let (seconds, attoseconds) = duration.components
        let nanoseconds = Int(attoseconds / 1_000_000_000)

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
