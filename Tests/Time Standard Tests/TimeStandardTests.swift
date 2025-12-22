// TimeStandardTests.swift
// Time Standard Tests
//
// Tests for cross-standard conversions

import ISO_8601
import RFC_5322
import StandardTime
import Testing

@testable import Time_Standard

@Suite
struct TimeStandardCrossFormatConversionTests {

    // MARK: - ISO 8601 ↔ RFC 5322 Conversions

    @Test
    func convertRFC5322ToISO8601() throws {
        let rfc = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,  // 2024-01-15 12:30:45 UTC
            timezoneOffsetSeconds: 0
        )

        let iso = try ISO_8601.DateTime(rfc)

        #expect(iso.secondsSinceEpoch == 1_705_324_245)
        #expect(iso.nanoseconds == 0)  // RFC 5322 has no sub-second precision
        #expect(iso.timezoneOffsetSeconds == 0)
    }

    @Test
    func convertRFC5322WithTimezoneToISO8601() throws {
        let rfc = RFC_5322.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            timezoneOffsetSeconds: 3600  // +01:00
        )

        let iso = try ISO_8601.DateTime(rfc)

        #expect(iso.secondsSinceEpoch == 1_705_324_245)
        #expect(iso.timezoneOffsetSeconds == 3600)  // Timezone preserved
    }

    @Test
    func convertISO8601ToRFC5322() throws {
        let iso = try ISO_8601.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            nanoseconds: 123_456_789,
            timezoneOffsetSeconds: 0
        )

        let rfc = RFC_5322.DateTime(iso)

        #expect(rfc.secondsSinceEpoch == 1_705_324_245)
        #expect(rfc.timezoneOffsetSeconds == 0)
        // Note: Sub-second precision is lost in RFC 5322
    }

    @Test
    func convertISO8601WithTimezoneToRFC5322() throws {
        let iso = try ISO_8601.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            nanoseconds: 0,
            timezoneOffsetSeconds: -18000  // -05:00
        )

        let rfc = RFC_5322.DateTime(iso)

        #expect(rfc.secondsSinceEpoch == 1_705_324_245)
        #expect(rfc.timezoneOffsetSeconds == -18000)  // Timezone preserved
    }

    @Test
    func roundTripISO8601ToRFC5322ToISO8601() throws {
        let original = try ISO_8601.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            nanoseconds: 0,  // No sub-second for clean round-trip
            timezoneOffsetSeconds: 3600
        )

        let rfc = RFC_5322.DateTime(original)
        let restored = try ISO_8601.DateTime(rfc)

        #expect(restored.secondsSinceEpoch == original.secondsSinceEpoch)
        #expect(restored.timezoneOffsetSeconds == original.timezoneOffsetSeconds)
        #expect(restored.nanoseconds == 0)  // Sub-second precision lost
    }

    @Test
    func roundTripRFC5322ToISO8601ToRFC5322() throws {
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
    func iso8601SubSecondPrecisionIsTruncatedInRFC5322() throws {
        let iso = try ISO_8601.DateTime(
            secondsSinceEpoch: 1_705_324_245,
            nanoseconds: 999_999_999,  // Maximum nanoseconds
            timezoneOffsetSeconds: 0
        )

        let rfc = RFC_5322.DateTime(iso)

        // RFC 5322 only has second precision
        #expect(rfc.secondsSinceEpoch == 1_705_324_245)

        // Converting back loses sub-second precision
        let isoRestored = try ISO_8601.DateTime(rfc)
        #expect(isoRestored.nanoseconds == 0)
    }

    @Test
    func timezoneEquivalenceAcrossFormats() throws {
        // Test various timezone offsets
        let offsets = [
            0,  // UTC
            3600,  // +01:00
            -18000,  // -05:00
            19800,  // +05:30 (India)
            -43200,  // -12:00
        ]

        for offset in offsets {
            let rfc = RFC_5322.DateTime(
                secondsSinceEpoch: 1_705_324_245,
                timezoneOffsetSeconds: offset
            )

            let iso = try ISO_8601.DateTime(rfc)
            #expect(iso.timezoneOffsetSeconds == offset)

            let rfcRestored = RFC_5322.DateTime(iso)
            #expect(rfcRestored.timezoneOffsetSeconds == offset)
        }
    }

    @Test
    func epochPreservationAcrossConversions() throws {
        let epochs = [
            0,  // Unix epoch
            1_705_324_245,  // 2024-01-15 12:30:45
            -86400,  // Before epoch
            2_147_483_647,  // Y2038 problem boundary
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
            #expect(isoRestored.secondsSinceEpoch == epoch)
        }
    }
}
