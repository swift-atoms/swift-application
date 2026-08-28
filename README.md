# swift-application

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The application-as-value algebra — a set-once composition root, a total boundary table, and a two-phase boot — stated as types, with no dependencies and no engine.

---

## Key Features

- **The application is a value** — an application is a composition root plus the rule by which every execution boundary obtains it. This package owns that vocabulary and nothing else: no server, no scene, no transport, no platform.
- **Set-once by contract** — `Application.Root` is registered exactly once and resolved thereafter. Registering twice and resolving before registration are typed errors, not representable states.
- **A total boundary table** — `Application.Boundary.Table` stores one disposition per boundary, so no boundary can be left unstated. A dictionary would allow an unmentioned boundary, and an unmentioned boundary is precisely the one that silently runs without the root.
- **The re-application invariant as a type** — `Application.Resolution` records *how* a boundary obtained the root while guaranteeing *what* it obtained. Disposition varies; the resolved root does not.
- **Ordering carried by the types** — `Application.Boot.Plan` composes a root only from resources it constructed, and yields a root already registered, so no caller holds one that boot has not finished.
- **Foundation-free and freestanding** — no dependencies at all, no reflection, no `Mutex`, no Objective-C interop. The algebra is what has to survive every deployment target, including Embedded.

---

## Quick Start

An application boots in two phases and then resolves at boundaries. The types carry the ordering, so the sequence cannot be written wrong:

```swift
import Application

struct Resources: Sendable {
    var greeting: String
}

struct Root: Sendable, Equatable {
    var greeting: String
}

// Phase one constructs process resources explicitly; phase two composes them
// into the composition root. `compose` takes a `Resources`, so registration
// cannot precede construction.
let plan = Application.Boot.Plan<Resources, Root, Never>(
    construct: { Resources(greeting: "hello") },
    compose: { Root(greeting: $0.greeting) }
)

// The plan yields a root that is already registered.
let root = plan()

// A runtime states, exhaustively, how each of its boundaries obtains the root.
var table = Application.Boundary.Table.inherited
table[.job] = .reapplied
table[.task] = .reapplied

// Whichever disposition a boundary has, it resolves the same root.
let served = try root.resolve(at: .request, using: table)   // .inherited
let queued = try root.resolve(at: .job, using: table)       // .reapplied
assert(served.agrees(with: queued))
```

Registering twice is rejected, and so is resolving too early:

```swift
var root = Application.Root<Root>.unset

#expect(throws: Application.Root<Root>.Error.notRegistered) { try root.resolve() }

try root.register(Root(greeting: "hello"))

#expect(throws: Application.Root<Root>.Error.alreadyRegistered) {
    try root.register(Root(greeting: "hello again"))
}
```

---

## Installation

No versions are tagged yet; pin to `main`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-atoms/swift-application.git", branch: "main")
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Application", package: "swift-application")
    ]
)
```

Requires Swift 6.3.3. Platform minimums: macOS 26, iOS 26, tvOS 26, watchOS 26, visionOS 26.

---

## Architecture

One library product over a single source module, with no package dependencies.

| Product | When to import |
|---------|----------------|
| `Application` | Stating an application's composition root, boundary table, or boot shape, in library or application code. |

Key types in the `Application` namespace:

| Type | Purpose |
|------|---------|
| `Application.Root` | The set-once composition root; registered once, resolved thereafter. |
| `Application.Root.State` | Whether a root has been registered, and with what. Two cases, no transition out of `registered`. |
| `Application.Root.Error` | The two violations the contract admits: `alreadyRegistered` and `notRegistered`. |
| `Application.Boundary` | The execution boundaries a runtime opens: `request`, `scene`, `task`, `job`, `shutdown`. |
| `Application.Boundary.Disposition` | Whether a boundary inherits the scope carrying the root or re-applies it. |
| `Application.Boundary.Table` | A disposition for every boundary — total by construction. |
| `Application.Resolution` | The root as obtained at one boundary; the re-application invariant made into a record. |
| `Application.Boot` | Namespace for the two-phase boot shape. |
| `Application.Boot.Phase` | `construction` then `registration`, ordered by `Comparable`. |
| `Application.Boot.Plan` | The two phases as a value, yielding a root already registered. |

### Where the runtime lives

This package deliberately performs nothing. It says when a root may be registered, what resolution yields, and which boundaries must account for themselves — not how a process holds the root or scopes it. That is the L3 runtime's job, and keeping the two apart is what lets the algebra stay dependency-free and freestanding while the runtime is free to use whatever the host platform provides.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public release.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE](LICENSE.md).
