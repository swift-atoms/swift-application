import Application_Primitives
import Synchronization
import Testing

extension Application.Boot.Test.Tally {
    func increment() {
        count.withLock { $0 += 1 }
    }

    var total: Int {
        count.withLock { $0 }
    }
}

extension Application.Boot {
    @Suite("Application.Boot")
    struct Test {

        struct Resource: Sendable, Equatable {
            var label: String
        }

        struct Composed: Sendable, Equatable {
            var label: String
        }

        enum Failure: Swift.Error, Equatable {
            case unavailable
        }

        final class Tally: Sendable {
            let count = Mutex(0)
        }

        @Suite struct Unit {
            @Test func `the phases are ordered construction before registration`() {
                #expect(Application.Boot.Phase.construction < Application.Boot.Phase.registration)
                #expect(Application.Boot.Phase.allCases == [.construction, .registration])
            }

            @Test func `a plan yields a root already in the registered state`() throws {
                let plan = Application.Boot.Plan<
                    Application.Boot.Test.Resource,
                    Application.Boot.Test.Composed,
                    Never
                >(
                    construct: { Application.Boot.Test.Resource(label: "production") },
                    compose: { Application.Boot.Test.Composed(label: $0.label) }
                )

                let root = plan()
                let resolved = try root.resolve()

                #expect(root.isRegistered)
                #expect(resolved == Application.Boot.Test.Composed(label: "production"))
            }

            @Test func `a plan runs the construction phase exactly once`() {
                let tally = Application.Boot.Test.Tally()
                let plan = Application.Boot.Plan<
                    Application.Boot.Test.Resource,
                    Application.Boot.Test.Composed,
                    Never
                >(
                    construct: {
                        tally.increment()
                        return Application.Boot.Test.Resource(label: "production")
                    },
                    compose: { Application.Boot.Test.Composed(label: $0.label) }
                )

                _ = plan()

                #expect(tally.total == 1)
            }

            @Test func `a failing construction phase raises its own error type`() {
                let plan = Application.Boot.Plan<
                    Application.Boot.Test.Resource,
                    Application.Boot.Test.Composed,
                    Application.Boot.Test.Failure
                >(

                    construct: {
                        () throws(Application.Boot.Test.Failure)
                            -> Application.Boot.Test.Resource in
                        throw Application.Boot.Test.Failure.unavailable
                    },
                    compose: { Application.Boot.Test.Composed(label: $0.label) }
                )

                #expect(throws: Application.Boot.Test.Failure.unavailable) {
                    try plan()
                }
            }
        }

        @Suite struct `Edge Case` {
            @Test func `a failed construction registers nothing`() {
                let tally = Application.Boot.Test.Tally()
                let plan = Application.Boot.Plan<
                    Application.Boot.Test.Resource,
                    Application.Boot.Test.Composed,
                    Application.Boot.Test.Failure
                >(
                    construct: {
                        () throws(Application.Boot.Test.Failure)
                            -> Application.Boot.Test.Resource in
                        throw Application.Boot.Test.Failure.unavailable
                    },
                    compose: {
                        tally.increment()
                        return Application.Boot.Test.Composed(label: $0.label)
                    }
                )

                do throws(Application.Boot.Test.Failure) {
                    _ = try plan()
                } catch {}

                #expect(tally.total == 0)
            }

            @Test func `each run of a plan constructs its own resources`() {
                let tally = Application.Boot.Test.Tally()
                let plan = Application.Boot.Plan<
                    Application.Boot.Test.Resource,
                    Application.Boot.Test.Composed,
                    Never
                >(
                    construct: {
                        tally.increment()
                        return Application.Boot.Test.Resource(label: "production")
                    },
                    compose: { Application.Boot.Test.Composed(label: $0.label) }
                )

                _ = plan()
                _ = plan()

                #expect(tally.total == 2)
            }
        }

        @Suite struct Integration {
            @Test func `a booted root resolves at every boundary`() throws {
                let plan = Application.Boot.Plan<
                    Application.Boot.Test.Resource,
                    Application.Boot.Test.Composed,
                    Never
                >(
                    construct: { Application.Boot.Test.Resource(label: "production") },
                    compose: { Application.Boot.Test.Composed(label: $0.label) }
                )

                let root = plan()
                let table = Application.Boundary.Table.reapplied
                let expected = Application.Boot.Test.Composed(label: "production")

                for boundary in Application.Boundary.allCases {
                    let resolution = try root.resolve(at: boundary, using: table)

                    #expect(resolution.disposition == .reapplied)
                    #expect(resolution.value == expected)
                }
            }
        }
    }
}
