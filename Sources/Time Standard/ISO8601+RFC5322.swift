import ISO_8601
import RFC_5322
import Time

extension ISO_8601.DateTime {

    public init(_ rfc5322: RFC_5322.DateTime) {

        try! self.init(
            secondsSinceEpoch: rfc5322.secondsSinceEpoch,
            nanoseconds: 0,
            timezoneOffsetSeconds: rfc5322.timezoneOffsetSeconds
        )
    }
}

extension RFC_5322.DateTime {

    public init(_ iso8601: ISO_8601.DateTime) {
        self.init(
            secondsSinceEpoch: iso8601.epoch.seconds,
            timezoneOffsetSeconds: iso8601.timezone.offsetSeconds
        )
    }
}
