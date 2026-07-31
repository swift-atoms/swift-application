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
    /// An execution boundary a runtime opens.
    ///
    /// A boundary is a place where the runtime begins doing work that was not
    /// already in flight. Every boundary must obtain the composition root, and the
    /// vocabulary exists so that a runtime can be asked, exhaustively, how each of
    /// its boundaries does so — see ``Application/Boundary/Table``.
    ///
    /// The set is closed on purpose. These are the boundaries a runtime opens, not
    /// the operations an application performs: a route handler is work *inside* the
    /// ``request`` boundary, not a boundary of its own.
    @frozen
    public enum Boundary: Sendable, Hashable, CaseIterable {
        /// An inbound request the application serves.
        case request

        /// A scene launch on a client platform.
        case scene

        /// Background work started outside any inbound boundary.
        case task

        /// A scheduled or queued job.
        case job

        /// The terminal boundary, opened once as the process winds down.
        case shutdown
    }
}
