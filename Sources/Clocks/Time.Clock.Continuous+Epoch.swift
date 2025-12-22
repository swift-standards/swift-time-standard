// Time.Clock.Continuous+Epoch.swift
// Clocks
//
// System epoch for the continuous clock.

public import Dimension
public import StandardTime

extension Time.Clock.Continuous {
    /// The system epoch for the continuous clock.
    ///
    /// Represents the reference point from which this clock measures time.
    /// On most systems, this corresponds to system boot time.
    ///
    /// Use `now - systemEpoch` to get the elapsed time since system boot
    /// (including time spent asleep).
    public static var systemEpoch: Instant {
        Instant(0)
    }
}
