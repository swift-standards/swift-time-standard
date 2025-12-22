// Time.Clock.Continuous+POSIX.swift
// Clocks
//
// POSIX (Linux) implementation of the continuous clock.

#if canImport(Glibc) || canImport(Musl)
    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif
    public import StandardTime
    public import Dimension

    extension Time.Clock.Continuous {
        /// The current instant according to the continuous clock.
        ///
        /// On Linux, uses `CLOCK_BOOTTIME` which advances during system sleep.
        public var now: Instant {
            var ts = timespec()
            clock_gettime(CLOCK_BOOTTIME, &ts)
            let nanos = Int64(ts.tv_sec) * 1_000_000_000 + Int64(ts.tv_nsec)
            return Instant(nanos)
        }
    }
#endif
