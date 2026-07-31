# ``Application_Primitives``

@Metadata {
    @DisplayName("Application Primitives")
    @TitleHeading("Swift Primitives")
}

The application-as-value algebra: a set-once composition root, a total boundary
table, and a two-phase boot, stated as types and free of any engine.

## Overview

An application is a value. It is composed once — explicitly, from resources the
process constructed rather than discovered — and every execution boundary the
runtime afterwards opens resolves that same composition root.

This package states that idea and stops there. It has no dependencies, performs no
work, and knows nothing about servers, scenes, transports, or platforms. What it
owns is the vocabulary a runtime has to satisfy, and the invariants a runtime can
get wrong.

## Topics

### The composition root

- ``Application/Root``
- ``Application/Root/State``
- ``Application/Root/Error``

### Execution boundaries

- ``Application/Boundary``
- ``Application/Boundary/Disposition``
- ``Application/Boundary/Table``
- ``Application/Resolution``

### Boot

- ``Application/Boot``
- ``Application/Boot/Phase``
- ``Application/Boot/Plan``
