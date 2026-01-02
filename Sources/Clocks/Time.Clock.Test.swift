// Time.Clock.Test.swift
// Clocks
//
// A clock whose time can be controlled deterministically for testing.

public import StandardTime

extension Time.Clock {
    /// A clock whose time can be controlled in a deterministic manner.
    ///
    /// This clock is useful for testing how the flow of time affects asynchronous
    /// and concurrent code. This includes any code that makes use of `sleep` or
    /// any time-based async operators, such as timers, debounce, throttle, timeout.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func testTimer() async {
    ///     let clock = Time.Clock.Test()
    ///     let model = FeatureModel(clock: clock)
    ///
    ///     XCTAssertEqual(model.count, 0)
    ///     model.startTimerButtonTapped()
    ///
    ///     await clock.advance(by: .seconds(1))
    ///     XCTAssertEqual(model.count, 1)
    ///
    ///     await clock.advance(by: .seconds(4))
    ///     XCTAssertEqual(model.count, 5)
    ///
    ///     model.stopTimerButtonTapped()
    ///     await clock.run()
    /// }
    /// ```
    public final class Test: Clock, @unchecked Sendable {
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

        public var minimumResolution: Duration = .zero
        public private(set) var now: Instant

        private var lock = RecursiveLock()
        private var suspensions:
            [(id: UInt64, deadline: Instant, continuation: AsyncStream<Void>.Continuation)] = []
        private var nextID: UInt64 = 0

        public init(now: Instant = .init()) {
            self.now = now
        }

        public func sleep(
            until deadline: Instant,
            tolerance: Duration? = nil
        ) async throws(CancellationError) {
            let wasCancelled = Task.isCancelled
            if wasCancelled { throw CancellationError() }

            let id = nextID
            nextID += 1

            let stream: AsyncStream<Void>? = lock.sync {
                guard deadline > self.now else { return nil }
                return AsyncStream<Void> { continuation in
                    self.suspensions.append(
                        (id: id, deadline: deadline, continuation: continuation)
                    )
                }
            }

            guard let stream else { return }

            for await _ in stream {
                // Stream finished, sleep completed
            }

            if Task.isCancelled {
                lock.sync { self.suspensions.removeAll { $0.id == id } }
                throw CancellationError()
            }
        }

        /// Advances the test clock's internal time by the duration.
        public func advance(by duration: Duration = .zero) async {
            await advance(to: lock.sync { now.advanced(by: duration) })
        }

        /// Advances the test clock's internal time to the deadline.
        public func advance(to deadline: Instant) async {
            while lock.sync({ now <= deadline }) {
                await Task.yield()
                let shouldReturn = lock.sync { () -> Bool in
                    suspensions.sort { $0.deadline < $1.deadline }

                    guard let next = suspensions.first, deadline >= next.deadline else {
                        now = deadline
                        return true
                    }

                    now = next.deadline
                    suspensions.removeFirst()
                    next.continuation.finish()
                    return false
                }

                if shouldReturn {
                    await Task.yield()
                    return
                }
            }
            await Task.yield()
        }

        /// Runs the clock until it has no scheduled sleeps left.
        ///
        /// - Parameter timeout: Maximum time to wait for sleeps to complete.
        public func run(timeout duration: Swift.Duration = .milliseconds(500)) async {
            // Yield to allow pending async work to register their sleeps
            await Task.yield()

            let startTime = ContinuousClock.now
            while lock.sync({ !suspensions.isEmpty }) {
                if startTime.duration(to: ContinuousClock.now) > duration {
                    // Timeout - cancel remaining suspensions
                    lock.sync {
                        for suspension in suspensions {
                            suspension.continuation.finish()
                        }
                        suspensions.removeAll()
                    }
                    return
                }

                if let deadline = lock.sync({ suspensions.first?.deadline }) {
                    await advance(by: lock.sync { now.duration(to: deadline) })
                }
            }
        }

        /// Throws an error if there are active sleeps on the clock.
        public func checkSuspension() async throws(Suspension.Error) {
            await Task.yield()
            guard lock.sync({ suspensions.isEmpty }) else {
                throw Suspension.Error()
            }
        }
    }
}

extension Time.Clock.Test {
    /// Namespace for suspension-related types.
    public enum Suspension {}
}

extension Time.Clock.Test.Suspension {
    /// An error that indicates there are actively suspending sleeps scheduled on the clock.
    public struct Error: Swift.Error, Sendable {}
}
