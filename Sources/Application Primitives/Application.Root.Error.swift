@frozen
public enum __ApplicationRootError: Swift.Error, Sendable, Hashable {

    case alreadyRegistered

    case notRegistered
}

extension Application.Root {

    public typealias Error = __ApplicationRootError
}
