public import ISO_8601

extension ISO_8601.DateTime {

    public enum Conversion {}
}

extension ISO_8601.DateTime.Conversion {

    public enum Error: Swift.Error, Sendable, Equatable {

        case offset(ISO_8601.Timezone.Offset.Error)

        case dateTime(ISO_8601.DateTime.Error)
    }
}
