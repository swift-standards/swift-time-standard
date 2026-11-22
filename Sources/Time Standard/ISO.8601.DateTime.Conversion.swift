public import ISO_8601

extension ISO.`8601`.DateTime {

    public enum Conversion {}
}

extension ISO.`8601`.DateTime.Conversion {

    public enum Error: Swift::Error, Sendable, Equatable {

        case offset(ISO.`8601`.Timezone.Offset.Error)

        case dateTime(ISO.`8601`.DateTime.Error)
    }
}
