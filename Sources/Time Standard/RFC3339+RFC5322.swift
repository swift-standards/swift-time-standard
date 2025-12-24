// RFC3339+RFC5322.swift
// Time Standard
//
// Cross-format conversions between RFC 3339 and RFC 5322

public import RFC_3339
public import RFC_5322
import StandardTime

// MARK: - RFC 3339 → RFC 5322

extension RFC_5322.DateTime {
    /// Initialize from RFC 3339 DateTime
    ///
    /// Converts an RFC 3339 date-time to RFC 5322 format.
    /// Preserves the instant in time and timezone offset.
    ///
    /// Note: RFC 3339 sub-second precision is truncated (RFC 5322 only supports seconds).
    ///
    /// - Parameter rfc3339: RFC 3339 DateTime
    public init(_ rfc3339: RFC_3339.DateTime) {
        // RFC 5322 doesn't support sub-second precision, so we use only whole seconds
        self.init(
            time: Time(secondsSinceEpoch: rfc3339.time.secondsSinceEpoch),
            timezoneOffset: Time.TimezoneOffset(seconds: rfc3339.offset.seconds)
        )
    }
}

// MARK: - RFC 5322 → RFC 3339

extension RFC_3339.DateTime {
    /// Initialize from RFC 5322 DateTime
    ///
    /// Converts an RFC 5322 date-time to RFC 3339 format.
    /// Preserves the instant in time and timezone offset.
    ///
    /// Note: RFC 5322 has no sub-second precision, so nanoseconds will be 0.
    ///
    /// - Parameter rfc5322: RFC 5322 DateTime
    public init(_ rfc5322: RFC_5322.DateTime) {
        let offset: RFC_3339.Offset
        if rfc5322.timezoneOffsetSeconds == 0 {
            offset = .utc
        } else {
            // RFC 3339 offset is validated, but RFC 5322 uses the same range
            offset = (try? RFC_3339.Offset(seconds: rfc5322.timezoneOffsetSeconds)) ?? .utc
        }

        self.init(time: rfc5322.time, offset: offset)
    }
}
