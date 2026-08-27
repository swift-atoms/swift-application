extension Application {

    @frozen
    public struct Root<Value: Sendable>: Sendable {

        public private(set) var state: Application.Root<Value>.State

        public init(state: Application.Root<Value>.State) {
            self.state = state
        }
    }
}

extension Application.Root {

    public static var unset: Self {
        Self(state: .unset)
    }

    public static func registered(_ value: Value) -> Self {
        Self(state: .registered(value))
    }
}

extension Application.Root {

    public var isRegistered: Bool {
        switch state {
        case .unset: false
        case .registered: true
        }
    }

    public mutating func register(_ value: Value) throws(Application.Root<Value>.Error) {
        guard case .unset = state else { throw .alreadyRegistered }
        state = .registered(value)
    }
}

extension Application.Root {

    public func resolve() throws(Application.Root<Value>.Error) -> Value {
        guard case .registered(let value) = state else { throw .notRegistered }
        return value
    }

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

extension Application.Root: Equatable where Value: Equatable {}
extension Application.Root: Hashable where Value: Hashable {}
