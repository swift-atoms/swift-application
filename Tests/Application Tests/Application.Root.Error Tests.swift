import Application
import Testing

@Suite struct `Root errors preserve registration contracts` {
    struct Payload: Sendable {
        let value: Int
    }

    @Test func `Different root value types have distinct error types`() {
        #expect(
            ObjectIdentifier(Application.Root<Int>.Error.self)
                != ObjectIdentifier(Application.Root<String>.Error.self)
        )

        let failure: any Swift.Error = Application.Root<Int>.Error.notRegistered
        #expect(failure is Application.Root<Int>.Error)
        #expect(!(failure is Application.Root<String>.Error))
    }

    @Test func `Root errors remain hashable and sendable without equality on the value`() async {
        let root = Application.Root<`Root errors preserve registration contracts`.Payload>.unset
        let failure = await Task.detached {
            () -> Application.Root<`Root errors preserve registration contracts`.Payload>.Error? in
            do throws(Application.Root<`Root errors preserve registration contracts`.Payload>.Error) {
                _ = try root.resolve()
                return nil
            } catch {
                return error
            }
        }.value

        #expect(failure == .notRegistered)
        let failures: Set<Application.Root<`Root errors preserve registration contracts`.Payload>.Error> = [
            .notRegistered, .alreadyRegistered, .notRegistered,
        ]
        #expect(failures.count == 2)
    }

    @Test(arguments: [nil, 7] as [Int?], [false, true])
    func `A registered nil rejects every subsequent registration`(
        replacement: Int?, initialized: Bool
    ) throws {
        var root: Application.Root<Int?>
        if initialized {
            root = Application.Root<Int?>(state: .registered(nil))
        } else {
            root = Application.Root<Int?>(state: .unset)
            try root.register(nil)
        }

        do {
            try root.register(replacement)
            Issue.record("A registered root accepted another value")
        } catch {
            let failure: Application.Root<Int?>.Error = error
            #expect(failure == .alreadyRegistered)
        }

        #expect(root.isRegistered)
        #expect(root.state == .registered(nil))
        #expect(try root.resolve() == nil)
        for boundary in Application.Boundary.allCases {
            let resolution = try root.resolve(at: boundary, using: .reapplied)
            #expect(resolution.value == nil)
        }
    }

    @Test func `Copies of an unset root register independently`() throws {
        let original = Application.Root<Int>.unset
        var first = original
        var second = original

        try first.register(1)
        try second.register(2)

        #expect(original.state == .unset)
        #expect(try first.resolve() == 1)
        #expect(try second.resolve() == 2)
        #expect(throws: Application.Root<Int>.Error.alreadyRegistered) {
            try first.register(3)
        }
        #expect(try second.resolve() == 2)
    }
}
