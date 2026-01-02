// Time.Clock.Timer.Sequence.swift
// Clocks
//
// AsyncSequence for timer intervals.

public import StandardTime

extension Time.Clock {
    /// Namespace for timer-related types.
    public enum Timer<C: Clock> {}
}

extension Time.Clock.Timer {
    /// An asynchronous sequence that emits the clock's current instant at regular intervals.
    public struct Sequence: AsyncSequence, Sendable where C: Sendable {
        public typealias Element = C.Instant

        let interval: C.Duration
        let tolerance: C.Duration?
        let clock: C

        public init(interval: C.Duration, tolerance: C.Duration?, clock: C) {
            self.interval = interval
            self.tolerance = tolerance
            self.clock = clock
        }

        public func makeAsyncIterator() -> Iterator {
            Iterator(interval: interval, tolerance: tolerance, clock: clock)
        }

        public struct Iterator: AsyncIteratorProtocol {
            let interval: C.Duration
            let tolerance: C.Duration?
            let clock: C
            var nextDeadline: C.Instant?

            init(interval: C.Duration, tolerance: C.Duration?, clock: C) {
                self.interval = interval
                self.tolerance = tolerance
                self.clock = clock
                self.nextDeadline = nil
            }

            public mutating func next() async -> C.Instant? {
                let deadline: C.Instant
                if let next = nextDeadline {
                    deadline = next
                } else {
                    deadline = clock.now.advanced(by: interval)
                }

                do {
                    try await clock.sleep(until: deadline, tolerance: tolerance)
                } catch {
                    return nil
                }

                let now = clock.now
                nextDeadline = deadline.advanced(by: interval)
                return now
            }
        }
    }
}
