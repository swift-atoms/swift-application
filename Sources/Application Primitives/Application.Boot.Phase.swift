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

extension Application.Boot {
    /// A phase of boot.
    ///
    /// The two phases are ordered, and ``Comparable`` states that order: everything
    /// constructed is constructed before anything is registered. A runtime reporting
    /// where boot stands, or where it stopped, names a phase.
    @frozen
    public enum Phase: Sendable, Hashable, CaseIterable, Comparable {
        /// Process resources are constructed explicitly.
        case construction

        /// The constructed resources are composed into the root and registered.
        case registration
    }
}
