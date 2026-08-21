extension Application.Boot {

    @frozen
    public enum Phase: Sendable, Hashable, CaseIterable, Comparable {

        case construction

        case registration
    }
}
