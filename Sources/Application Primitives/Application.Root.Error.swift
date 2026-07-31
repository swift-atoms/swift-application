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

/// A violation of the set-once composition-root contract.
///
/// Declared at module scope and reached through ``Application/Root/Error``. An
/// error enum nested in a generic type that never uses that type's parameter is
/// accidentally generic: its `@error` result carries a type parameter, which is the
/// shape that trips the optimizer's function-signature pass in release builds of
/// the package and of every consumer. Hoisting is the sanctioned fix; the public
/// spelling stays ``Application/Root/Error``.
@frozen
public enum __ApplicationRootError: Swift.Error, Sendable, Hashable {
    /// A root was already registered.
    ///
    /// Produced by ``Application/Root/register(_:)``. Set-once admits no second
    /// registration, so this reports a defect in the boot sequence rather than a
    /// condition to recover from.
    case alreadyRegistered

    /// No root has been registered.
    ///
    /// Produced by ``Application/Root/resolve()`` and
    /// ``Application/Root/resolve(at:using:)``. It means a boundary opened before
    /// boot finished registering the root.
    case notRegistered
}

extension Application.Root {
    /// A violation of the set-once composition-root contract.
    public typealias Error = __ApplicationRootError
}
