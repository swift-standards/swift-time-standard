// Time.Clock.Continuous+Duration.swift
// Clocks
//
// Duration arithmetic for continuous clock instants.

public import StandardTime

// MARK: - Instant - Instant → Duration (lossless)

/// Returns the duration between two continuous clock instants.
///
/// Positive if `lhs` is after `rhs`, negative otherwise.
/// Follows the affine pattern: Point - Point → Vector.
@inlinable
public func - (
    lhs: Time.Clock.Continuous.Instant,
    rhs: Time.Clock.Continuous.Instant
) -> Duration {
    rhs.duration(to: lhs)
}

// MARK: - Static Duration Helper

extension Time.Clock.Continuous {
    /// Returns the duration between two instants.
    @inlinable
    public static func duration(from start: Instant, to end: Instant) -> Duration {
        start.duration(to: end)
    }
}
