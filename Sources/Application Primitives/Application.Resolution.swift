// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-application-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-application-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Application {
    /// The composition root as obtained at one execution boundary.
    ///
    /// A resolution pairs the registered root with the boundary that asked for it
    /// and the disposition under which it was obtained. Producing it is the only
    /// way ``Application/Root/resolve(at:using:)`` reports a boundary's handling,
    /// and it is deliberately a record rather than a branch: the disposition never
    /// changes which value comes back.
    ///
    /// That is the per-boundary re-application invariant. Two resolutions of the
    /// same root at different boundaries, under different dispositions, carry equal
    /// values.
    @frozen
    public struct Resolution<Value: Sendable>: Sendable {
        /// The boundary at which the root was obtained.
        public let boundary: Application.Boundary

        /// How the boundary obtained the root.
        public let disposition: Application.Boundary.Disposition

        /// The registered root.
        public let value: Value

        /// Creates a resolution of `value` at `boundary` under `disposition`.
        public init(
            boundary: Application.Boundary,
            disposition: Application.Boundary.Disposition,
            value: Value
        ) {
            self.boundary = boundary
            self.disposition = disposition
            self.value = value
        }
    }
}

// MARK: - Invariant

extension Application.Resolution where Value: Equatable {
    /// Whether this resolution and `other` agree on the root.
    ///
    /// The invariant holds when every resolution of one registered root agrees,
    /// whatever boundary and disposition produced it. A runtime that fails this
    /// check has re-applied something other than the root it registered.
    public func agrees(with other: Self) -> Bool {
        value == other.value
    }
}

// MARK: - Conditional Conformances

extension Application.Resolution: Equatable where Value: Equatable {}
extension Application.Resolution: Hashable where Value: Hashable {}
