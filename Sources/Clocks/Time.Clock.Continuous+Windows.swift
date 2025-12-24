// Time.Clock.Continuous+Windows.swift
// Clocks
//
// Windows implementation of the continuous clock.

#if os(Windows)
    import WinSDK
    public import StandardTime
    public import Dimension

    /// Cached QPC frequency (constant after system boot, queried once at first use).
    /// QueryPerformanceFrequency always succeeds on Windows XP and later.
    private let qpcFrequency: Int64 = {
        var frequency: LARGE_INTEGER = LARGE_INTEGER()
        QueryPerformanceFrequency(&frequency)
        return Int64(frequency.QuadPart)
    }()

    extension Time.Clock.Continuous {
        /// The current instant according to the continuous clock.
        ///
        /// On Windows, uses `QueryPerformanceCounter` which provides high-resolution timing.
        /// Note: Windows does not have a true "continuous during sleep" clock;
        /// this uses the best available monotonic source.
        public var now: Instant {
            var counter: LARGE_INTEGER = LARGE_INTEGER()
            QueryPerformanceCounter(&counter)

            // Convert to nanoseconds: counter * 1e9 / frequency
            let nanos = Int64(counter.QuadPart) * 1_000_000_000 / qpcFrequency
            return Instant(nanos)
        }
    }
#endif
