# guessGame

## Project Overview

guessGame is a SwiftUI number-guessing game for iOS. The Xcode project is generated via XcodeGen from `project.yml` (the source of truth — never edit `guessGame.xcodeproj` directly). It exists to demonstrate a strict Clean Architecture with three layers — Presentation, Domain, and Data — organized within a single Xcode target.

## Architecture

The dependency rule is: **Presentation → Domain ← Data**. Domain never depends on Presentation or Data; both Presentation and Data depend inward on Domain, never on each other directly.

All three layers live in **one Xcode target/module** (`guessGame`) — there are no separate frameworks or Swift packages per layer, and therefore no cross-layer `import` statements exist to enforce the boundary at compile time. The boundary is enforced instead by **folder structure and code-review convention**: Domain-layer files must never reference `SwiftUI` or any type declared under `Data/` or `Presentation/`.

| Kind of code | Layer | Folder |
|---|---|---|
| SwiftUI Views | Presentation | `Presentation/Views` |
| ViewModels (`@Observable`) | Presentation | `Presentation/ViewModels` |
| Business entities (structs/enums) | Domain | `Domain/Entities` |
| Use cases (business rules) | Domain | `Domain/UseCases` |
| Repository protocols | Domain | `Domain/Repositories` |
| Repository implementations | Data | `Data/Repositories` |
| Data sources (in-memory, network, disk, ...) | Data | `Data/DataSources` |
| Dependency wiring | App (composition root) | `App/guessGameApp.swift` |

Not every use case needs a repository dependency. `MakeGuessUseCase` is deliberately pure (no repository) because evaluating a guess against an already-known target is pure logic; `StartGameUseCase` needs `GameRepository` because it must obtain a new random number from outside the Domain layer. A use case depends on a repository only when it needs data or a side effect from outside Domain.

## Folder Structure

```
guessGame/
├── project.yml                  # XcodeGen project spec — source of truth for the .xcodeproj
├── .gitignore
├── CLAUDE.md
├── guessGame/                   # App target: all three Clean Architecture layers
│   ├── App/                     # Composition root — wires concrete types together
│   │   └── guessGameApp.swift
│   ├── Domain/                  # Business entities, use cases, repository protocols — no outward deps
│   │   ├── Entities/
│   │   │   ├── GameSession.swift
│   │   │   └── GuessOutcome.swift
│   │   ├── UseCases/
│   │   │   ├── StartGameUseCase.swift
│   │   │   ├── StartGameUseCaseImpl.swift
│   │   │   ├── MakeGuessUseCase.swift
│   │   │   └── MakeGuessUseCaseImpl.swift
│   │   └── Repositories/
│   │       └── GameRepository.swift
│   ├── Data/                    # Repository implementations and data sources
│   │   ├── DataSources/
│   │   │   └── InMemoryGameDataSource.swift
│   │   └── Repositories/
│   │       └── GameRepositoryImpl.swift
│   ├── Presentation/            # SwiftUI views and view models
│   │   ├── ViewModels/
│   │   │   └── GameViewModel.swift
│   │   └── Views/
│   │       └── GameView.swift
│   └── Assets.xcassets/         # App icon and accent color
└── guessGameTests/              # XCTest unit tests for the Domain layer
    ├── UseCases/
    │   ├── StartGameUseCaseTests.swift
    │   └── MakeGuessUseCaseTests.swift
    └── Mocks/
        └── MockGameRepository.swift
```

## Coding Conventions

- One type per file; file name matches type name.
- Naming: `XUseCase` (protocol) / `XUseCaseImpl` (concrete); `XRepository` (protocol) / `XRepositoryImpl` (concrete); ViewModels suffixed `ViewModel`; Views suffixed `View`.
- Default `internal` access everywhere (no explicit `public`/`private(set)` unless deliberately restricting visibility within the same type).
- No force unwraps (`!`) or `try!` in shipped code — use `guard`/optional binding.
- Comments only explain non-obvious "why," never restate "what" the code does.
- Domain entities are value types (`struct`/`enum`); classes are reserved for reference-semantic objects (ViewModels, repository/data-source implementations).
- Swift language mode 5 (not Swift 6 strict concurrency) — a deliberate, documented scaffold choice; upgrading is a valid future task, not an oversight.

## Build/Run/Test Commands

```bash
# Regenerate the .xcodeproj after any project.yml change
xcodegen generate

# Discover available simulator destinations on this machine
xcodebuild -showdestinations -project guessGame.xcodeproj -scheme guessGame

# Build (generic simulator platform — no specific device needed just to compile)
xcodebuild -project guessGame.xcodeproj -scheme guessGame -destination 'generic/platform=iOS Simulator' build

# Run tests (substitute the device name from -showdestinations if 'iPhone 16' isn't available)
xcodebuild -project guessGame.xcodeproj -scheme guessGame -destination 'platform=iOS Simulator,name=iPhone 16' test

# Clean
xcodebuild -project guessGame.xcodeproj -scheme guessGame clean
```

After regenerating, open `guessGame.xcodeproj` in Xcode to run the app in the Simulator via the Run button.

## Dependency Injection

`guessGameApp.swift` is the sole composition root — the only file that constructs concrete types from all three layers. `GameView` receives its already-built `GameViewModel` via `init`, held in `@State` (this mirrors `@StateObject`'s once-only seeding behavior for `ObservableObject`, but for `@Observable` reference types). `$viewModel.property` bindings work directly through `@State` without needing `@Bindable` in this configuration.

## Testing Strategy

XCTest only (not Swift Testing) per project convention. The Domain layer has full coverage via `guessGameTests`:

- `StartGameUseCaseTests` — uses `MockGameRepository` to verify the session is built with the repository's target, starts with zero attempts and not finished, and that the requested range is passed through correctly.
- `MakeGuessUseCaseTests` — no mock needed since `MakeGuessUseCaseImpl` is pure logic; verifies too-low/too-high/correct outcomes, that a correct guess marks the session finished, that every guess increments the attempt count, and that an incorrect guess leaves the session unfinished.

## Multi-Agent Workflow Rule (Binding)

> All future non-trivial work on this project follows a 3-agent process:
> 1. **Planner** drafts an implementation plan (scope, files, architecture impact, open questions) but does not write code.
> 2. **Reviewer** critiques the plan, resolves every open question with an explicit decision, checks technical correctness, and outputs one FINAL REFINED PLAN — no unresolved questions are left for the Builder.
> 3. **Builder** implements the FINAL REFINED PLAN literally: writes/edits files, runs builds and tests, and reports results. The Builder does not re-litigate settled plan decisions.
>
> This rule was established during the initial scaffold of this project and applies to all subsequent features, refactors, and fixes, unless the user explicitly says otherwise.

## Git Workflow (Binding)

This project is connected to GitHub at `https://github.com/rana998/guess_game.git` (remote `origin`, branch `main`).

- **Auto-push rule**: after finishing any prompt/task in this project, always commit and push the resulting changes to `origin main` automatically — never wait to be asked separately. If a task produces no file changes, there is nothing to commit; skip silently.
- **Commit message style**: short, clear, written in English, explaining *what* changed and *why* — not just what.
- **Multiple meaningful commits**: split each task's work into logical, self-contained commits rather than one giant commit. Each commit should represent one clear change (e.g. a new use case, a UI change, a config update, a docs update) that could be understood and reverted independently.
- **No attribution lines, ever**: never include a `Co-Authored-By: Claude ...` line, a `Claude-Session:` link, a "Generated with Claude Code" line, or any other co-author/attribution trailer in any commit message or PR description, in this repo or any other. No exceptions. This is enforced via `.claude/settings.json` in this repo (`attribution.commit`, `attribution.pr` set to `""`, `attribution.sessionUrl` set to `false`) — do not remove or override that config.

## Non-Goals / Current Limitations

- Code signing disabled (not directly device-deployable without adding a Developer Team later).
- In-memory game state only, no persistence.
- Placeholder app icon with no artwork yet (a missing-icon build warning is expected).
- Swift 5 language mode, not Swift 6 strict concurrency.
- iPhone-only device family.
