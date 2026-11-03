# swift-application

Use this package when an application composes one root value at startup, registers it once, and then resolves that same value at each boundary where work enters the application: a request, a scene, a task, a job or shutdown. Start from `Application.Boot.Plan` to construct resources and compose the root, `Application.Root` to hold and resolve it, and `Application.Boundary.Table` to record how each boundary treats it. When code instead reads many independent values by key from whatever the current task has bound, use the swift-dependency package.

## Laws

- An `Application.Root` is registered at most once. Any later `register(_:)` fails, even with an equal value, and the first value stays in place. A registered `nil` counts as registered, so an `Application.Root<Int?>` holding `nil` is distinct from an unset root.
- Resolving an unset root fails, at every boundary and under every disposition, and leaves the root unset.
- `Application.Root` is a value: copies of an unset root register independently of each other and of the original.
- Calling an `Application.Boot.Plan` runs `construct` once and then `compose` once on its result, and returns a root that is already registered. Nothing is cached: every call constructs fresh resources. When `construct` throws, its own error reaches the caller, `compose` does not run and no root is produced.
- `Application.Boot.Phase.construction` comes before `Application.Boot.Phase.registration`.
- Resolving at a boundary returns the registered value unchanged, whatever disposition the table assigns there. The disposition is only recorded in the `Application.Resolution`; this package does not inherit or reapply anything itself.
- `Application.Resolution.agrees(with:)` compares values only, so two resolutions of one root agree across boundaries and dispositions; `==` compares the whole record, boundary and disposition included.
- `Application.Boundary.Table.boundaries(_:)` partitions every `Application.Boundary` between the two dispositions, in `Application.Boundary.allCases` order. Assigning one boundary changes no other.
