# swift-time-standard

Use this package when you hold a timestamp in one of ISO 8601, RFC 3339 or RFC 5322 and need it in another, or when you need calendar arithmetic with ISO 8601 durations. Start from `ISO_8601.DateTime`, which gains initializers from `RFC_3339.DateTime` and `RFC_5322.DateTime`, and `ISO_8601.DateTime.adding(_:)` for arithmetic. If you only parse or format one of these standards, use swift-iso-8601, swift-rfc-3339 or swift-rfc-5322 directly.

## Laws

- Every conversion keeps the instant and the UTC offset, except as below.
- Converting to `RFC_5322.DateTime` drops the fraction of a second, because RFC 5322 has whole seconds only. Converting back gives zero nanoseconds.
- The RFC 3339 unknown local offset (-00:00) becomes an offset of zero in ISO 8601 and RFC 5322.
- An RFC 5322 offset that is not a whole number of minutes can't become an ISO 8601 offset, so converting it throws.
- `ISO_8601.DateTime.adding(_:)` and `ISO_8601.DateTime.subtracting(_:)` apply years and months first, on the calendar, and keep the day of the month unless the new month is shorter, in which case the day becomes its last day. January 31 plus one month is February 29 in 2024. Days, hours, minutes and seconds are then applied to the instant, with a day as exactly 86,400 seconds.
- Arithmetic keeps the offset of the original date-time. A result past year 9999 throws.
- `ISO_8601.Duration.swiftDuration` is nil when the duration has any years or months, since those have no fixed length, and when the total number of seconds overflows `Int`. Days count as 86,400 seconds.
- An `ISO_8601.Duration` made from a `Swift.Duration` holds hours, minutes, seconds and nanoseconds only, never days. Anything finer than a nanosecond is dropped.
