// DurationArithmeticTests.swift
// Time Standard Tests
//
// Tests for ISO 8601 Duration arithmetic

import ISO_8601
import Time_Primitives
import Testing

@testable import Time_Standard

@Suite
struct DurationArithmeticTests {

    // MARK: - ISO 8601 Duration → Swift.Duration

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func convertTimeOnlyDurationToSwift() throws {
        let duration = try ISO_8601.Duration(hours: 2, minutes: 30, seconds: 45)
        let swiftDuration = duration.swiftDuration

        #expect(swiftDuration != nil)
        let expected = Duration.seconds(2 * 3600 + 30 * 60 + 45)
        #expect(swiftDuration == expected)
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func convertDurationWithDaysToSwift() throws {
        let duration = try ISO_8601.Duration(days: 1, hours: 12)
        let swiftDuration = duration.swiftDuration

        #expect(swiftDuration != nil)
        let expected = Duration.seconds(86400 + 12 * 3600)
        #expect(swiftDuration == expected)
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func convertDurationWithNanosecondsToSwift() throws {
        let duration = try ISO_8601.Duration(seconds: 1, nanoseconds: 500_000_000)
        let swiftDuration = duration.swiftDuration

        #expect(swiftDuration != nil)
        let expected = Duration.seconds(1) + Duration.nanoseconds(500_000_000)
        #expect(swiftDuration == expected)
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func durationWithYearsReturnsNil() throws {
        let duration = try ISO_8601.Duration(years: 1, days: 5)
        #expect(duration.swiftDuration == nil)
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func durationWithMonthsReturnsNil() throws {
        let duration = try ISO_8601.Duration(months: 6, hours: 12)
        #expect(duration.swiftDuration == nil)
    }

    // MARK: - Swift.Duration → ISO 8601 Duration

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func convertSwiftDurationToISO8601() throws {
        let swiftDuration = Duration.seconds(3661)  // 1 hour, 1 minute, 1 second
        let iso8601 = try ISO_8601.Duration(swiftDuration)

        #expect(iso8601.years == 0)
        #expect(iso8601.months == 0)
        #expect(iso8601.days == 0)
        #expect(iso8601.hours == 1)
        #expect(iso8601.minutes == 1)
        #expect(iso8601.seconds == 1)
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func convertSwiftDurationWithNanoseconds() throws {
        let swiftDuration = Duration.seconds(1) + Duration.nanoseconds(123_456_789)
        let iso8601 = try ISO_8601.Duration(swiftDuration)

        #expect(iso8601.seconds == 1)
        #expect(iso8601.nanoseconds == 123_456_789)
    }

    // MARK: - DateTime + Duration

    @Test
    func addTimeOnlyDuration() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 10,
            minute: 30,
            second: 0
        )
        let duration = try ISO_8601.Duration(hours: 2, minutes: 30)

        let result = dateTime + duration

        #expect(result.time.hour.value == 13)
        #expect(result.time.minute.value == 0)
    }

    @Test
    func addDaysDuration() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 10,
            minute: 0,
            second: 0
        )
        let duration = try ISO_8601.Duration(days: 20)

        let result = dateTime + duration

        #expect(result.time.year.rawValue == 2024)
        #expect(result.time.month.rawValue == 2)
        #expect(result.time.day.rawValue == 4)
    }

    @Test
    func addMonthsDuration() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 0,
            second: 0
        )
        let duration = try ISO_8601.Duration(months: 3)

        let result = dateTime + duration

        #expect(result.time.year.rawValue == 2024)
        #expect(result.time.month.rawValue == 4)
        #expect(result.time.day.rawValue == 15)
    }

    @Test
    func addMonthsWithDayClamping() throws {
        // Jan 31 + 1 month = Feb 29 (2024 is leap year)
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 31,
            hour: 12,
            minute: 0,
            second: 0
        )
        let duration = try ISO_8601.Duration(months: 1)

        let result = dateTime + duration

        #expect(result.time.year.rawValue == 2024)
        #expect(result.time.month.rawValue == 2)
        #expect(result.time.day.rawValue == 29)  // Clamped to end of Feb
    }

    @Test
    func addYearsDuration() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 6,
            day: 15,
            hour: 12,
            minute: 0,
            second: 0
        )
        let duration = try ISO_8601.Duration(years: 2)

        let result = dateTime + duration

        #expect(result.time.year.rawValue == 2026)
        #expect(result.time.month.rawValue == 6)
        #expect(result.time.day.rawValue == 15)
    }

    // MARK: - DateTime - Duration

    @Test
    func subtractTimeDuration() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 10,
            minute: 30,
            second: 0
        )
        let duration = try ISO_8601.Duration(hours: 2, minutes: 30)

        let result = dateTime - duration

        #expect(result.time.hour.value == 8)
        #expect(result.time.minute.value == 0)
    }

    @Test
    func subtractDaysDuration() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 2,
            day: 4,
            hour: 10,
            minute: 0,
            second: 0
        )
        let duration = try ISO_8601.Duration(days: 20)

        let result = dateTime - duration

        #expect(result.time.year.rawValue == 2024)
        #expect(result.time.month.rawValue == 1)
        #expect(result.time.day.rawValue == 15)
    }

    @Test
    func subtractMonthsDuration() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 4,
            day: 15,
            hour: 12,
            minute: 0,
            second: 0
        )
        let duration = try ISO_8601.Duration(months: 3)

        let result = dateTime - duration

        #expect(result.time.year.rawValue == 2024)
        #expect(result.time.month.rawValue == 1)
        #expect(result.time.day.rawValue == 15)
    }

    // MARK: - Preserves Timezone

    @Test
    func preservesTimezoneOffset() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 10,
            minute: 0,
            second: 0,
            nanoseconds: 0,
            timezoneOffsetSeconds: 3600  // +01:00
        )
        let duration = try ISO_8601.Duration(hours: 1)

        let result = dateTime + duration

        #expect(result.timezoneOffsetSeconds == 3600)
    }
}
