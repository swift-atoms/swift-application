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

import Testing

import Application_Primitives

// `Application.Root` is generic, so its suite cannot be an extension of the source
// type: unspecialized, `@Suite` is a hard error in a generic context; specialized,
// the suite compiles and is silently never discovered.
// A backticked suite name is already the display name, so `@Suite` must not also
// be given one.
@Suite
struct `Root Tests` {
    @Suite struct Unit {
        @Test func `an unset root reports it is not registered`() {
            let root = Application.Root<Int>.unset

            #expect(!root.isRegistered)
        }

        @Test func `resolving an unset root reports no root is registered`() {
            let root = Application.Root<Int>.unset

            #expect(throws: Application.Root<Int>.Error.notRegistered) {
                try root.resolve()
            }
        }

        @Test func `registering then resolving yields the registered value`() throws {
            var root = Application.Root<Int>.unset
            try root.register(7)

            #expect(root.isRegistered)
            #expect(try root.resolve() == 7)
        }

        @Test func `registering twice reports the root is already registered`() throws {
            var root = Application.Root<Int>.unset
            try root.register(7)

            #expect(throws: Application.Root<Int>.Error.alreadyRegistered) {
                try root.register(8)
            }
        }

        @Test func `a rejected second registration leaves the first value in place`() throws {
            var root = Application.Root<Int>.unset
            try root.register(7)
            _ = try? root.register(8)

            #expect(try root.resolve() == 7)
        }

        @Test func `the registered constructor produces an already registered root`() throws {
            let root = Application.Root<Int>.registered(7)

            #expect(root.isRegistered)
            #expect(try root.resolve() == 7)
        }
    }

    @Suite struct `Edge Case` {
        @Test func `a root registering an optional value distinguishes none from unset`() throws {
            var root = Application.Root<Int?>.unset
            try root.register(nil)

            // Registering `nil` is a completed registration, not an absent one.
            #expect(root.isRegistered)
            let resolved = try root.resolve()
            #expect(resolved == nil)
        }

        @Test func `registering a second time is rejected even with an equal value`() throws {
            var root = Application.Root<Int>.unset
            try root.register(7)

            // Set-once is about the event, not the value: an idempotent-looking
            // second registration is still a defect in the boot sequence.
            #expect(throws: Application.Root<Int>.Error.alreadyRegistered) {
                try root.register(7)
            }
        }
    }

    @Suite struct Integration {
        @Test func `every boundary resolves the same value whatever its disposition`() throws {
            let root = Application.Root<Int>.registered(7)
            var table = Application.Boundary.Table.inherited
            table[.job] = .reapplied
            table[.task] = .reapplied

            // The per-boundary re-application invariant: disposition varies, the
            // resolved root does not.
            for boundary in Application.Boundary.allCases {
                let resolution = try root.resolve(at: boundary, using: table)

                #expect(resolution.boundary == boundary)
                #expect(resolution.disposition == table[boundary])
                #expect(resolution.value == 7)
            }
        }

        @Test func `resolving at a boundary before registration reports no root`() {
            let root = Application.Root<Int>.unset

            #expect(throws: Application.Root<Int>.Error.notRegistered) {
                try root.resolve(at: .request, using: .inherited)
            }
        }
    }
}
