extension Application {

    @frozen
    public struct Resolution<Value: Sendable>: Sendable {

        public let boundary: Application.Boundary

        public let disposition: Application.Boundary.Disposition

        public let value: Value

        public init(
            boundary: Application.Boundary,
            disposition: Application.Boundary.Disposition,
            value: Value
        ) {
            self.boundary = boundary
            self.disposition = disposition
            self.value = value
        }
    }
}

extension Application.Resolution where Value: Equatable {

    public func agrees(with other: Self) -> Bool {
        value == other.value
    }
}

extension Application.Resolution: Equatable where Value: Equatable {}
extension Application.Resolution: Hashable where Value: Hashable {}
