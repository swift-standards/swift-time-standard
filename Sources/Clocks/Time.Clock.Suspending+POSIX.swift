// Time.Clock.Suspending+POSIX.swift
// Clocks
//
// POSIX (Linux) implementation of the suspending clock.

#if canImport(Glibc) || canImport(Musl)
    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif
    public import StandardTime
    public import Dimension

    extension Time.Clock.Suspending {
        /// The current instant according to the suspending clock.
        ///
        /// On Linux, uses `CLOCK_MONOTONIC` which pauses during system sleep.
        public var now: Instant {
            var ts = timespec()
            clock_gettime(CLOCK_MONOTONIC, &ts)
            let nanos = Int64(ts.tv_sec) * 1_000_000_000 + Int64(ts.tv_nsec)
            return Instant(nanos)
        }
    }
#endif
