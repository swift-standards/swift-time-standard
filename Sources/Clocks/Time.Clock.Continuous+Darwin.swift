// Time.Clock.Continuous+Darwin.swift
// Clocks
//
// Darwin implementation of the continuous clock.

#if canImport(Darwin)
    import Darwin
    public import StandardTime
    public import Dimension

    extension Time.Clock.Continuous {
        /// The current instant according to the continuous clock.
        ///
        /// On Darwin, uses `CLOCK_MONOTONIC` which advances during system sleep.
        public var now: Instant {
            var ts = timespec()
            clock_gettime(CLOCK_MONOTONIC, &ts)
            let nanos = Int64(ts.tv_sec) * 1_000_000_000 + Int64(ts.tv_nsec)
            return Instant(nanos)
        }
    }
#endif
