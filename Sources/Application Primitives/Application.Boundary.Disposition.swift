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

extension Application.Boundary {
    /// How a boundary obtains the composition root.
    ///
    /// The distinction is about scope, not about value. A boundary that runs nested
    /// inside the scope carrying the root inherits it; a boundary that starts
    /// detached from that scope must re-establish it. Both resolve to the same
    /// registered root — that is the invariant ``Application/Resolution`` records.
    @frozen
    public enum Disposition: Sendable, Hashable, CaseIterable {
        /// The boundary runs inside the scope that already carries the root.
        case inherited

        /// The boundary starts outside that scope and re-establishes the root itself.
        ///
        /// This is the case that goes wrong silently when it is missed: detached
        /// work keeps running, but against a scope that never carried the root.
        case reapplied
    }
}
