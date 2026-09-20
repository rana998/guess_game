# guessGame

## Project Overview

guessGame (product name **تخمين**) is a SwiftUI party game for iOS: a picture-description guessing game for 3–6 players, each on their own device. The Xcode project is generated via XcodeGen from `project.yml` (the source of truth — never edit `guessGame.xcodeproj` directly). It's built as a strict Clean Architecture with three layers — Presentation, Domain, and Data — organized within a single Xcode target; only the Presentation layer is populated so far (Home screen + placeholder navigation), with Domain/Data waiting on the first real use case (room creation, gameplay, etc.) in a later phase.

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
| Design tokens & reusable UI components | Presentation | `Presentation/DesignSystem` |
| Navigation destinations | Presentation | `Presentation/Navigation` |

`Domain/` and `Data/` currently contain no files — the app's only screens so far (Home and its placeholder destinations) have no business logic or external data dependency. This is deliberate and temporary, not an oversight, mirroring how earlier limitations were flagged rather than left silent (see Non-Goals below). The first real use case (e.g. room creation) will re-populate both folders following this table.

## Folder Structure

```
guessGame/
├── project.yml                  # XcodeGen project spec — source of truth for the .xcodeproj
├── .gitignore
├── CLAUDE.md
├── DESIGN_SYSTEM.md
├── guessGame/                   # App target
│   ├── App/                     # Composition root
│   │   └── guessGameApp.swift
│   ├── Domain/                  # (empty — no use case exists yet)
│   ├── Data/                    # (empty — no repository/data source exists yet)
│   ├── Presentation/
│   │   ├── Views/
│   │   │   ├── HomeView.swift           # App entry point
│   │   │   ├── CreateRoomView.swift     # Placeholder — no room logic yet
│   │   │   ├── JoinRoomView.swift       # Placeholder — no room logic yet
│   │   │   ├── HomeSettingView.swift    # Settings (UI-only toggles), landscape 852×393 Figma spec
│   │   │   └── HowPlayView.swift        # Placeholder
│   │   ├── Navigation/
│   │   │   └── HomeDestination.swift    # Hashable enum for Home's NavigationStack
│   │   └── DesignSystem/
│   │       ├── Color+DesignSystem.swift
│   │       ├── Font+DesignSystem.swift
│   │       ├── Strings.swift            # Hardcoded Arabic strings, namespaced per screen
│   │       ├── AppButtonStyle.swift     # Primary/secondary/tertiary-dashed button styles
│   │       ├── RoundedChevronButton.swift # 44pt yellow rounded-square back button (HomeSettingView)
│   │       ├── SettingsRowToggleStyle.swift # Full-row toggle with 64×28pt custom switch (HomeSettingView)
│   │       ├── ComicOutlineText.swift   # Stroked-text technique for the wordmark
│   │       ├── StarburstLogo.swift      # Real PNG starburst asset (Image("starburst"), template-tinted shadow copy) + wordmark lockup, GeometryReader-proportional layout
│   │       └── PlaceholderDestinationView.swift
│   ├── Resources/
│   │   └── Fonts/                # Bundled Almarai .ttf weights (Light/Regular/Bold/ExtraBold)
│   └── Assets.xcassets/          # App icon, accent color, design-system colors, badge icons
└── guessGameTests/
    └── PlaceholderTests.swift    # Keeps the target buildable; no Domain logic exists yet
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

`guessGameApp.swift` is the composition root. It currently wires nothing from Domain/Data (both are empty — see Architecture above); its content today is the app-wide RTL setup: forcing `UIView.appearance().semanticContentAttribute = .forceRightToLeft` in `init()` (so UIKit-backed chrome like `NavigationStack`'s back-chevron placement mirrors correctly) and applying `.environment(\.layoutDirection, .rightToLeft)` to the root view. `HomeView` has no ViewModel — it owns its own `NavigationStack` and push-navigation state directly via `@State private var path: [HomeDestination]`, since it has no business logic to separate out.

## Testing Strategy

XCTest only (not Swift Testing) per project convention. There is currently no logic-bearing Domain code to test — `guessGameTests/PlaceholderTests.swift` exists solely to keep the test target buildable and should be removed once the first real use case (and its real tests) ships. `HomeView` and its placeholder destinations are pure declarative SwiftUI with no logic to assert, so they're intentionally untested; `Font+DesignSystem`/`Color+DesignSystem` are trivial accessors wrapping platform APIs, also intentionally untested.

## Design System

See [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) for the full visual design system — colors, typography, spacing, and Apple HIG compliance rules. Follow it for every UI/frontend task; treat it as the source of truth over any values inferred from mockup images or screenshots. Token helpers live in `Presentation/DesignSystem/`. Note: DESIGN_SYSTEM.md's single `Ink/Stroke & Ink/Text` token was split into two color assets, `InkStroke` and `InkText` — identical in Light Mode, but `InkStroke` stays dark in Dark Mode (it's a comic-outline color around shapes) while `InkText` inverts to a warm off-white (it's body/label text color and needs contrast against the dark Paper background).

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
- Placeholder app icon with no artwork yet (a missing-icon build warning is expected).
- Swift 5 language mode, not Swift 6 strict concurrency.
- iPhone-only device family.
- Adaptive across portrait and landscape on all supported iPhone sizes — `HomeView` picks its arrangement live from a `GeometryReader` width-vs-height comparison (no fixed device breakpoints). `Home.png` remains the pixel-exact reference for the landscape composition only; the portrait arrangement is a proportional reflow of the same elements (not a separately designed screen), and DESIGN_SYSTEM.md's landscape safe-area rule still applies whenever the device is in landscape.
- No real room/networking logic yet — Create Room, Join Room, and How to Play are UI-only placeholders that push to empty stub screens. See `/Users/rana/Desktop/Takhmeen Handoff Plan.pdf` for the planned full screen flow and the future `roomState`/`roundState` networking contract.
- No `Localizable.strings`/`NSLocalizedString` infrastructure — single hardcoded Arabic language via `Presentation/DesignSystem/Strings.swift`. A future real localization pass is a mechanical extraction from there, not a rewrite.
