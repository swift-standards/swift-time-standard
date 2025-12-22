# Time Standard

Unified time representation across all time standards in pure Swift.

## Overview

Time Standard provides a single, canonical `Time` type that composes multiple time standards (ISO 8601, RFC 5322, etc.) into a unified interface. It follows the same architectural pattern as [EmailAddress Standard](https://github.com/swift-standards/swift-emailaddress-standard) and [URI Standard](https://github.com/swift-standards/swift-uri-standard).

## Architecture

Time Standard is an **aggregation package** that sits atop the swift-standards ecosystem:

```
swift-standards/Time          ← Foundation (UTC, nanosecond precision)
    ↓
swift-iso-8601               ← ISO 8601:2019 date-time formatting
swift-rfc-5322               ← RFC 5322 email date headers
    ↓
swift-time-standard          ← THIS PACKAGE (unified API)
```

### Design Principles

1. **Single Canonical Representation**: Internally stores `Standards.Time` (UTC, nanosecond precision)
2. **Format-Specific Views**: Computes ISO 8601, RFC 5322, etc. on-demand
3. **Preservation of Precision**: Full nanosecond precision maintained in canonical form
4. **Timezone-Agnostic Core**: UTC only; timezones handled by format-specific types
5. **Category-Theoretic Foundation**: Based on functors, natural transformations (see CATEGORICAL_PROPERTIES.md in swift-standards/Time)

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-time-standard", from: "0.1.0")
]
```

Then add to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Time Standard", package: "swift-time-standard")
    ]
)
```

## Usage

### Creating Times

```swift
import StandardTime

// From components (UTC)
let time = try Time(
    year: 2024,
    month: 1,
    day: 15,
    hour: 12,
    minute: 30,
    second: 45,
    millisecond: 123,
    microsecond: 456,
    nanosecond: 789
)

// From foundation Time
import StandardTime  // From swift-standards
let Time = try Standards.Time(year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 0)
let time = Time(Time)

// From ISO 8601
let time = try Time(iso8601String: "2024-01-15T12:30:45.123Z")

// From RFC 5322
let time = try Time(rfc5322String: "Mon, 15 Jan 2024 12:30:45 +0000")
```

### Accessing Components

```swift
let time = try Time(year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 45)

// Individual components (refined types from swift-standards/Time)
print(time.year.value)        // 2024
print(time.month.value)       // 1
print(time.day.value)         // 15
print(time.hour.value)        // 12
print(time.minute.value)      // 30
print(time.second.value)      // 45

// Sub-second precision
print(time.millisecond.value) // 0
print(time.totalNanoseconds)  // 0

// Unix timestamp
print(time.unixTimestamp)     // 1705324245
```

### Format Conversions

```swift
let time = try Time(year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 45)

// Convert to ISO 8601
let iso = try time.iso8601
print(iso.secondsSinceEpoch)      // 1705324245
print(iso.nanoseconds)            // 0
print(iso.timezoneOffsetSeconds)  // 0 (UTC)

// Convert to RFC 5322
let rfc = time.rfc5322
print(rfc.secondsSinceEpoch)      // 1705324245
print(rfc.timezoneOffsetSeconds)  // 0 (UTC)
```

### String Formatting

```swift
let time = try Time(year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 45)

// ISO 8601 format (default for description)
print(time.description)              // "2024-01-15T12:30:45Z"
print(try time.iso8601String())      // "2024-01-15T12:30:45Z"

// RFC 5322 format (email headers)
print(time.rfc5322String())          // "Mon, 15 Jan 2024 12:30:45 +0000"

// Custom ISO 8601 formatting
print(try time.iso8601String(
    format: .basic,
    precision: .seconds
))  // "20240115T123045Z"
```

### Codable Support

```swift
import Foundation

// Time encodes/decodes as ISO 8601 string
let time = try Time(year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 0)

let encoder = JSONEncoder()
let data = try encoder.encode(time)
// {"time":"2024-01-15T12:30:00Z"}

let decoder = JSONDecoder()
let decoded = try decoder.decode(Time.self, from: data)
```

## Supported Standards

Currently supports:

- **[ISO 8601:2019](https://github.com/swift-standards/swift-iso-8601)** - International date-time standard
  - Extended and basic formats
  - Nanosecond precision
  - Timezone offsets

- **[RFC 5322](https://github.com/swift-standards/swift-rfc-5322)** - Internet Message Format
  - Email date headers
  - Timezone offsets
  - No sub-second precision

Future standards:

- **RFC 3339** - Internet timestamps (profile of ISO 8601)
- **POSIX time** - `time_t`, `struct tm`
- **NTP** - Network Time Protocol
- **GPS time** - Global Positioning System time

## Precision and Timezones

### Precision

The canonical `Standards.Time` representation provides:
- Nanosecond precision (10^-9 seconds)
- Cascading sub-second fields: millisecond, microsecond, nanosecond
- Total nanoseconds: 0-999,999,999

Different formats have different precision:
- **ISO 8601**: Nanosecond precision supported
- **RFC 5322**: Second precision only (sub-seconds truncated)

### Timezones

The canonical `Time` is always **UTC**. Timezone offsets are handled by format-specific types:

```swift
import ISO_8601

// Create ISO 8601 with timezone offset
let iso = try ISO_8601.DateTime(
    year: 2024, month: 1, day: 15,
    hour: 12, minute: 30, second: 0,
    timezoneOffsetSeconds: 3600  // +01:00
)

// Convert to canonical Time (UTC)
let time = try Time(iso)
// Timezone offset discarded, instant preserved
```

## Category Theory Foundation

The Time Standard architecture is grounded in category theory:

### Time as Initial Object

`Standards.Time` is the **initial object** in the category of time representations:
- Most primitive, format-agnostic
- All other time types have unique morphisms from Time
- See `swift-standards/Sources/Time/CATEGORICAL_PROPERTIES.md`

### Functors

Each standard package defines a **functor**:
- `F_ISO8601: Time → ISO_8601.DateTime`
- `F_RFC5322: Time → RFC_5322.DateTime`
- These preserve structure (components, ordering, instants)

### Colimit

Time Standard is the **colimit** (coproduct):
- Universal construction over all time standard functors
- Canonical representation that all formats map into
- Conversions between formats commute

### Natural Transformations

Format conversions are **natural transformations**:
```
Time → ISO_8601 → RFC_5322  =  Time → RFC_5322
```

This ensures consistency across format conversions.

## Requirements

- Swift 6.0+
- macOS 15.0+ / iOS 18.0+ / tvOS 18.0+ / watchOS 11.0+

## Dependencies

- [swift-standards](https://github.com/swift-standards/swift-standards) - Foundation utilities and Time
- [swift-iso-8601](https://github.com/swift-standards/swift-iso-8601) - ISO 8601 implementation
- [swift-rfc-5322](https://github.com/swift-standards/swift-rfc-5322) - RFC 5322 implementation

## Related Packages

- **[swift-emailaddress-standard](https://github.com/swift-standards/swift-emailaddress-standard)** - Unified email address (same pattern)
- **[swift-uri-standard](https://github.com/swift-standards/swift-uri-standard)** - Unified URI (same pattern)
- **[swift-domain-standard](https://github.com/swift-standards/swift-domain-standard)** - Unified domain (same pattern)

## Contributing

Contributions welcome! This package follows the swift-standards philosophy:

1. **Academic rigor**: Category theory foundations
2. **Type safety**: Invalid states unrepresentable
3. **Pure Swift**: No Foundation dependencies in core
4. **Standard compliance**: Literal implementation of specs

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

Apache License 2.0

## See Also

- **[Swift Standards Organization](https://github.com/swift-standards)** - All standards packages
- **[CATEGORICAL_PROPERTIES.md](https://github.com/swift-standards/swift-standards/blob/main/Sources/Time/CATEGORICAL_PROPERTIES.md)** - Mathematical foundation of Time module
