// Time.Clock.Suspending+Darwin.swift
// Clocks
//
// Darwin implementation of the suspending clock.

#if canImport(Darwin)
    import Darwin
    public import StandardTime
    public import Dimension

    extension Time.Clock.Suspending {
        /// The current instant according to the suspending clock.
        ///
        /// On Darwin, uses `CLOCK_UPTIME_RAW` which pauses during system sleep.
        public var now: Instant {
            var ts = timespec()
            clock_gettime(CLOCK_UPTIME_RAW, &ts)
            let nanos = Int64(ts.tv_sec) * 1_000_000_000 + Int64(ts.tv_nsec)
            return Instant(nanos)
        }
    }
#endif
