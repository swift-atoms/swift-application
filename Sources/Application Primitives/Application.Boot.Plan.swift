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
    /// A two-phase boot stated as a value.
    ///
    /// A plan holds the two phases as functions and nothing else: `construct` builds
    /// the process resources, `compose` turns them into the composition root. Since
    /// `compose` takes a `Resources`, the plan cannot register a root it has not
    /// constructed resources for — the ordering is carried by the types rather than
    /// by a convention.
    ///
    /// `Failure` is the construction phase's error type, so a plan whose resources
    /// cannot fail to construct is `Never`-failing and runs without `try`.
    ///
    /// ```swift
    /// let plan = Application.Boot.Plan<Resources, Root, Never>(
    ///     construct: { Resources() },
    ///     compose: { Root(resources: $0) }
    /// )
    /// let root = plan()
    /// ```
    ///
    /// `Resources` is `Sendable` because process resources outlive boot and are
    /// reached from every boundary; a resource that cannot cross an isolation
    /// boundary is not a process resource.
    @frozen
    public struct Plan<Resources: Sendable, Value: Sendable, Failure: Swift.Error>: Sendable {
        /// Phase one: build the process resources explicitly.
        public let construct: @Sendable () throws(Failure) -> Resources

        /// Phase two: compose the constructed resources into the composition root.
        public let compose: @Sendable (Resources) -> Value

        /// Creates a plan from its two phases.
        public init(
            construct: @escaping @Sendable () throws(Failure) -> Resources,
            compose: @escaping @Sendable (Resources) -> Value
        ) {
            self.construct = construct
            self.compose = compose
        }
    }
}

// MARK: - Running

extension Application.Boot.Plan {
    /// Runs both phases and returns the registered composition root.
    ///
    /// The result is a ``Application/Root`` already in
    /// ``Application/Root/State/registered(_:)``, so no caller ever holds a root
    /// that boot has not finished registering.
    ///
    /// - Throws: `Failure`, raised by the construction phase. Composition does not
    ///   fail: by the time resources exist, assembling them into a root is total.
    public func callAsFunction() throws(Failure) -> Application.Root<Value> {
        .registered(compose(try construct()))
    }
}
