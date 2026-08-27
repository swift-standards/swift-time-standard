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

        #expect(iso.epoch.seconds == 1_705_324_245)
        #expect(iso.nanoseconds == 0)
        #expect(iso.timezone.offsetSeconds == 0)
    }

    @Test
    func `convert RFC5322 With Timezone To ISO8601`() throws {
        let rfc = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: 3600
        )

        let iso = try ISO_8601.DateTime(rfc)

        #expect(iso.epoch.seconds == 1_705_324_245)
        #expect(iso.timezone.offsetSeconds == 3600)
    }

    @Test
    func `convert ISO8601 To RFC5322`() throws {
        let iso = try ISO_8601.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            nanoseconds: 123_456_789,
            timezoneOffsetSeconds: 0
        )

        let rfc = RFC_5322.DateTime(iso)

        #expect(rfc.secondsSinceEpoch == 1_705_324_245)
        #expect(rfc.timezoneOffsetSeconds == 0)

    }

    @Test
    func `convert ISO8601 With Timezone To RFC5322`() throws {
        let iso = try ISO_8601.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            nanoseconds: 0,
            timezoneOffsetSeconds: -18000
        )

        let rfc = RFC_5322.DateTime(iso)

        #expect(rfc.secondsSinceEpoch == 1_705_324_245)
        #expect(rfc.timezoneOffsetSeconds == -18000)
    }

    @Test
    func `round Trip ISO8601 To RFC5322 To ISO8601`() throws {
        let original = try ISO_8601.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            nanoseconds: 0,
            timezoneOffsetSeconds: 3600
        )

        let rfc = RFC_5322.DateTime(original)
        let restored = try ISO_8601.DateTime(rfc)

        #expect(restored.epoch.seconds == original.epoch.seconds)
        #expect(restored.timezone.offsetSeconds == original.timezone.offsetSeconds)
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
            secondsSinceEpoch: 1_705_324_245,
            nanoseconds: 999_999_999,
            timezoneOffsetSeconds: 0
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
            #expect(iso.timezone.offsetSeconds == offset)

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
                secondsSinceEpoch: epoch,
                nanoseconds: 0,
                timezoneOffsetSeconds: 0
            )

            let rfc = RFC_5322.DateTime(iso)
            #expect(rfc.secondsSinceEpoch == epoch)

            let isoRestored = try ISO_8601.DateTime(rfc)
            #expect(isoRestored.epoch.seconds == epoch)
        }
    }
}
