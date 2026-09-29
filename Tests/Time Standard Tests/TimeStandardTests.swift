import ISO_8601
import RFC_5322
import Testing
import Time

@testable import Time_Standard

@Suite
struct `Time Standard Cross-Format Conversion Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `convert RFC5322 To ISO8601`() throws {
        let rfc = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: 0
        )

        let iso = try ISO_8601.DateTime(rfc)

        #expect(iso.instant.secondsSinceUnixEpoch == 1_705_324_245)
        #expect(iso.nanoseconds == 0)
        #expect(iso.offset.seconds == 0)
    }

    @Test
    func `convert RFC5322 With Timezone To ISO8601`() throws {
        let rfc = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: 3600
        )

        let iso = try ISO_8601.DateTime(rfc)

        #expect(iso.instant.secondsSinceUnixEpoch == 1_705_324_245)
        #expect(iso.offset.seconds == 3600)
    }

    @Test
    func `convert ISO8601 To RFC5322`() throws {
        let iso = try ISO_8601.DateTime(
            Time.Instant(secondsSinceUnixEpoch: 1_705_324_245, nanosecondFraction: 123_456_789),
            offset: ISO_8601.Timezone.Offset(seconds: 0)
        )

        let rfc = RFC_5322.DateTime(iso)

        #expect(rfc.secondsSinceEpoch == 1_705_324_245)
        #expect(rfc.timezoneOffsetSeconds == 0)

    }

    @Test
    func `convert ISO8601 With Timezone To RFC5322`() throws {
        let iso = try ISO_8601.DateTime(
            Time.Instant(secondsSinceUnixEpoch: 1_705_324_245, nanosecondFraction: 0),
            offset: ISO_8601.Timezone.Offset(seconds: -18000)
        )

        let rfc = RFC_5322.DateTime(iso)

        #expect(rfc.secondsSinceEpoch == 1_705_324_245)
        #expect(rfc.timezoneOffsetSeconds == -18000)
    }

    @Test
    func `round Trip ISO8601 To RFC5322 To ISO8601`() throws {
        let original = try ISO_8601.DateTime(
            Time.Instant(secondsSinceUnixEpoch: 1_705_324_245, nanosecondFraction: 0),
            offset: ISO_8601.Timezone.Offset(seconds: 3600)
        )

        let rfc = RFC_5322.DateTime(original)
        let restored = try ISO_8601.DateTime(rfc)

        #expect(restored.instant == original.instant)
        #expect(restored.offset.seconds == original.offset.seconds)
        #expect(restored.nanoseconds == 0)
    }

    @Test
    func `round Trip RFC5322 To ISO8601 To RFC5322`() throws {
        let original = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: -18000
        )

        let iso = try ISO_8601.DateTime(original)
        let restored = RFC_5322.DateTime(iso)

        #expect(restored.secondsSinceEpoch == original.secondsSinceEpoch)
        #expect(restored.timezoneOffsetSeconds == original.timezoneOffsetSeconds)
    }

    @Test
    func `iso8601 Sub Second Precision Is Truncated In RFC5322`() throws {
        let iso = try ISO_8601.DateTime(
            Time.Instant(secondsSinceUnixEpoch: 1_705_324_245, nanosecondFraction: 999_999_999),
            offset: ISO_8601.Timezone.Offset(seconds: 0)
        )

        let rfc = RFC_5322.DateTime(iso)

        #expect(rfc.secondsSinceEpoch == 1_705_324_245)

        let isoRestored = try ISO_8601.DateTime(rfc)
        #expect(isoRestored.nanoseconds == 0)
    }

    @Test
    func `timezone Equivalence Across Formats`() throws {

        let offsets = [
            0,
            3600,
            -18000,
            19800,
            -43200,
        ]

        for offset in offsets {
            let rfc = RFC_5322.DateTime(
                secondsSinceEpoch: 1_705_324_245,
                timezoneOffsetSeconds: offset
            )

            let iso = try ISO_8601.DateTime(rfc)
            #expect(iso.offset.seconds == offset)

            let rfcRestored = RFC_5322.DateTime(iso)
            #expect(rfcRestored.timezoneOffsetSeconds == offset)
        }
    }

    @Test
    func `epoch Preservation Across Conversions`() throws {
        let epochs = [
            0,
            1_705_324_245,
            -86400,
            2_147_483_647,
        ]

        for epoch in epochs {
            let iso = try ISO_8601.DateTime(
                Time.Instant(secondsSinceUnixEpoch: Int64(epoch), nanosecondFraction: 0),
                offset: ISO_8601.Timezone.Offset(seconds: 0)
            )

            let rfc = RFC_5322.DateTime(iso)
            #expect(rfc.secondsSinceEpoch == epoch)

            let isoRestored = try ISO_8601.DateTime(rfc)
            #expect(Int(isoRestored.instant.secondsSinceUnixEpoch) == epoch)
        }
    }

    @Test
    func `sub minute RFC5322 offset throws when converting to ISO8601`() {
        let rfc = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: 30
        )

        #expect(throws: ISO_8601.DateTime.Conversion.Error.offset(.fractionalMinute(30))) {
            try ISO_8601.DateTime(rfc)
        }
    }
}
