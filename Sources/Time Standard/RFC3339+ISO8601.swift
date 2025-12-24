// RFC3339+ISO8601.swift
// Time Standard
//
// Cross-format conversions between RFC 3339 and ISO 8601

public import ISO_8601
public import RFC_3339
import StandardTime

// MARK: - RFC 3339 → ISO 8601

extension ISO_8601.DateTime {
    /// Initialize from RFC 3339 DateTime
    ///
    /// Converts an RFC 3339 date-time to ISO 8601 format.
    /// Preserves the instant in time, timezone offset, and sub-second precision.
    ///
    /// - Parameter rfc3339: RFC 3339 DateTime
    public init(_ rfc3339: RFC_3339.DateTime) {
        self.init(
            time: rfc3339.time,
            timezoneOffset: Time.TimezoneOffset(seconds: rfc3339.offset.seconds)
        )
    }
}

// MARK: - ISO 8601 → RFC 3339

extension RFC_3339.DateTime {
    /// Initialize from ISO 8601 DateTime
    ///
    /// Converts an ISO 8601 date-time to RFC 3339 format.
    /// Preserves the instant in time, timezone offset, and sub-second precision.
    ///
    /// - Parameter iso8601: ISO 8601 DateTime
    public init(_ iso8601: ISO_8601.DateTime) {
        let offset: RFC_3339.Offset
        if iso8601.timezoneOffsetSeconds == 0 {
            offset = .utc
        } else {
            // RFC 3339 offset is validated, but ISO 8601 uses the same range
            offset = (try? RFC_3339.Offset(seconds: iso8601.timezoneOffsetSeconds)) ?? .utc
        }

        self.init(time: iso8601.time, offset: offset)
    }
}
