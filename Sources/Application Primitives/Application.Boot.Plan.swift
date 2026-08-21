extension Application.Boot {

    @frozen
    public struct Plan<Resources: Sendable, Value: Sendable, Failure: Swift.Error>: Sendable {

        public let construct: @Sendable () throws(Failure) -> Resources

        public let compose: @Sendable (Resources) -> Value

        public init(
            construct: @escaping @Sendable () throws(Failure) -> Resources,
            compose: @escaping @Sendable (Resources) -> Value
        ) {
            self.construct = construct
            self.compose = compose
        }
    }
}

extension Application.Boot.Plan {

    public func callAsFunction() throws(Failure) -> Application.Root<Value> {
        .registered(compose(try construct()))
    }
}
