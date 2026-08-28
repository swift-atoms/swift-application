import Application
import Testing

@Suite
struct `Resolution Tests` {
    @Suite struct Unit {
        @Test func `a resolution records the boundary and disposition it was obtained under`() {
            let resolution = Application.Resolution(
                boundary: .job,
                disposition: .reapplied,
                value: 7
            )

            #expect(resolution.boundary == .job)
            #expect(resolution.disposition == .reapplied)
            #expect(resolution.value == 7)
        }

        @Test func `resolutions of one root agree across boundaries and dispositions`() {
            let inherited = Application.Resolution(
                boundary: .request,
                disposition: .inherited,
                value: 7
            )
            let reapplied = Application.Resolution(
                boundary: .job,
                disposition: .reapplied,
                value: 7
            )

            #expect(inherited.agrees(with: reapplied))
        }

        @Test func `resolutions carrying different roots do not agree`() {
            let one = Application.Resolution(boundary: .request, disposition: .inherited, value: 7)
            let other = Application.Resolution(
                boundary: .request,
                disposition: .inherited,
                value: 8
            )

            #expect(!one.agrees(with: other))
        }
    }

    @Suite struct `Edge Case` {
        @Test func `agreement is about the value and equality is about the whole record`() {
            let inherited = Application.Resolution(
                boundary: .request,
                disposition: .inherited,
                value: 7
            )
            let reapplied = Application.Resolution(
                boundary: .job,
                disposition: .reapplied,
                value: 7
            )

            #expect(inherited.agrees(with: reapplied))
            #expect(inherited != reapplied)
        }

        @Test func `a resolution agrees with itself`() {
            let resolution = Application.Resolution(
                boundary: .shutdown,
                disposition: .inherited,
                value: 7
            )

            #expect(resolution.agrees(with: resolution))
        }
    }

    @Suite struct Integration {
        @Test func `every pair of boundary resolutions of one registered root agrees`() throws {
            let root = Application.Root<Int>.registered(7)
            var table = Application.Boundary.Table.inherited
            table[.task] = .reapplied
            table[.job] = .reapplied

            var resolutions: [Application.Resolution<Int>] = []
            for boundary in Application.Boundary.allCases {
                resolutions.append(try root.resolve(at: boundary, using: table))
            }

            for one in resolutions {
                for other in resolutions {
                    #expect(one.agrees(with: other))
                }
            }
        }
    }
}
