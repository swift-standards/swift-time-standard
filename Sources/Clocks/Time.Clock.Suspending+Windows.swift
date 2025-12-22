// Time.Clock.Suspending+Windows.swift
// Clocks
//
// Windows implementation of the suspending clock.

#if os(Windows)
    import WinSDK
    public import StandardTime
    public import Dimension

    extension Time.Clock.Suspending {
        /// The current instant according to the suspending clock.
        ///
        /// On Windows, uses `QueryUnbiasedInterruptTime` which excludes time
        /// spent in sleep/hibernation.
        public var now: Instant {
            var unbiasedTime: ULONGLONG = 0
            QueryUnbiasedInterruptTime(&unbiasedTime)

            // QueryUnbiasedInterruptTime returns 100-nanosecond intervals
            let nanos = Int64(unbiasedTime) * 100
            return Instant(nanos)
        }
    }
#endif
