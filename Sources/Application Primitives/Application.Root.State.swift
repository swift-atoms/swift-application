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

extension Application.Root {
    /// Whether the composition root has been registered, and with what.
    ///
    /// There are exactly two states, and no transition out of ``registered(_:)``.
    /// That is what set-once means.
    @frozen
    public enum State: Sendable {
        /// Boot has not registered a root yet.
        case unset

        /// Boot registered this value as the root.
        case registered(Value)
    }
}

// MARK: - Conditional Conformances

extension Application.Root.State: Equatable where Value: Equatable {}
extension Application.Root.State: Hashable where Value: Hashable {}
