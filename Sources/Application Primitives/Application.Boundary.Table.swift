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
    /// A disposition for every boundary.
    ///
    /// The table is total by construction: it stores one
    /// ``Application/Boundary/Disposition`` per case of ``Application/Boundary``, so
    /// there is no boundary whose handling was left unstated. A runtime publishes
    /// its table, and that table is the runtime's answer to "how does each of your
    /// boundaries obtain the root?"
    ///
    /// Totality is the point. A dictionary would let a boundary go unmentioned, and
    /// an unmentioned boundary is exactly the one that silently runs without the
    /// root.
    ///
    /// ```swift
    /// var table = Application.Boundary.Table.uniform(.inherited)
    /// table[.job] = .reapplied
    /// ```
    @frozen
    public struct Table: Sendable, Hashable {
        /// How ``Application/Boundary/request`` obtains the root.
        public var request: Application.Boundary.Disposition

        /// How ``Application/Boundary/scene`` obtains the root.
        public var scene: Application.Boundary.Disposition

        /// How ``Application/Boundary/task`` obtains the root.
        public var task: Application.Boundary.Disposition

        /// How ``Application/Boundary/job`` obtains the root.
        public var job: Application.Boundary.Disposition

        /// How ``Application/Boundary/shutdown`` obtains the root.
        public var shutdown: Application.Boundary.Disposition

        /// Creates a table assigning each boundary its disposition.
        public init(
            request: Application.Boundary.Disposition,
            scene: Application.Boundary.Disposition,
            task: Application.Boundary.Disposition,
            job: Application.Boundary.Disposition,
            shutdown: Application.Boundary.Disposition
        ) {
            self.request = request
            self.scene = scene
            self.task = task
            self.job = job
            self.shutdown = shutdown
        }
    }
}

// MARK: - Construction

extension Application.Boundary.Table {
    /// A table assigning `disposition` to every boundary.
    public static func uniform(_ disposition: Application.Boundary.Disposition) -> Self {
        Self(
            request: disposition,
            scene: disposition,
            task: disposition,
            job: disposition,
            shutdown: disposition
        )
    }

    /// A table in which every boundary inherits the root.
    public static var inherited: Self {
        .uniform(.inherited)
    }

    /// A table in which every boundary re-applies the root.
    public static var reapplied: Self {
        .uniform(.reapplied)
    }
}

// MARK: - Access

extension Application.Boundary.Table {
    /// The disposition assigned to `boundary`.
    public subscript(boundary: Application.Boundary) -> Application.Boundary.Disposition {
        get {
            switch boundary {
            case .request: request
            case .scene: scene
            case .task: task
            case .job: job
            case .shutdown: shutdown
            }
        }
        set {
            switch boundary {
            case .request: request = newValue
            case .scene: scene = newValue
            case .task: task = newValue
            case .job: job = newValue
            case .shutdown: shutdown = newValue
            }
        }
    }

    /// The boundaries assigned `disposition`.
    ///
    /// Reading the table the other way round is what a runtime audit wants: which
    /// boundaries have to re-establish the root, and therefore which ones have
    /// somewhere to go wrong.
    public func boundaries(
        _ disposition: Application.Boundary.Disposition
    ) -> [Application.Boundary] {
        Application.Boundary.allCases.filter { self[$0] == disposition }
    }
}
