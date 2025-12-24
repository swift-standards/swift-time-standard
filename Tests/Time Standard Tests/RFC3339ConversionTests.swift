// RFC3339ConversionTests.swift
// Time Standard Tests
//
// Tests for RFC 3339 cross-standard conversions

import ISO_8601
import RFC_3339
import RFC_5322
import StandardTime
import Testing

@testable import Time_Standard

@Suite
struct RFC3339ConversionTests {

    // MARK: - RFC 3339 ↔ ISO 8601 Conversions

    @Test
    func convertRFC3339ToISO8601() throws {
        let time = try Time(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 45,
            millisecond: 123,
            microsecond: 456,
            nanosecond: 789
        )
        let rfc3339 = RFC_3339.DateTime(time: time, offset: .utc)

        let iso8601 = ISO_8601.DateTime(rfc3339)

        #expect(iso8601.time == time)
        #expect(iso8601.timezoneOffsetSeconds == 0)
    }

    @Test
    func convertRFC3339WithTimezoneToISO8601() throws {
        let time = try Time(year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 0)
        let offset = try RFC_3339.Offset(seconds: 19800)  // +05:30
        let rfc3339 = RFC_3339.DateTime(time: time, offset: offset)

        let iso8601 = ISO_8601.DateTime(rfc3339)

        #expect(iso8601.timezoneOffsetSeconds == 19800)
    }

    @Test
    func convertISO8601ToRFC3339() throws {
        let iso8601 = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 45,
            nanoseconds: 123_456_789,
            timezoneOffsetSeconds: 0
        )

        let rfc3339 = RFC_3339.DateTime(iso8601)

        #expect(rfc3339.time == iso8601.time)
        #expect(rfc3339.offset == .utc)
    }

    @Test
    func convertISO8601WithTimezoneToRFC3339() throws {
        let iso8601 = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 0,
            nanoseconds: 0,
            timezoneOffsetSeconds: -18000  // -05:00
        )

        let rfc3339 = RFC_3339.DateTime(iso8601)

        #expect(rfc3339.offset.seconds == -18000)
    }

    @Test
    func roundTripRFC3339ToISO8601() throws {
        let time = try Time(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 45,
            millisecond: 500,
            microsecond: 0,
            nanosecond: 0
        )
        let offset = try RFC_3339.Offset(seconds: 3600)
        let original = RFC_3339.DateTime(time: time, offset: offset)

        let iso8601 = ISO_8601.DateTime(original)
        let restored = RFC_3339.DateTime(iso8601)

        #expect(restored.time == original.time)
        #expect(restored.offset.seconds == original.offset.seconds)
    }

    // MARK: - RFC 3339 ↔ RFC 5322 Conversions

    @Test
    func convertRFC3339ToRFC5322() throws {
        let time = try Time(year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 45)
        let rfc3339 = RFC_3339.DateTime(time: time, offset: .utc)

        let rfc5322 = RFC_5322.DateTime(rfc3339)

        #expect(rfc5322.secondsSinceEpoch == time.secondsSinceEpoch)
        #expect(rfc5322.timezoneOffsetSeconds == 0)
    }

    @Test
    func convertRFC3339ToRFC5322LosesSubSecondPrecision() throws {
        let time = try Time(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 45,
            millisecond: 999,
            microsecond: 999,
            nanosecond: 999
        )
        let rfc3339 = RFC_3339.DateTime(time: time, offset: .utc)

        let rfc5322 = RFC_5322.DateTime(rfc3339)

        // RFC 5322 only has second precision, sub-seconds are truncated
        #expect(rfc5322.secondsSinceEpoch == time.secondsSinceEpoch)
    }

    @Test
    func convertRFC5322ToRFC3339() throws {
        let rfc5322 = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: 0
        )

        let rfc3339 = RFC_3339.DateTime(rfc5322)

        #expect(rfc3339.time.secondsSinceEpoch == 1_705_324_245)
        #expect(rfc3339.offset == .utc)
        #expect(rfc3339.time.totalNanoseconds == 0)  // RFC 5322 has no sub-seconds
    }

    @Test
    func convertRFC5322WithTimezoneToRFC3339() throws {
        let rfc5322 = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: -18000  // -05:00
        )

        let rfc3339 = RFC_3339.DateTime(rfc5322)

        #expect(rfc3339.offset.seconds == -18000)
    }

    @Test
    func roundTripRFC5322ToRFC3339() throws {
        let original = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: 3600
        )

        let rfc3339 = RFC_3339.DateTime(original)
        let restored = RFC_5322.DateTime(rfc3339)

        #expect(restored.secondsSinceEpoch == original.secondsSinceEpoch)
        #expect(restored.timezoneOffsetSeconds == original.timezoneOffsetSeconds)
    }

    // MARK: - Three-Way Conversions

    @Test
    func threeWayConversionPreservesInstant() throws {
        let time = try Time(year: 2024, month: 6, day: 15, hour: 14, minute: 30, second: 0)
        let rfc3339 = RFC_3339.DateTime(time: time, offset: .utc)

        // RFC 3339 → ISO 8601 → RFC 5322
        let iso8601 = ISO_8601.DateTime(rfc3339)
        let rfc5322 = RFC_5322.DateTime(iso8601)

        // All should represent the same instant
        #expect(rfc5322.secondsSinceEpoch == time.secondsSinceEpoch)
    }

    @Test
    func unknownLocalOffsetHandling() throws {
        let time = try Time(year: 2024, month: 1, day: 15, hour: 12, minute: 0, second: 0)
        let rfc3339 = RFC_3339.DateTime(time: time, offset: .unknownLocalOffset)

        // Unknown offset is still 0 seconds from UTC
        let iso8601 = ISO_8601.DateTime(rfc3339)
        #expect(iso8601.timezoneOffsetSeconds == 0)

        let rfc5322 = RFC_5322.DateTime(rfc3339)
        #expect(rfc5322.timezoneOffsetSeconds == 0)
    }
}
