public import ISO_8601
@_spi(Internal) import Time

extension ISO_8601.DateTime {

    public func adding(_ duration: ISO_8601.Duration) -> ISO_8601.DateTime {

        var year = time.year.rawValue + duration.years

        var month = time.month.rawValue + duration.months

        while month > 12 {
            month -= 12
            year += 1
        }
        while month < 1 {
            month += 12
            year -= 1
        }

        let maxDay = Time.Month(unchecked: month).days(in: Time.Year(year))

        let day = min(time.day.rawValue, maxDay)

        let additionalSeconds =
            duration.days * 86400
            + duration.hours * 3600
            + duration.minutes * 60
            + duration.seconds

        let adjustedTime = Time(
            _unchecked: (),
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

        let newSeconds = adjustedTime.secondsSinceEpoch + additionalSeconds
        var newNanoseconds = time.totalNanoseconds + duration.nanoseconds

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
            _unchecked: (),
            secondsSinceEpoch: newSeconds + secondsAdjustment,
            nanoseconds: newNanoseconds
        )

        return ISO_8601.DateTime(time: finalTime, timezoneOffset: timezoneOffset)
    }

    public func subtracting(_ duration: ISO_8601.Duration) -> ISO_8601.DateTime {

        let negated: ISO_8601.Duration
        do throws(ISO_8601.Date.Error) {
            negated = try ISO_8601.Duration(
                years: -duration.years,
                months: -duration.months,
                days: -duration.days,
                hours: -duration.hours,
                minutes: -duration.minutes,
                seconds: -duration.seconds,
                nanoseconds: 0
            )
        } catch {
            preconditionFailure("Negating valid duration components should never fail: \(error)")
        }

        var result = adding(negated)

        if duration.nanoseconds > 0 {
            let newNanos = result.time.totalNanoseconds - duration.nanoseconds
            if newNanos < 0 {

                let adjustedSeconds = result.time.secondsSinceEpoch - 1
                let adjustedNanos = newNanos + 1_000_000_000
                let adjustedTime = Time(
                    _unchecked: (),
                    secondsSinceEpoch: adjustedSeconds,
                    nanoseconds: adjustedNanos
                )
                result = ISO_8601.DateTime(time: adjustedTime, timezoneOffset: timezoneOffset)
            } else {
                let adjustedTime = Time(
                    _unchecked: (),
                    secondsSinceEpoch: result.time.secondsSinceEpoch,
                    nanoseconds: newNanos
                )
                result = ISO_8601.DateTime(time: adjustedTime, timezoneOffset: timezoneOffset)
            }
        }

        return result
    }
}

extension ISO_8601.DateTime {

    public static func + (lhs: ISO_8601.DateTime, rhs: ISO_8601.Duration) -> ISO_8601.DateTime {
        lhs.adding(rhs)
    }

    public static func - (lhs: ISO_8601.DateTime, rhs: ISO_8601.Duration) -> ISO_8601.DateTime {
        lhs.subtracting(rhs)
    }
}

extension Time.Month {

    internal init(unchecked value: Int) {

        self = Time.Month(rawValue: value)!
    }
}
