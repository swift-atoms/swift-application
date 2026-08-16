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

import Application_Primitives
import Testing

extension Application.Boundary {
    @Suite("Application.Boundary")
    struct Test {
        @Suite struct Unit {
            @Test func `a uniform table assigns its disposition to every boundary`() {
                for disposition in Application.Boundary.Disposition.allCases {
                    let table = Application.Boundary.Table.uniform(disposition)

                    for boundary in Application.Boundary.allCases {
                        #expect(table[boundary] == disposition)
                    }
                }
            }

            @Test func `the presets are the uniform tables`() {
                #expect(Application.Boundary.Table.inherited == .uniform(.inherited))
                #expect(Application.Boundary.Table.reapplied == .uniform(.reapplied))
            }

            @Test func `assigning a boundary changes that boundary and no other`() {
                for assigned in Application.Boundary.allCases {
                    var table = Application.Boundary.Table.inherited
                    table[assigned] = .reapplied

                    for boundary in Application.Boundary.allCases {
                        let expected: Application.Boundary.Disposition =
                            boundary == assigned ? .reapplied : .inherited
                        #expect(table[boundary] == expected)
                    }
                }
            }

            @Test func `the dispositions partition every boundary`() {
                var table = Application.Boundary.Table.inherited
                table[.job] = .reapplied

                let inherited = table.boundaries(.inherited)
                let reapplied = table.boundaries(.reapplied)

                #expect(reapplied == [.job])
                #expect(inherited.count + reapplied.count == Application.Boundary.allCases.count)
                #expect(!inherited.contains(.job))
            }
        }

        @Suite struct `Edge Case` {
            @Test func `a table is total over the boundary vocabulary`() {
                // Totality is the reason the table is stored rather than mapped:
                // reading it can never miss a boundary, so no boundary can silently
                // go unhandled. This test fails by construction the moment a case is
                // added to `Application.Boundary` without a stored counterpart.
                let table = Application.Boundary.Table(
                    request: .inherited,
                    scene: .inherited,
                    task: .reapplied,
                    job: .reapplied,
                    shutdown: .inherited
                )

                #expect(Application.Boundary.allCases.count == 5)
                #expect(
                    table.boundaries(.inherited).count + table.boundaries(.reapplied).count == 5
                )
            }

            @Test func `a table assigning every boundary the same way has one partition`() {
                let table = Application.Boundary.Table.reapplied

                #expect(table.boundaries(.inherited).isEmpty)
                #expect(table.boundaries(.reapplied) == Application.Boundary.allCases)
            }
        }

        @Suite struct Integration {}
    }
}
