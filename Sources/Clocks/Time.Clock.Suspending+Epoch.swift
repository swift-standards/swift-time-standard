// Time.Clock.Suspending+Epoch.swift
// Clocks
//
// System epoch for the suspending clock.

public import Dimension
public import StandardTime

extension Time.Clock.Suspending {
    /// The system epoch for the suspending clock.
    ///
    /// Represents the reference point from which this clock measures time.
    /// On most systems, this corresponds to system boot time, but the elapsed
    /// time excludes periods when the system was asleep.
    ///
    /// Use `now - systemEpoch` to get the elapsed active time since system boot.
    public static var systemEpoch: Instant {
        Instant(0)
    }
}
