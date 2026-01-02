// Time.Clock.Immediate.swift
// Clocks
//
// A clock that does not suspend when sleeping.

public import StandardTime

extension Time.Clock {
    /// A clock that does not suspend when sleeping.
    ///
    /// This clock is useful for squashing all of time down to a single instant,
    /// forcing any `sleep`s to execute immediately. This is particularly useful
    /// for SwiftUI previews where you want to see the final state without waiting.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct Feature_Previews: PreviewProvider {
    ///     static var previews: some View {
    ///         Feature(clock: Time.Clock.Immediate())
    ///     }
    /// }
    /// ```
    public final class Immediate: Clock, @unchecked Sendable {
        public struct Instant: InstantProtocol, Sendable {
            public let offset: Duration

            public init(offset: Duration = .zero) {
                self.offset = offset
            }

            public func advanced(by duration: Duration) -> Self {
                .init(offset: offset + duration)
            }

            public func duration(to other: Self) -> Duration {
                other.offset - offset
            }

            public static func < (lhs: Self, rhs: Self) -> Bool {
                lhs.offset < rhs.offset
            }
        }

        public private(set) var now: Instant
        public var minimumResolution: Duration = .zero
        private var lock = Lock()

        public init(now: Instant = .init()) {
            self.now = now
        }

        public func sleep(until deadline: Instant, tolerance: Duration?) async throws {
            try Task.checkCancellation()
            lock.sync { now = deadline }
            await Task.yield()
        }
    }
}
