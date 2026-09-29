import ISO_8601
import RFC_5322
import Time

extension ISO_8601.DateTime {

    public init(_ rfc5322: RFC_5322.DateTime) throws(ISO_8601.DateTime.Conversion.Error) {
        let instant = Time::Time.Instant(secondsSinceUnixEpoch: Int64(rfc5322.secondsSinceEpoch))
        let offset: ISO_8601.Timezone.Offset
        do throws(ISO_8601.Timezone.Offset.Error) {
            offset = try ISO_8601.Timezone.Offset(seconds: rfc5322.timezoneOffsetSeconds)
        } catch {
            throw .offset(error)
        }
        do throws(ISO_8601.DateTime.Error) {
            try self.init(instant, offset: offset)
        } catch {
            throw .dateTime(error)
        }
    }
}

extension RFC_5322.DateTime {

    public init(_ iso8601: ISO_8601.DateTime) {
        self.init(
            secondsSinceEpoch: Int(iso8601.instant.secondsSinceUnixEpoch),
            timezoneOffsetSeconds: iso8601.offset.seconds
        )
    }
}
