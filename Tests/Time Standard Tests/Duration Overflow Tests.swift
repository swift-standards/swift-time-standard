import ISO_8601
import Testing
import Time

@testable import Time_Standard

@Suite
struct `Duration overflow` {
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func `a day count too large for seconds converts to nil instead of trapping`() throws {
        let duration = try ISO_8601.Duration("P999999999999999D")
        #expect(duration.swiftDuration == nil)
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func `components that overflow only when summed convert to nil`() throws {
        let duration = try ISO_8601.Duration(days: Int.max / 86400, hours: Int.max / 3600)
        #expect(duration.swiftDuration == nil)
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func `the largest representable day count still converts`() throws {
        let duration = try ISO_8601.Duration(days: Int.max / 86400)
        #expect(duration.swiftDuration == .seconds((Int.max / 86400) * 86400))
    }
}
