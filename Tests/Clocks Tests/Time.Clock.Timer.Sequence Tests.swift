// Time.Clock.Timer.Sequence Tests.swift
// Clocks Tests

import StandardsTestSupport
import Testing

@testable import Clocks

// Timer.Sequence is generic, so we test with concrete clock types
// using a dedicated test enum

enum TimerSequenceTests {
    #TestSuites
}

// MARK: - Unit Tests

extension TimerSequenceTests.Test.Unit {
    @Test("timer emits at regular intervals with TestClock")
    @MainActor
    func timerEmitsAtIntervals() async {
        await withSerialExecutor {
            let clock = Time.Clock.Test()

            let task = Task<Int, Never> {
                var count = 0
                for await _ in clock.timer(interval: .seconds(1)) {
                    count += 1
                    if count >= 2 { break }
                }
                return count
            }

            // Advance to trigger first tick
            await clock.advance(by: .seconds(1))
            #expect(clock.now.offset == .seconds(1))

            // Advance to trigger second tick
            await clock.advance(by: .seconds(1))
            #expect(clock.now.offset == .seconds(2))

            let tickCount = await task.value
            #expect(tickCount == 2)
        }
    }

    @Test("timer respects tolerance parameter")
    @MainActor
    func timerRespectssTolerance() async {
        await withSerialExecutor {
            let clock = Time.Clock.Test()

            let task = Task<Bool, Never> {
                for await _ in clock.timer(interval: .seconds(1), tolerance: .milliseconds(100)) {
                    return true
                }
                return false
            }

            await clock.advance(by: .seconds(1))
            let receivedTick = await task.value
            #expect(receivedTick)
        }
    }

    @Test("timer with ImmediateClock emits immediately")
    func timerWithImmediateClock() async {
        let clock = Time.Clock.Immediate()
        let timer = clock.timer(interval: .seconds(100))
        var iterator = timer.makeAsyncIterator()

        // Should complete almost immediately
        let before = ContinuousClock.now
        let instant = await iterator.next()
        let elapsed = before.duration(to: ContinuousClock.now)

        #expect(instant != nil)
        #expect(elapsed < .seconds(1))  // Should not actually wait 100 seconds
    }

    @Test("timer conforms to AsyncSequence")
    func conformsToAsyncSequence() async {
        let clock = Time.Clock.Test()
        let timer: Time.Clock.Timer<Time.Clock.Test>.Sequence = clock.timer(interval: .seconds(1))
        // Verify it has AsyncSequence conformance
        _ = timer.makeAsyncIterator()
    }

    @Test("timer Element type is clock Instant")
    @MainActor
    func elementTypeIsInstant() async {
        await withSerialExecutor {
            let clock = Time.Clock.Test()

            let task = Task<Time.Clock.Test.Instant?, Never> {
                for await tick in clock.timer(interval: .seconds(1)) {
                    return tick
                }
                return nil
            }

            await clock.advance(by: .seconds(1))
            let instant = await task.value
            #expect(instant != nil)
        }
    }
}

// MARK: - Edge Cases

extension TimerSequenceTests.Test.EdgeCase {
    @Test("timer stops on task cancellation")
    @MainActor
    func timerStopsOnCancellation() async {
        await withSerialExecutor {
            let clock = Time.Clock.Test()

            let task = Task {
                for await _ in clock.timer(interval: .seconds(1)) {
                    // This should never complete because we cancel
                }
            }

            // Cancel immediately
            task.cancel()

            // Await completion (should exit due to cancellation)
            await task.value
        }
    }

    @Test("timer with zero interval")
    @MainActor
    func timerWithZeroInterval() async {
        await withSerialExecutor {
            let clock = Time.Clock.Test()

            let task = Task<Bool, Never> {
                for await _ in clock.timer(interval: .zero) {
                    return true
                }
                return false
            }

            await clock.advance(by: .zero)
            let receivedTick = await task.value
            #expect(receivedTick)
        }
    }

    @Test("timer catches up when clock advances past multiple intervals")
    @MainActor
    func timerCatchesUp() async {
        await withSerialExecutor {
            let clock = Time.Clock.Test()

            let task = Task<Int, Never> {
                var count = 0
                for await _ in clock.timer(interval: .seconds(1)) {
                    count += 1
                    if count >= 2 { break }
                }
                return count
            }

            // Advance by 5 seconds at once - first tick fires at 1s
            await clock.advance(by: .seconds(5))

            // Advance by 1 more second for second tick at 2s
            await clock.advance(by: .seconds(1))

            let tickCount = await task.value
            #expect(tickCount == 2)
        }
    }

    @Test("multiple timers on same clock work independently")
    @MainActor
    func multipleTimers() async {
        await withSerialExecutor {
            let clock = Time.Clock.Test()

            let task1 = Task<Int, Never> {
                var count = 0
                for await _ in clock.timer(interval: .seconds(1)) {
                    count += 1
                    if count >= 2 { break }
                }
                return count
            }

            let task2 = Task<Int, Never> {
                var count = 0
                for await _ in clock.timer(interval: .seconds(2)) {
                    count += 1
                    if count >= 1 { break }
                }
                return count
            }

            // Advance to 2 seconds - timer1 ticks at 1s and 2s, timer2 ticks at 2s
            await clock.advance(by: .seconds(2))

            let timer1Count = await task1.value
            let timer2Count = await task2.value

            #expect(timer1Count == 2)
            #expect(timer2Count == 1)
        }
    }
}

// MARK: - Performance

extension TimerSequenceTests.Test.Performance {
    @Test("timer iteration overhead", .timed(iterations: 100, warmup: 10))
    func timerIterationOverhead() async {
        let clock = Time.Clock.Immediate()
        var count = 0
        for await _ in clock.timer(interval: .milliseconds(1)).prefix(100) {
            count += 1
        }
        #expect(count == 100)
    }
}
