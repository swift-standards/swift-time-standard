public import ISO_8601
import Time

extension ISO_8601.DateTime {

    public func adding(_ duration: ISO_8601.Duration) throws(ISO_8601.DateTime.Error) -> ISO_8601.DateTime {
        try shifted(
            months: Int128(duration.years) * 12 + Int128(duration.months),
            seconds: Int128(duration.days) * 86_400
                + Int128(duration.hours) * 3_600
                + Int128(duration.minutes) * 60
                + Int128(duration.seconds),
            nanoseconds: Int128(duration.nanoseconds)
        )
    }

    public func subtracting(_ duration: ISO_8601.Duration) throws(ISO_8601.DateTime.Error) -> ISO_8601.DateTime {
        try shifted(
            months: -(Int128(duration.years) * 12 + Int128(duration.months)),
            seconds: -(Int128(duration.days) * 86_400
                + Int128(duration.hours) * 3_600
                + Int128(duration.minutes) * 60
                + Int128(duration.seconds)),
            nanoseconds: -Int128(duration.nanoseconds)
        )
    }

    private func shifted(
        months: Int128,
        seconds: Int128,
        nanoseconds: Int128
    ) throws(ISO_8601.DateTime.Error) -> ISO_8601.DateTime {
        let monthIndex = Int128(date.year) * 12 + Int128(date.month - 1) + months
        let shiftedYear = monthIndex >= 0 ? monthIndex / 12 : (monthIndex - 11) / 12
        guard let year = Int(exactly: shiftedYear) else {
            throw .date(.yearOutOfRange(Int(clamping: shiftedYear)))
        }
        let month = Int(monthIndex - shiftedYear * 12) + 1
        let day = min(date.day, ISO_8601.CalendarDate.numberOfDays(inMonth: month, year: year))

        let anchor = try ISO_8601.DateTime(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanoseconds: self.nanoseconds,
            offset: offset
        )

        let perSecond: Int128 = 1_000_000_000
        let total =
            Int128(anchor.instant.secondsSinceUnixEpoch) * perSecond
            + Int128(anchor.instant.nanosecondFraction)
            + seconds * perSecond
            + nanoseconds
        let fraction = (total % perSecond + perSecond) % perSecond
        let wholeSeconds = (total - fraction) / perSecond
        guard let secondsSinceUnixEpoch = Int64(exactly: wholeSeconds) else {
            throw .date(.daysSinceUnixEpochOutOfRange(Int(clamping: wholeSeconds / 86_400)))
        }
        let instant = Time::Time.Instant(
            _unchecked: (),
            secondsSinceUnixEpoch: secondsSinceUnixEpoch,
            nanosecondFraction: Int32(fraction)
        )

        return try ISO_8601.DateTime(instant, offset: offset)
    }
}

extension ISO_8601.DateTime {

    public static func + (
        lhs: ISO_8601.DateTime,
        rhs: ISO_8601.Duration
    ) throws(ISO_8601.DateTime.Error) -> ISO_8601.DateTime {
        try lhs.adding(rhs)
    }

    public static func - (
        lhs: ISO_8601.DateTime,
        rhs: ISO_8601.Duration
    ) throws(ISO_8601.DateTime.Error) -> ISO_8601.DateTime {
        try lhs.subtracting(rhs)
    }
}
