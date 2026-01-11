// ISO8601+RFC5322.swift
// Time Standard
//
// Cross-format conversions between ISO 8601 and RFC 5322

import ISO_8601
import RFC_5322
import Time_Primitives

// MARK: - ISO 8601 ↔ RFC 5322 Conversions

extension ISO_8601.DateTime {
    /// Initialize from RFC 5322 DateTime
    ///
    /// Converts an RFC 5322 date-time to ISO 8601 format.
    /// Preserves the instant in time and timezone offset.
    ///
    /// Note: RFC 5322 has no sub-second precision, so nanoseconds will be 0.
    ///
    /// - Parameter rfc5322: RFC 5322 DateTime
    /// - Throws: If conversion fails
    public init(_ rfc5322: RFC_5322.DateTime) throws {
        try self.init(
            secondsSinceEpoch: rfc5322.secondsSinceEpoch,
            nanoseconds: 0,  // RFC 5322 has no sub-second precision
            timezoneOffsetSeconds: rfc5322.timezoneOffsetSeconds
        )
    }
}

extension RFC_5322.DateTime {
    /// Initialize from ISO 8601 DateTime
    ///
    /// Converts an ISO 8601 date-time to RFC 5322 format.
    /// Preserves the instant in time and timezone offset.
    ///
    /// Note: ISO 8601 sub-second precision is truncated (RFC 5322 only supports seconds).
    ///
    /// - Parameter iso8601: ISO 8601 DateTime
    public init(_ iso8601: ISO_8601.DateTime) {
        self.init(
            secondsSinceEpoch: iso8601.secondsSinceEpoch,
            timezoneOffsetSeconds: iso8601.timezoneOffsetSeconds
        )
    }
}
