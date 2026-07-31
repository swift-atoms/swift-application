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

/// Namespace for the application-as-value algebra.
///
/// An application is a value: a composition root, plus the rule by which every
/// execution boundary the runtime opens obtains that root. This namespace states
/// that idea as types and says nothing about how a process runs — no engine, no
/// transport, no platform.
///
/// ## The algebra
///
/// - ``Application/Root`` is a set-once cell. It is registered exactly once and
///   resolved thereafter; registering twice and resolving before registration are
///   both errors rather than representable states.
/// - ``Application/Boundary`` enumerates the execution boundaries a runtime opens,
///   and ``Application/Boundary/Table`` assigns each boundary a
///   ``Application/Boundary/Disposition``: the boundary either *inherits* the scope
///   that already carries the root, or *re-applies* the root because it starts
///   outside that scope.
/// - ``Application/Resolution`` is the root as obtained at one boundary. Its
///   existence is the re-application invariant: whichever disposition a boundary
///   has, it resolves to the same registered value.
/// - ``Application/Boot`` states the two-phase boot shape — construct process
///   resources explicitly, then compose and register them — as a value that cannot
///   perform the phases out of order.
///
/// ## Example
///
/// ```swift
/// struct Resources: Sendable { var greeting: String }
/// struct Root: Sendable { var greeting: String }
///
/// let plan = Application.Boot.Plan<Resources, Root, Never>(
///     construct: { Resources(greeting: "hello") },
///     compose: { Root(greeting: $0.greeting) }
/// )
///
/// let root = plan()
/// let table = Application.Boundary.Table.uniform(.inherited)
/// let resolution = try root.resolve(at: .request, using: table)
/// // resolution.value.greeting == "hello"
/// ```
public enum Application {}
