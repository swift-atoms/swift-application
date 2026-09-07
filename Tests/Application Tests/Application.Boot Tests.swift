import Application
import Synchronization
import Testing

extension Application.Boot.`Boot constructs and registers application roots`.Tally {
    func increment() {
        count.withLock { $0 += 1 }
    }

    var total: Int {
        count.withLock { $0 }
    }
}

extension Application.Boot {
    @Suite
    struct `Boot constructs and registers application roots` {

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

        @Suite struct `Plans construct before registration` {
            @Test func `the phases are ordered construction before registration`() {
                #expect(Application.Boot.Phase.construction < Application.Boot.Phase.registration)
                #expect(Application.Boot.Phase.allCases == [.construction, .registration])
            }

            @Test func `a plan yields a root already in the registered state`() throws {
                let plan = Application.Boot.Plan<
                    Application.Boot.`Boot constructs and registers application roots`.Resource,
                    Application.Boot.`Boot constructs and registers application roots`.Composed,
                    Never
                >(
                    construct: { Application.Boot.`Boot constructs and registers application roots`.Resource(label: "production") },
                    compose: { Application.Boot.`Boot constructs and registers application roots`.Composed(label: $0.label) }
                )

                let root = plan()
                let resolved = try root.resolve()

                #expect(root.isRegistered)
                #expect(resolved == Application.Boot.`Boot constructs and registers application roots`.Composed(label: "production"))
            }

            @Test func `a plan runs the construction phase exactly once`() {
                let tally = Application.Boot.`Boot constructs and registers application roots`.Tally()
                let plan = Application.Boot.Plan<
                    Application.Boot.`Boot constructs and registers application roots`.Resource,
                    Application.Boot.`Boot constructs and registers application roots`.Composed,
                    Never
                >(
                    construct: {
                        tally.increment()
                        return Application.Boot.`Boot constructs and registers application roots`.Resource(label: "production")
                    },
                    compose: { Application.Boot.`Boot constructs and registers application roots`.Composed(label: $0.label) }
                )

                _ = plan()

                #expect(tally.total == 1)
            }

            @Test func `composition follows construction exactly once per invocation`() throws {
                let construction = Application.Boot.`Boot constructs and registers application roots`.Tally()
                let composition = Application.Boot.`Boot constructs and registers application roots`.Tally()
                let plan = Application.Boot.Plan<Int, Int, Never>(
                    construct: {
                        construction.increment()
                        return construction.total
                    },
                    compose: { resource in
                        #expect(construction.total == resource)
                        #expect(composition.total == resource - 1)
                        composition.increment()
                        return resource
                    }
                )

                let first = plan()
                let second = plan()

                #expect(construction.total == 2)
                #expect(composition.total == 2)
                #expect(try first.resolve() == 1)
                #expect(try second.resolve() == 2)
            }

            @Test func `a plan composing nil still registers its root`() throws {
                let plan = Application.Boot.Plan<Int, Int?, Never>(
                    construct: { 7 },
                    compose: { _ in nil }
                )

                var root = plan()

                #expect(root.isRegistered)
                #expect(root.state == .registered(nil))
                #expect(try root.resolve() == nil)
                #expect(throws: Application.Root<Int?>.Error.alreadyRegistered) {
                    try root.register(8)
                }
            }

            @Test func `a failing construction phase raises its own error type`() {
                let plan = Application.Boot.Plan<
                    Application.Boot.`Boot constructs and registers application roots`.Resource,
                    Application.Boot.`Boot constructs and registers application roots`.Composed,
                    Application.Boot.`Boot constructs and registers application roots`.Failure
                >(

                    construct: {
                        () throws(Application.Boot.`Boot constructs and registers application roots`.Failure)
                            -> Application.Boot.`Boot constructs and registers application roots`.Resource in
                        throw Application.Boot.`Boot constructs and registers application roots`.Failure.unavailable
                    },
                    compose: { Application.Boot.`Boot constructs and registers application roots`.Composed(label: $0.label) }
                )

                #expect(throws: Application.Boot.`Boot constructs and registers application roots`.Failure.unavailable) {
                    try plan()
                }
            }
        }

        @Suite struct `Construction failure and repeated execution preserve phase boundaries` {
            @Test func `a failed construction registers nothing`() {
                let tally = Application.Boot.`Boot constructs and registers application roots`.Tally()
                let plan = Application.Boot.Plan<
                    Application.Boot.`Boot constructs and registers application roots`.Resource,
                    Application.Boot.`Boot constructs and registers application roots`.Composed,
                    Application.Boot.`Boot constructs and registers application roots`.Failure
                >(
                    construct: {
                        () throws(Application.Boot.`Boot constructs and registers application roots`.Failure)
                            -> Application.Boot.`Boot constructs and registers application roots`.Resource in
                        throw Application.Boot.`Boot constructs and registers application roots`.Failure.unavailable
                    },
                    compose: {
                        tally.increment()
                        return Application.Boot.`Boot constructs and registers application roots`.Composed(label: $0.label)
                    }
                )

                do throws(Application.Boot.`Boot constructs and registers application roots`.Failure) {
                    _ = try plan()
                } catch {}

                #expect(tally.total == 0)
            }

            @Test func `each run of a plan constructs its own resources`() {
                let tally = Application.Boot.`Boot constructs and registers application roots`.Tally()
                let plan = Application.Boot.Plan<
                    Application.Boot.`Boot constructs and registers application roots`.Resource,
                    Application.Boot.`Boot constructs and registers application roots`.Composed,
                    Never
                >(
                    construct: {
                        tally.increment()
                        return Application.Boot.`Boot constructs and registers application roots`.Resource(label: "production")
                    },
                    compose: { Application.Boot.`Boot constructs and registers application roots`.Composed(label: $0.label) }
                )

                _ = plan()
                _ = plan()

                #expect(tally.total == 2)
            }
        }

        @Suite struct `Booted roots resolve through boundaries` {
            @Test func `a booted root resolves at every boundary`() throws {
                let plan = Application.Boot.Plan<
                    Application.Boot.`Boot constructs and registers application roots`.Resource,
                    Application.Boot.`Boot constructs and registers application roots`.Composed,
                    Never
                >(
                    construct: { Application.Boot.`Boot constructs and registers application roots`.Resource(label: "production") },
                    compose: { Application.Boot.`Boot constructs and registers application roots`.Composed(label: $0.label) }
                )

                let root = plan()
                let table = Application.Boundary.Table.reapplied
                let expected = Application.Boot.`Boot constructs and registers application roots`.Composed(label: "production")

                for boundary in Application.Boundary.allCases {
                    let resolution = try root.resolve(at: boundary, using: table)

                    #expect(resolution.disposition == .reapplied)
                    #expect(resolution.value == expected)
                }
            }
        }
    }
}
