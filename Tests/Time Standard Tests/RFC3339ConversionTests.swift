import ISO_8601
import RFC_3339
import RFC_5322
import Testing
import Time_Primitives

@testable import Time_Standard

@Suite
struct `RFC 3339 Conversion Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `convert RFC3339 To ISO8601`() throws {
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
        #expect(iso8601.timezone.offsetSeconds == 0)
    }

    @Test
    func `convert RFC3339 With Timezone To ISO8601`() throws {
        let time = try Time(year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 0)
        let offset = try RFC_3339.Offset(seconds: 19800)
        let rfc3339 = RFC_3339.DateTime(time: time, offset: offset)

        let iso8601 = ISO_8601.DateTime(rfc3339)

        #expect(iso8601.timezone.offsetSeconds == 19800)
    }

    @Test
    func `convert ISO8601 To RFC3339`() throws {
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
    func `convert ISO8601 With Timezone To RFC3339`() throws {
        let iso8601 = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 0,
            nanoseconds: 0,
            timezoneOffsetSeconds: -18000
        )

        let rfc3339 = RFC_3339.DateTime(iso8601)

        #expect(rfc3339.offset.seconds == -18000)
    }

    @Test
    func `round Trip RFC3339 To ISO8601`() throws {
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

    @Test
    func `convert RFC3339 To RFC5322`() throws {
        let time = try Time(year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 45)
        let rfc3339 = RFC_3339.DateTime(time: time, offset: .utc)

        let rfc5322 = RFC_5322.DateTime(rfc3339)

        #expect(rfc5322.secondsSinceEpoch == time.secondsSinceEpoch)
        #expect(rfc5322.timezoneOffsetSeconds == 0)
    }

    @Test
    func `convert RFC3339 To RFC5322 Loses Sub Second Precision`() throws {
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

        #expect(rfc5322.secondsSinceEpoch == time.secondsSinceEpoch)
    }

    @Test
    func `convert RFC5322 To RFC3339`() throws {
        let rfc5322 = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: 0
        )

        let rfc3339 = RFC_3339.DateTime(rfc5322)

        #expect(rfc3339.time.secondsSinceEpoch == 1_705_324_245)
        #expect(rfc3339.offset == .utc)
        #expect(rfc3339.time.totalNanoseconds == 0)
    }

    @Test
    func `convert RFC5322 With Timezone To RFC3339`() throws {
        let rfc5322 = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: -18000
        )

        let rfc3339 = RFC_3339.DateTime(rfc5322)

        #expect(rfc3339.offset.seconds == -18000)
    }

    @Test
    func `round Trip RFC5322 To RFC3339`() throws {
        let original = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: 3600
        )

        let rfc3339 = RFC_3339.DateTime(original)
        let restored = RFC_5322.DateTime(rfc3339)

        #expect(restored.secondsSinceEpoch == original.secondsSinceEpoch)
        #expect(restored.timezoneOffsetSeconds == original.timezoneOffsetSeconds)
    }

    @Test
    func `three Way Conversion Preserves Instant`() throws {
        let time = try Time(year: 2024, month: 6, day: 15, hour: 14, minute: 30, second: 0)
        let rfc3339 = RFC_3339.DateTime(time: time, offset: .utc)

        let iso8601 = ISO_8601.DateTime(rfc3339)
        let rfc5322 = RFC_5322.DateTime(iso8601)

        #expect(rfc5322.secondsSinceEpoch == time.secondsSinceEpoch)
    }

    @Test
    func `unknown Local Offset Handling`() throws {
        let time = try Time(year: 2024, month: 1, day: 15, hour: 12, minute: 0, second: 0)
        let rfc3339 = RFC_3339.DateTime(time: time, offset: .unknownLocalOffset)

        let iso8601 = ISO_8601.DateTime(rfc3339)
        #expect(iso8601.timezone.offsetSeconds == 0)

        let rfc5322 = RFC_5322.DateTime(rfc3339)
        #expect(rfc5322.timezoneOffsetSeconds == 0)
    }
}
