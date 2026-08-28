extension Application.Root {

    @frozen
    public enum State: Sendable {

        case unset

        case registered(Value)
    }
}

extension Application.Root.State: Equatable where Value: Equatable {}
extension Application.Root.State: Hashable where Value: Hashable {}
