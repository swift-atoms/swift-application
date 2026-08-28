extension Application.Boundary {

    @frozen
    public enum Disposition: Sendable, Hashable, CaseIterable {

        case inherited

        case reapplied
    }
}
