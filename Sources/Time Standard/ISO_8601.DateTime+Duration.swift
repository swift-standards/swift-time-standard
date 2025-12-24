// ISO_8601.DateTime+Duration.swift
// Time Standard
//
// DateTime arithmetic with ISO 8601 Duration

public import ISO_8601
@_spi(Internal) import StandardTime

extension ISO_8601.DateTime {
    /// Add a duration to this date-time.
    ///
    /// Calendar components (years, months) are added first, then time components.
    /// This follows ISO 8601 semantics where:
    /// - Adding 1 month to Jan 31 gives Feb 28/29 (end of February)
    /// - Adding time components uses standard second-based arithmetic
    ///
    /// ## Example
    ///
    /// ```swift
    /// let date = try ISO_8601.DateTime(year: 2024, month: 1, day: 15, hour: 10)
    /// let duration = try ISO_8601.Duration(days: 5, hours: 3)
    /// let result = date.adding(duration)
    /// // 2024-01-20T13:00:00Z
    /// ```
    ///
    /// - Parameter duration: The duration to add
    /// - Returns: A new DateTime with the duration added
    public func adding(_ duration: ISO_8601.Duration) -> ISO_8601.DateTime {
        var year = time.year.rawValue + duration.years
        var month = time.month.rawValue + duration.months

        // Normalize months (handle overflow)
        while month > 12 {
            month -= 12
            year += 1
        }
        while month < 1 {
            month += 12
            year -= 1
        }

        // Clamp day to valid range for the new month
        let maxDay = Time.Month(unchecked: month).days(in: Time.Year(year))
        let day = min(time.day.rawValue, maxDay)

        // Calculate time components addition using seconds
        let additionalSeconds =
            duration.days * 86400
            + duration.hours * 3600
            + duration.minutes * 60
            + duration.seconds

        // Create base time with adjusted year/month/day
        let adjustedTime = Time(
            __unchecked: (),
            year: year,
            month: month,
            day: day,
            hour: time.hour.value,
            minute: time.minute.value,
            second: time.second.value,
            millisecond: time.millisecond.value,
            microsecond: time.microsecond.value,
            nanosecond: time.nanosecond.value
        )

        // Add the time components
        let newSeconds = adjustedTime.secondsSinceEpoch + additionalSeconds
        var newNanoseconds = time.totalNanoseconds + duration.nanoseconds

        // Normalize nanoseconds
        var secondsAdjustment = 0
        while newNanoseconds >= 1_000_000_000 {
            newNanoseconds -= 1_000_000_000
            secondsAdjustment += 1
        }
        while newNanoseconds < 0 {
            newNanoseconds += 1_000_000_000
            secondsAdjustment -= 1
        }

        let finalTime = Time(
            __unchecked: (),
            secondsSinceEpoch: newSeconds + secondsAdjustment,
            nanoseconds: newNanoseconds
        )

        return ISO_8601.DateTime(time: finalTime, timezoneOffset: timezoneOffset)
    }

    /// Subtract a duration from this date-time.
    ///
    /// - Parameter duration: The duration to subtract
    /// - Returns: A new DateTime with the duration subtracted
    public func subtracting(_ duration: ISO_8601.Duration) -> ISO_8601.DateTime {
        // Create negated duration (negating valid components cannot fail)
        let negated: ISO_8601.Duration
        do {
            negated = try ISO_8601.Duration(
                years: -duration.years,
                months: -duration.months,
                days: -duration.days,
                hours: -duration.hours,
                minutes: -duration.minutes,
                seconds: -duration.seconds,
                nanoseconds: 0  // Nanoseconds stay positive, handled separately
            )
        } catch {
            preconditionFailure("Negating valid duration components should never fail: \(error)")
        }

        var result = adding(negated)

        // Handle nanosecond subtraction separately
        if duration.nanoseconds > 0 {
            let newNanos = result.time.totalNanoseconds - duration.nanoseconds
            if newNanos < 0 {
                // Borrow from seconds
                let adjustedSeconds = result.time.secondsSinceEpoch - 1
                let adjustedNanos = newNanos + 1_000_000_000
                let adjustedTime = Time(
                    __unchecked: (),
                    secondsSinceEpoch: adjustedSeconds,
                    nanoseconds: adjustedNanos
                )
                result = ISO_8601.DateTime(time: adjustedTime, timezoneOffset: timezoneOffset)
            } else {
                let adjustedTime = Time(
                    __unchecked: (),
                    secondsSinceEpoch: result.time.secondsSinceEpoch,
                    nanoseconds: newNanos
                )
                result = ISO_8601.DateTime(time: adjustedTime, timezoneOffset: timezoneOffset)
            }
        }

        return result
    }
}

// MARK: - Operators

extension ISO_8601.DateTime {
    /// Add a duration to a date-time.
    public static func + (lhs: ISO_8601.DateTime, rhs: ISO_8601.Duration) -> ISO_8601.DateTime {
        lhs.adding(rhs)
    }

    /// Subtract a duration from a date-time.
    public static func - (lhs: ISO_8601.DateTime, rhs: ISO_8601.Duration) -> ISO_8601.DateTime {
        lhs.subtracting(rhs)
    }
}

// MARK: - Month Extension

extension Time.Month {
    /// Creates a month without validation (internal use only).
    internal init(unchecked value: Int) {
        // Use RawRepresentable init which is failable
        self = Time.Month(rawValue: value)!
    }
}
