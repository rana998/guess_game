# guessGame

## Project Overview

guessGame (product name **تخمين**) is a SwiftUI party game for iOS: a picture-description guessing game for 3–6 players, each on their own device. The Xcode project is generated via XcodeGen from `project.yml` (the source of truth — never edit `guessGame.xcodeproj` directly). It's built as a strict Clean Architecture with three layers — Presentation, Domain, and Data — organized within a single Xcode target; Presentation is populated (the Home, Settings, How to Play, Create Room, Join Room and Enter Name screens); Domain holds only the room entities the Enter Name screen needs (`Player`, `Room`, `PlayerColor`, `JoinOutcome`), and Data is still empty, waiting on the first real use case (room creation, joining, gameplay) in a later phase.

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

`Domain/Entities` now holds four pure value types (`PlayerColor`, `Player`, `Room`, `JoinOutcome`) — they import nothing but Foundation, and Presentation maps `PlayerColor` to SwiftUI colors in `PlayerColor+DesignSystem.swift`. There are still no use cases, repositories or `Data/` files: the app's screens are UI-only, with no business logic beyond Join Room's entry rules (a Presentation view-model behind an injectable resolver that returns a `JoinOutcome`) and no external data dependency. That is deliberate and temporary, not an oversight, mirroring how earlier limitations were flagged rather than left silent (see Non-Goals below). The first real use case (e.g. joining a room) will fill in `Domain/UseCases`, `Domain/Repositories` and `Data/` following this table.

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
│   ├── Domain/
│   │   └── Entities/
│   │       ├── PlayerColor.swift    # The six player identity colors in reading order (first = physical right); no SwiftUI
│   │       ├── Player.swift         # id, name, color, isOwner
│   │       ├── Room.swift           # code, capacity, players
│   │       └── JoinOutcome.swift    # joined(Room) / invalidCode / roomFull(capacity:) — what a room-code lookup produces
│   ├── Data/                    # (empty — no repository/data source exists yet)
│   ├── Presentation/
│   │   ├── Views/
│   │   │   ├── HomeView.swift           # App entry point
│   │   │   ├── CreateRoomView.swift     # Room setup screen: name field + avatar badge/swatches, player-count & round-duration pills, create button (UI-only), landscape 852×393 mockup spec
│   │   │   ├── JoinRoomView.swift       # Room-code entry: 4 code boxes + keypad, error banner or room-full card by JoinRoomState, landscape 852×393 mockup spec
│   │   │   ├── EnterNameView.swift      # After a code is accepted: name field + live avatar preview, swatches, enter button, and the players-in-room card, landscape 852×393 mockup spec
│   │   │   ├── HomeSettingView.swift    # Settings (UI-only toggles), landscape 852×393 Figma spec
│   │   │   └── HowPlayView.swift        # Static rules screen: header + 5 InfoCards + points bar, landscape 852×393 mockup spec
│   │   ├── ViewModels/
│   │   │   ├── JoinRoomState.swift      # idle / invalidCode / roomFull(capacity:) — the single enum Join Room's UI follows
│   │   │   ├── JoinRoomViewModel.swift  # @Observable code-entry rules, submit via injectable JoinOutcome resolver (default: every code invalid — no rooms exist yet) and an onJoined closure, per-box styles
│   │   │   └── EnterNameViewModel.swift # @Observable name + color + the room being joined; computed count text, row models, canSubmit
│   │   ├── Samples/
│   │   │   └── Room+Sample.swift        # #if DEBUG example rooms for previews/screenshots only — never the shipping path
│   │   ├── Navigation/
│   │   │   └── HomeDestination.swift    # Hashable enum for Home's NavigationStack (enterName carries the joined Room)
│   │   └── DesignSystem/
│   │       ├── Color+DesignSystem.swift
│   │       ├── Font+DesignSystem.swift
│   │       ├── Strings.swift            # Hardcoded Arabic strings, namespaced per screen
│   │       ├── AppButtonStyle.swift     # Primary/secondary/tertiary-dashed button styles + keypad-key and card-action factories
│   │       ├── RoundedChevronButton.swift # 44pt yellow rounded-square back button (used via ScreenHeader)
│   │       ├── ScreenHeader.swift       # 85pt white header bar + 3pt rule with back button and title; optional trailing accessory overlay (room-code pill) — every screen after Home
│   │       ├── InfoCard.swift           # Parameterized icon/title/description card, tall + compact variants (HowPlayView)
│   │       ├── HardShadowModifier.swift # View.hardShadow(in:offset:color:) — flat offset shadow for non-button surfaces (name field, avatar badge)
│   │       ├── SelectablePillButton.swift # Value-over-caption choice pill, white/green by selection (CreateRoomView)
│   │       ├── SelectablePillGroup.swift # Titled row of pills bound to one selection — players and duration rows share it
│   │       ├── ColorSwatchPicker.swift  # Generic row of 44pt color circles with a red selection ring
│   │       ├── PlayerColor+DesignSystem.swift # Maps the Domain PlayerColor to its SwiftUI color and VoiceOver name
│   │       ├── AvatarBadge.swift        # Round player avatar (large 52pt live preview / small 30pt list marker): swatch color + first letter of the name
│   │       ├── NameField.swift          # Shared name TextField: white ink-bordered box, gray hint, red caret (Create Room, Enter Name)
│   │       ├── RoomCodePill.swift       # Yellow capsule with "غرفة" + the room code (Enter Name header)
│   │       ├── PlayerRow.swift          # One player in a list: small avatar + name + owner caption (Model derives the rules)
│   │       ├── PlayersCard.swift        # Fixed-size card: title, scrolling PlayerRow list with dashed rules, count footer
│   │       ├── DashedRule.swift         # 3pt dashed rule shared by the room-full card and the players list
│   │       ├── KeypadKey.swift          # One keypad key (digit / red delete / green confirm) on HardShadowButtonStyle
│   │       ├── NumericKeypad.swift      # 3×4 left-to-right keypad reporting taps through callbacks (JoinRoomView)
│   │       ├── CodeDigitBox.swift       # One 56×70 room-code box: filled / active (caret) / empty (dashed) / error / locked styles
│   │       ├── CodeDigitRow.swift       # The four code boxes in entry order (first digit at the physical left)
│   │       ├── MessageBanner.swift      # Red pill with a white "!" badge and hard shadow (invalid-code message)
│   │       ├── AlertCard.swift          # White card with red border: count badge, headline, dashed rule, message, two actions (room full)
│   │       ├── DashedRoundedRect.swift  # Rounded-rect path with a known start point for measured dash phases (Home's dashed button, empty code box)
│   │       ├── SettingsRowToggleStyle.swift # Full-row toggle with 64×28pt custom switch (HomeSettingView)
│   │       ├── ComicOutlineText.swift   # Stroked-text technique for the wordmark
│   │       └── StarburstLogo.swift      # Real PNG starburst asset (Image("starburst"), template-tinted shadow copy) + wordmark lockup, GeometryReader-proportional layout
│   ├── Resources/
│   │   └── Fonts/                # Bundled Almarai .ttf weights (Light/Regular/Bold/ExtraBold)
│   └── Assets.xcassets/          # App icon, accent color, design-system colors, badge icons
└── guessGameTests/
    ├── AvatarBadgeTests.swift    # Avatar-initial derivation (trim, placeholder fallback, diacritics)
    ├── PlayerColorTests.swift    # Swatch reading order, unique VoiceOver names
    ├── PlayerRowModelTests.swift # Owner caption, accessibility label, initial
    ├── EnterNameViewModelTests.swift # Count text from the room, rows, name trimming, canSubmit/submit
    ├── EnterNameViewTests.swift  # fitScale at 852/734/narrow widths
    └── JoinRoomViewModelTests.swift # Code-entry rules, transitions, JoinOutcome resolver, onJoined, per-box styles
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

`guessGameApp.swift` is the composition root. It currently wires nothing from Domain/Data (no use case or repository exists yet — see Architecture above); its content today is the app-wide RTL setup: forcing `UIView.appearance().semanticContentAttribute = .forceRightToLeft` in `init()` (so UIKit-backed chrome like `NavigationStack`'s back-chevron placement mirrors correctly) and applying `.environment(\.layoutDirection, .rightToLeft)` to the root view. `HomeView` has no ViewModel — it owns its own `NavigationStack` and push-navigation state directly via `@State private var path: [HomeDestination]`, since it has no business logic to separate out. Its one injection point is `HomeView(joinResolver:)`, the seam where the future join use case will plug in; it defaults to `JoinRoomViewModel.noRoomsYet`, which rejects every code. `HomeView` also owns the hand-off from Join Room to Enter Name: it passes Join Room's view-model an `onJoined` closure that appends `.enterName(room)` to `path`.

## Testing Strategy

XCTest only (not Swift Testing) per project convention. The Domain entities are plain data, so they have no tests of their own beyond `PlayerColorTests`; the Presentation layer has the real logic and real tests (the old `PlaceholderTests` stub is gone). The screens themselves are pure declarative SwiftUI with no logic to assert, so they're intentionally untested; `Font+DesignSystem`/`Color+DesignSystem` are trivial accessors wrapping platform APIs, also intentionally untested. Presentation logic with real branching is covered: `AvatarBadge.initial(from:placeholder:)`, which derives the avatar letter from the entered name, by `AvatarBadgeTests`, Join Room's entry rules (capacity, delete, error clearing on edit, submit with an incomplete or complete code via an injected `JoinOutcome` resolver, `onJoined`, retry, per-box styles, announcements) by `JoinRoomViewModelTests`, and Enter Name's rules (count text computed from the room, owner-only caption, name trimming, `canSubmit`/`submit`, narrow-screen scale) by `PlayerRowModelTests`, `EnterNameViewModelTests` and `EnterNameViewTests`. Test on this machine with `-destination 'id=<simulator UDID>'` from `xcodebuild -showdestinations` when the name-based destination above doesn't resolve.

## Design System

See [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) for the full visual design system — colors, typography, spacing, and Apple HIG compliance rules. Follow it for every UI/frontend task; treat it as the source of truth over any values inferred from mockup images or screenshots. Token helpers live in `Presentation/DesignSystem/`. Note: DESIGN_SYSTEM.md's single `Ink/Stroke & Ink/Text` token was split into two color assets, `InkStroke` and `InkText` — identical in Light Mode, but `InkStroke` stays dark in Dark Mode (it's a comic-outline color around shapes) while `InkText` inverts to a warm off-white (it's body/label text color and needs contrast against the dark Paper background). The Create Room screen added five swatch colors (`AvatarTeal`, `AvatarPurple`, `AvatarPink`, `AvatarBlue`, `AvatarGold`, identical in both appearances because they identify a player) — its greens and reds reuse `BrandLime`/`BrandRed`. The How to Play screen added three colors measured from its mockup: `BrandLimeDeep` (green card border) and the `TintRed` / `TintLime` card fills. Cards that are literally white or yellow in the mockup keep literal black text in both appearances; only the tinted cards use `InkText`. The Join Room screen added `LockedFill` / `LockedStroke` / `LockedText` for its disabled (room-full) code boxes, plus five fonts (`codeDigit`, `labelPrompt`, `messageBanner`, `bodyStrong`, `badgeMono`); its red, green and yellow surfaces reuse `BrandRed`, `TintRed`, `BrandLime` and `BrandYellow`. The Enter Name screen added one font (`avatarInitialSmall`) and no colors — everything on it reuses existing tokens (`BrandYellow`, `BrandLime`, the avatar swatch colors, `InkStroke`, black at 25%/45%/50% for the divider, caption/footer and hint).

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
- Adaptive across portrait and landscape on all supported iPhone sizes — `HomeView` picks its arrangement live from a `GeometryReader` width-vs-height comparison (no fixed device breakpoints). `Home.png` is the pixel-exact reference for the landscape composition: it is laid out in fixed points (407×271pt logo, 288pt button column, 18pt gap) and centered on the *physical* 852×393 screen, ignoring the safe area, because the mockup has no safe-area concept (only the logo shrinks below ~780pt width, e.g. iPhone SE). The portrait arrangement is a proportional reflow of the same elements (not a separately designed screen) inside the safe area with a 16/24pt margin.
- No real room/networking logic yet — Enter Name is a real screen built to its mockup (name field with a live avatar preview, swatches, the players-in-room card driven by a `Room`), but it is not reachable in the shipping flow yet: Join Room's default resolver rejects every code, so nothing ever produces a `.joined(room)` outcome. It is reachable through previews (`Room.sample`, `#if DEBUG`) and an injected resolver (`HomeView(joinResolver:)`). Its "دخول الغرفة" button calls a no-op `onSubmit` until a lobby screen and the join use case exist, and a room with 0 players (the future owner path) renders the card with an empty list. The player list is a fixed 208pt card whose 123.75pt list scrolls past three rows, because six rows would not fit the 393pt-tall screen. Join Room is a real screen built to its three mockups (entering, invalid code, room full), driven by one `JoinRoomState` enum and a `JoinRoomViewModel`, but its join step is a stub: the injectable resolver defaults to "no rooms exist, so every submitted code is invalid" until the join use case lands, and the room-full state is reachable only through an injected resolver or previews. Create Room is a real screen built to its mockup, but UI-only: name, avatar color, player count and round duration live in local `@State`, and its create button is a deliberate no-op until the create-room use case exists. It pins `.dynamicTypeSize(.large)` and scales its column down below 734pt for the same reasons as How to Play. How to Play is a real, static rules screen (`HowPlayView`) built to its mockup; it pins `.dynamicTypeSize(.large)` because its card and line heights are fixed pixel measurements, and it scales its content column down uniformly on screens narrower than 734pt (iPhone SE class). See `/Users/rana/Desktop/Takhmeen Handoff Plan.pdf` for the planned full screen flow and the future `roomState`/`roundState` networking contract.
- No `Localizable.strings`/`NSLocalizedString` infrastructure — single hardcoded Arabic language via `Presentation/DesignSystem/Strings.swift`. A future real localization pass is a mechanical extraction from there, not a rewrite.
