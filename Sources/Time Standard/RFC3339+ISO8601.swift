public import ISO_8601
public import RFC_3339
import Time

extension ISO_8601.DateTime {

    public init(_ rfc3339: RFC_3339.DateTime) {
        self.init(
            time: rfc3339.time,
            timezoneOffset: Time.Timezone.Offset(seconds: rfc3339.offset.seconds)
        )
    }
}

extension RFC_3339.DateTime {

    public init(_ iso8601: ISO_8601.DateTime) {
        let offset: RFC_3339.Offset
        if iso8601.timezone.offsetSeconds == 0 {
            offset = .utc
        } else {

            do throws(RFC_3339.Offset.Error) {
                offset = try RFC_3339.Offset(seconds: iso8601.timezone.offsetSeconds)
            } catch {
                offset = .utc
            }
        }

        self.init(time: iso8601.time, offset: offset)
    }
}
