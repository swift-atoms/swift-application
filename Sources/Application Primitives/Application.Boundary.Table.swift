extension Application.Boundary {

    @frozen
    public struct Table: Sendable, Hashable {

        public var request: Application.Boundary.Disposition

        public var scene: Application.Boundary.Disposition

        public var task: Application.Boundary.Disposition

        public var job: Application.Boundary.Disposition

        public var shutdown: Application.Boundary.Disposition

        public init(
            request: Application.Boundary.Disposition,
            scene: Application.Boundary.Disposition,
            task: Application.Boundary.Disposition,
            job: Application.Boundary.Disposition,
            shutdown: Application.Boundary.Disposition
        ) {
            self.request = request
            self.scene = scene
            self.task = task
            self.job = job
            self.shutdown = shutdown
        }
    }
}

extension Application.Boundary.Table {

    public static func uniform(_ disposition: Application.Boundary.Disposition) -> Self {
        Self(
            request: disposition,
            scene: disposition,
            task: disposition,
            job: disposition,
            shutdown: disposition
        )
    }

    public static var inherited: Self {
        .uniform(.inherited)
    }

    public static var reapplied: Self {
        .uniform(.reapplied)
    }
}

extension Application.Boundary.Table {

    public subscript(boundary: Application.Boundary) -> Application.Boundary.Disposition {
        get {
            switch boundary {
            case .request: request
            case .scene: scene
            case .task: task
            case .job: job
            case .shutdown: shutdown
            }
        }
        set {
            switch boundary {
            case .request: request = newValue
            case .scene: scene = newValue
            case .task: task = newValue
            case .job: job = newValue
            case .shutdown: shutdown = newValue
            }
        }
    }

    public func boundaries(
        _ disposition: Application.Boundary.Disposition
    ) -> [Application.Boundary] {
        Application.Boundary.allCases.filter { self[$0] == disposition }
    }
}
