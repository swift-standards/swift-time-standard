public import ISO_8601
public import RFC_3339
import Calendar
import Calendar_Gregorian
import Time

extension ISO_8601.DateTime {

    public init(_ rfc3339: RFC_3339.DateTime) throws(ISO_8601.DateTime.Conversion.Error) {
        let offset: ISO_8601.Timezone.Offset
        do throws(ISO_8601.Timezone.Offset.Error) {
            offset = try ISO_8601.Timezone.Offset(seconds: rfc3339.offset.seconds)
        } catch {
            throw .offset(error)
        }
        do throws(ISO_8601.DateTime.Error) {
            try self.init(Time::Time.Instant(rfc3339), offset: offset)
        } catch {
            throw .dateTime(error)
        }
    }
}

extension RFC_3339.DateTime {

    public init(_ iso8601: ISO_8601.DateTime) {
        let offset: RFC_3339.Offset
        if iso8601.offset.seconds == 0 {
            offset = .utc
        } else {

            do throws(RFC_3339.Offset.Error) {
                offset = try RFC_3339.Offset(seconds: iso8601.offset.seconds)
            } catch {
                offset = .utc
            }
        }

        let local = Time.Instant(
            _unchecked: (),
            secondsSinceUnixEpoch: iso8601.instant.secondsSinceUnixEpoch + Int64(offset.seconds),
            nanosecondFraction: iso8601.instant.nanosecondFraction
        )

        self.init(time: Gregorian.DateTime(local), offset: offset)
    }
}
