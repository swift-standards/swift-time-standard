public import RFC_3339
public import RFC_5322
import Time_Primitives

extension RFC_5322.DateTime {

    public init(_ rfc3339: RFC_3339.DateTime) {

        self.init(
            time: Time(secondsSinceEpoch: rfc3339.time.secondsSinceEpoch),
            timezoneOffset: Time.Timezone.Offset(seconds: rfc3339.offset.seconds)
        )
    }
}

extension RFC_3339.DateTime {

    public init(_ rfc5322: RFC_5322.DateTime) {
        let offset: RFC_3339.Offset
        if rfc5322.timezoneOffsetSeconds == 0 {
            offset = .utc
        } else {

            do throws(RFC_3339.Offset.Error) {
                offset = try RFC_3339.Offset(seconds: rfc5322.timezoneOffsetSeconds)
            } catch {
                offset = .utc
            }
        }

        self.init(time: rfc5322.time, offset: offset)
    }
}
