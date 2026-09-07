extension Application.Root {

    @frozen
    public enum State: Sendable {

        case unset

        case registered(Value)
    }
}

extension Application.Root.State: Swift.Equatable where Value: Swift.Equatable {}

extension Application.Root.State: Swift.Hashable where Value: Swift.Hashable {}
