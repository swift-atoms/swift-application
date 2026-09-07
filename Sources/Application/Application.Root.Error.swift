extension Application.Root {

    @frozen
    public enum Error: Swift.Error, Sendable, Hashable {

        case alreadyRegistered

        case notRegistered
    }
}
