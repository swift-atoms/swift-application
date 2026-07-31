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
    /// Namespace for the two-phase boot shape.
    ///
    /// Boot has two phases and one product. ``Application/Boot/Phase/construction``
    /// builds the process resources explicitly — nothing is discovered, nothing is
    /// implicit. ``Application/Boot/Phase/registration`` composes those resources
    /// into the composition root and registers it. Only then do boundaries open and
    /// resolve.
    ///
    /// ``Application/Boot/Plan`` states that sequence as a value: it cannot register
    /// a root it has not constructed resources for, and it yields an
    /// ``Application/Root`` already in the registered state, so there is no window
    /// in which a root exists unregistered.
    public enum Boot {}
}
