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
    /// The composition root: a set-once cell holding everything the application was
    /// composed from.
    ///
    /// The root is registered exactly once, during boot, and resolved thereafter at
    /// every execution boundary. The two failures the contract admits are stated as
    /// errors rather than as representable states: registering a root that is
    /// already registered, and resolving one that is not.
    ///
    /// `Value` is deliberately opaque. The algebra says when a root may be
    /// registered and what resolution yields; it says nothing about what a root
    /// contains.
    ///
    /// ```swift
    /// var root = Application.Root<Int>.unset
    /// try root.register(1)
    /// #expect(try root.resolve() == 1)
    /// ```
    @frozen
    public struct Root<Value: Sendable>: Sendable {
        /// Whether the root has been registered, and with what.
        public var state: Application.Root<Value>.State

        /// Creates a root in `state`.
        public init(state: Application.Root<Value>.State) {
            self.state = state
        }
    }
}

// MARK: - Construction

extension Application.Root {
    /// A root that has not been registered.
    public static var unset: Self {
        Self(state: .unset)
    }

    /// A root already carrying `value`.
    ///
    /// This is the state a completed boot leaves behind, and the only way to obtain
    /// a registered root without going through ``register(_:)``.
    public static func registered(_ value: Value) -> Self {
        Self(state: .registered(value))
    }
}

// MARK: - Registration

extension Application.Root {
    /// Whether a value has been registered.
    public var isRegistered: Bool {
        switch state {
        case .unset: false
        case .registered: true
        }
    }

    /// Registers `value` as the composition root.
    ///
    /// - Throws: ``Application/Root/Error/alreadyRegistered`` when a value is
    ///   already registered. Set-once is the whole contract: a second registration
    ///   is a defect in the boot sequence, never a re-configuration.
    public mutating func register(_ value: Value) throws(Application.Root<Value>.Error) {
        guard case .unset = state else { throw .alreadyRegistered }
        state = .registered(value)
    }
}

// MARK: - Resolution

extension Application.Root {
    /// The registered value.
    ///
    /// - Throws: ``Application/Root/Error/notRegistered`` when no value has been
    ///   registered yet, which means a boundary opened before boot completed.
    public func resolve() throws(Application.Root<Value>.Error) -> Value {
        guard case .registered(let value) = state else { throw .notRegistered }
        return value
    }

    /// The registered value as obtained at `boundary` under `table`.
    ///
    /// This is the re-application invariant made into an operation: the disposition
    /// records *how* the boundary obtained the root — by inheriting the scope that
    /// already carried it, or by re-applying it — and the value is the registered
    /// value either way. A boundary can differ in its disposition; it can never
    /// differ in what it resolves.
    ///
    /// - Throws: ``Application/Root/Error/notRegistered`` when no value has been
    ///   registered yet.
    public func resolve(
        at boundary: Application.Boundary,
        using table: Application.Boundary.Table
    ) throws(Application.Root<Value>.Error) -> Application.Resolution<Value> {
        Application.Resolution(
            boundary: boundary,
            disposition: table[boundary],
            value: try resolve()
        )
    }
}

// MARK: - Conditional Conformances

extension Application.Root: Equatable where Value: Equatable {}
extension Application.Root: Hashable where Value: Hashable {}
