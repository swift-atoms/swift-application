extension Application {

    @frozen
    public enum Boundary: Sendable, Hashable, CaseIterable {

        case request

        case scene

        case task

        case job

        case shutdown
    }
}
