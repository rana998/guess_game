# guessGame

## Project Overview

guessGame (product name **تخمين**) is a SwiftUI party game for iOS: a picture-description guessing game for 3–6 players, each on their own device. The Xcode project is generated via XcodeGen from `project.yml` (the source of truth — never edit `guessGame.xcodeproj` directly). It's built as a strict Clean Architecture with three layers — Presentation, Domain, and Data — organized within a single Xcode target. Presentation holds the Home, Settings, How to Play, Create Room, Join Room, Enter Name and Waiting Room screens and the round flow's screens (waiting for the word, difficulty picker, word card, describer board with its tag picker, guesser board); Domain holds the room and game entities, the pure round rules, the game use cases and the repository protocols; Data holds the in-memory game store and the Arabic word lists. Rooms and games are still local to one device until networking arrives (see Non-Goals).

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
| Pure rules (no state, no dependencies) | Domain | `Domain/Rules` |
| Injected domain capabilities (randomness) | Domain | `Domain/Services` |
| Design tokens & reusable UI components | Presentation | `Presentation/DesignSystem` |
| Navigation destinations | Presentation | `Presentation/Navigation` |
| Development-only tools (`#if DEBUG`) | Presentation | `Presentation/Debug` |

`Domain/Entities` holds pure value types that import nothing but Foundation: the room's (`PlayerColor`, `Player` with its `isReady` lobby flag, `Room` with its `roundSeconds` and the 3–6 player / round-length constants, `RoomRole`, `JoinOutcome`) and the game's (`Game` — players, round length, the fixed turn order, the current `Round`, scores and used words; `Round` — phase, difficulty, word, deadline, the describer's `ClueMark`s and the `Guess`es; plus `Difficulty`, `ClueTag`, `RoundPhase`, `RoundEndReason` and the typed results/rejections of a tag or a guess). Presentation maps them to SwiftUI in `*+DesignSystem.swift` extensions. `Domain/Rules` holds the stateless rules — `TurnOrder` (random first describer, then round-robin), `ClueMarkRules` (1 "?" main idea, 10 cube details, 1 "!" secondary idea per round, independent caps), `ScoringRules` (1/2/3 by difficulty + 1 for the describer) and `GuessMatcher`/`ArabicTextNormalizer` (spelling-, diacritic-, space- and article-insensitive matching). `Domain/UseCases` holds the game's use cases (`GameLifecycleUseCase`, `DescriberTurnUseCase`, `GuessUseCase`, `RoundTimerUseCase`, each protocol + struct `Impl`), which load the game from `GameRepository`, refuse anything out of turn or over a cap without saving, and save the new game otherwise. `Data/` holds `GameRepositoryImpl` (an `@Observable` in-memory store — every screen reads the game through it, so one player's move redraws everyone's view on the device; the networked store replaces it later) and `WordRepositoryImpl` over the bundled `ArabicWordList`. Room creation and joining are still Presentation-only (Join Room's injectable resolver, Create Room's local room building, the waiting room's rules) until their use cases exist.

## Folder Structure

```
guessGame/
├── project.yml                  # XcodeGen project spec — source of truth for the .xcodeproj
├── .gitignore
├── CLAUDE.md
├── DESIGN_SYSTEM.md
├── guessGame/                   # App target
│   ├── App/                     # Composition root
│   │   ├── guessGameApp.swift
│   │   ├── GameUseCases+Live.swift   # make(...) / live(): the game's use cases over GameRepositoryImpl + WordRepositoryImpl — the only non-Data file that names Data types
│   │   └── GameUseCases+Preview.swift # #if DEBUG preview(seededWith:) — live use cases over a store holding a given game
│   ├── Domain/
│   │   ├── Entities/
│   │   │   ├── PlayerColor.swift    # The six player identity colors in reading order (first = physical right); no SwiftUI
│   │   │   ├── Player.swift         # id, name, color, isOwner, isReady
│   │   │   ├── Room.swift           # code, capacity, players, roundSeconds; min/max players and round-length options
│   │   │   ├── RoomRole.swift       # owner / participant — the viewer's role in a room, not a player field
│   │   │   ├── JoinOutcome.swift    # joined(Room) / invalidCode / roomFull(capacity:) — what a room-code lookup produces
│   │   │   ├── Game.swift           # players, roundSeconds, turnOrder, currentRound, scores, usedWords, isFinished; guessers, roundsUntilTurn(of:)
│   │   │   ├── Round.swift          # index, describerId, phase, difficulty, word, endsAt/endedAt, marks, guesses, awardedPoints; 32-tile board; remainingSeconds(at:)
│   │   │   ├── RoundPhase.swift     # choosingWord / wordDrawn / describing / ended(reason)
│   │   │   ├── RoundEndReason.swift # guessed(winnerId:) / timeUp / endedByDescriber
│   │   │   ├── Difficulty.swift     # easy / medium / hard
│   │   │   ├── ClueTag.swift        # mainIdea ("?") / detail (cube) / secondaryIdea ("!"); the first two share the main-idea box
│   │   │   ├── ClueMark.swift       # A tagged board tile (handoff marks[{tileId, badge}])
│   │   │   ├── Guess.swift          # id (order), playerId, trimmed text, isCorrect
│   │   │   ├── ClueMarkResult.swift / ClueMarkRejection.swift # placed, or why a tag was refused
│   │   │   └── GuessResult.swift / GuessRejection.swift       # correct / incorrect, or why a guess was refused
│   │   ├── Rules/
│   │   │   ├── TurnOrder.swift      # rotation(of:startingAt:) — everyone describes once, round-robin from the random first
│   │   │   ├── ClueMarkRules.swift  # limit(for:) 1/10/1, remaining, hasAnyRemaining, rejection(placing:onTile:in:)
│   │   │   ├── ScoringRules.swift   # guesser 1/2/3 by difficulty, describer 1
│   │   │   ├── ArabicTextNormalizer.swift # NFKC, diacritics/tatweel/invisible marks out, alef/ta marbuta/alef maqsura/hamza carriers unified, punctuation out
│   │   │   └── GuessMatcher.swift   # normalized, space-insensitive, optional "ال" article
│   │   ├── Services/
│   │   │   └── RandomIndexPicker.swift # Injected randomness (first describer, word draw); index(below:) never out of range
│   │   ├── Repositories/
│   │   │   ├── GameRepository.swift # game / save / clear; implementations are @Observable
│   │   │   └── WordRepository.swift # words(for: difficulty)
│   │   └── UseCases/
│   │       ├── GameLifecycleUseCase(+Impl).swift # currentGame, start(room:), advanceToNextRound(), leave()
│   │       ├── DescriberTurnUseCase(+Impl).swift # drawWord (no repeats per game), startDescribing, placeMark (caps), endRound
│   │       ├── GuessUseCase(+Impl).swift         # submit: refusals, record, first correct guess scores and ends the round
│   │       └── RoundTimerUseCase(+Impl).swift    # expireIfDue(now:) — idempotent time-up
│   ├── Data/
│   │   ├── Repositories/
│   │   │   ├── GameRepositoryImpl.swift # @Observable in-memory game shared by every screen on the device
│   │   │   └── WordRepositoryImpl.swift # Serves ArabicWordList by difficulty
│   │   └── DataSources/
│   │       └── ArabicWordList.swift # 16 real words per difficulty, no diacritics
│   ├── Presentation/
│   │   ├── Views/
│   │   │   ├── HomeView.swift           # App entry point
│   │   │   ├── CreateRoomView.swift     # Room setup screen: name field + avatar badge/swatches, player-count & round-duration pills, create button (builds a local room via CreateRoomViewModel), landscape 852×393 mockup spec
│   │   │   ├── WaitingRoomView.swift    # Lobby for both roles: room code + copy chip or kebab, player-card grid up to capacity, ready count, duration pills + start (owner) or ready toggle (participant), landscape 852×393 mockup spec
│   │   │   ├── JoinRoomView.swift       # Room-code entry: 4 code boxes + keypad, error banner or room-full card by JoinRoomState, landscape 852×393 mockup spec
│   │   │   ├── EnterNameView.swift      # After a code is accepted: name field + live avatar preview, swatches, enter button, and the players-in-room card, landscape 852×393 mockup spec
│   │   │   ├── HomeSettingView.swift    # Settings (UI-only toggles), landscape 852×393 Figma spec
│   │   │   ├── Game/                    # The round flow, each screen built to its 852×393 mockup on a GameCanvas
│   │   │   │   ├── GameView.swift           # Host: routes phase × role to a screen (reset per GameScreenIdentity), ticks the timer (and moves on 4 s after a round ends), leave alert, DEBUG switcher
│   │   │   │   ├── WaitingForWordView.swift # Guesser, screen 1: DescriberStatusPill ("<name> تختار الكلمة", per mockup), waiting dots, timer message, rounds-until-your-turn badge, guessers and count
│   │   │   │   ├── DifficultyPickerView.swift # Describer, screen 2: easy/medium/hard cards with points, "اسحب الكلمة"
│   │   │   │   ├── WordCardView.swift       # Describer, screen 3: the word on a burst, the tags checklist, "ابدأ الوصف"
│   │   │   │   ├── DescriberBoardView.swift # Describer, screen 4: word pill, cube counter, timer, end round, legend, 8×4 grid, custom scroll bar
│   │   │   │   ├── BadgePickerSheet.swift   # Screen 5: the tag picker, options greyed as their caps are used
│   │   │   │   ├── GuesserBoardView.swift   # Guesser, screens 6–7: header strip, guess panel + field, main-idea and secondary-idea boxes
│   │   │   │   └── RoundCountdownPill.swift # The only view that reads the clock, so ticks don't redraw the boards
│   │   │   └── HowPlayView.swift        # Static rules screen: header + 5 InfoCards + points bar, landscape 852×393 mockup spec
│   │   ├── ViewModels/
│   │   │   ├── JoinRoomState.swift      # idle / invalidCode / roomFull(capacity:) — the single enum Join Room's UI follows
│   │   │   ├── JoinRoomViewModel.swift  # @Observable code-entry rules, submit via injectable JoinOutcome resolver (default: every code invalid — no rooms exist yet) and an onJoined closure, per-box styles
│   │   │   ├── EnterNameViewModel.swift # @Observable name + color + the room being joined; computed count text, row models, canSubmit
│   │   │   ├── CreateRoomViewModel.swift # @Observable Create Room choices; submit builds the owner's local room and session
│   │   │   ├── LocalRoomCode.swift      # Stub 4-digit room code until a backend exists; never the example code 8701
│   │   │   ├── WaitingRoomViewModel.swift # @Observable lobby rules: ready toggle, remove, copy, round length, start and auto-start
│   │   │   ├── WaitingRoomPhase.swift   # waiting / starting — starting locks the room
│   │   │   ├── WaitingRoomSlot.swift    # One grid place: a player's card model or an empty seat
│   │   │   ├── GameViewModel.swift      # screen/screenIdentity per viewer, tick() (time-up, then auto-advance after roundEndPause), continueAfterRound(), leave once, switchViewer, child factories
│   │   │   ├── GameClock.swift          # @Observable injected clock; refreshed only by intents and ticks
│   │   │   ├── GameScreen.swift / GameScreenIdentity.swift # The five screens; round + viewer + screen identity
│   │   │   ├── WaitingForWordViewModel.swift / DifficultyPickerViewModel.swift / WordCardViewModel.swift
│   │   │   ├── DescriberBoardViewModel.swift # Tiles, cube counter, picker state/options, choose → placeMark, end round
│   │   │   ├── GuesserBoardViewModel.swift  # Guess rows, typedGuess/canSubmit/submit, main slots in placement order, secondary tile, announcements
│   │   │   ├── DifficultyOption.swift / BadgeOption.swift / AvatarModel.swift / ViewerChoice.swift
│   │   │   └── CountdownFormatter.swift # "m:ss" in ASCII digits
│   │   ├── Samples/
│   │   │   ├── Room+Sample.swift        # #if DEBUG example rooms for previews/screenshots only — never the shipping path
│   │   │   └── Game+Sample.swift        # #if DEBUG the round mockups' game (lobby players, round 3 of 6, "وحيد القرن") on a fixed clock
│   │   ├── Navigation/
│   │   │   ├── HomeDestination.swift    # Hashable enum for Home's NavigationStack (enterName carries the joined Room, waitingRoom the session)
│   │   │   ├── WaitingRoomSession.swift # Room + viewer role + viewer id; joining(...) appends a new participant (nil when full)
│   │   │   └── GameUseCases.swift       # The use-case bundle round screens get (no repository: they can't save directly)
│   │   ├── Debug/
│   │   │   └── ViewerSwitcher.swift     # #if DEBUG: view the one-device game as any player
│   │   └── DesignSystem/
│   │       ├── Color+DesignSystem.swift
│   │       ├── Font+DesignSystem.swift
│   │       ├── Strings.swift            # Hardcoded Arabic strings, namespaced per screen
│   │       ├── AppButtonStyle.swift     # Primary/secondary/tertiary-dashed button styles + keypad-key, card-action, header-icon, copy-chip and lobby-action factories
│   │       ├── RoundedChevronButton.swift # 44pt yellow rounded-square back button (used via ScreenHeader)
│   │       ├── ScreenHeader.swift       # 85pt white header bar + 3pt rule with back button and title; optional trailing accessory overlay (room-code pill) — every screen after Home
│   │       ├── InfoCard.swift           # Parameterized icon/title/description card, tall + compact variants (HowPlayView)
│   │       ├── HardShadowModifier.swift # View.hardShadow(in:offset:color:) — flat offset shadow for non-button surfaces (name field, avatar badge)
│   │       ├── SelectablePillButton.swift # Choice pill, white/green by selection: regular value-over-caption (Create Room) or compact value-only (Waiting Room)
│   │       ├── SelectablePillGroup.swift # Optionally titled row of pills bound to one selection — Create Room's rows and the waiting room's duration pills
│   │       ├── ColorSwatchPicker.swift  # Generic row of 44pt color circles with a red selection ring
│   │       ├── PlayerColor+DesignSystem.swift # Maps the Domain PlayerColor to its SwiftUI color and VoiceOver name
│   │       ├── AvatarBadge.swift        # Round player avatar (large 52pt live preview / medium 36pt waiting-room card / small 30pt list marker): swatch color + first letter of the name
│   │       ├── NameField.swift          # Shared name TextField: white ink-bordered box, gray hint, red caret (Create Room, Enter Name)
│   │       ├── RoomCodePill.swift       # Yellow capsule with "غرفة" + the room code (Enter Name and Waiting Room headers)
│   │       ├── EllipsisDots.swift       # Three 5pt dots — Home's settings badge and the waiting room's kebab
│   │       ├── PlayerWaitingCard.swift  # 242×89 waiting-room card: avatar, name + caption, ready pill, owner's remove button (Model derives the rules)
│   │       ├── EmptyPlayerSlotCard.swift # Dashed "بانتظار لاعب" seat up to the room's capacity
│   │       ├── ReadyStatusPill.swift    # 63×30 green "جاهز" + check / dashed "في الانتظار" capsule
│   │       ├── RemovePlayerButton.swift # Red 39pt "−" button with a 44pt hit area
│   │       ├── CopyBurstIcon.swift      # Vector 12-point yellow burst with a green oval (copy chip icon)
│   │       ├── CopyCodeButton.swift     # Owner's "نسخ" chip; reads "تم النسخ" while confirming
│   │       ├── KebabMenuButton.swift    # Participant's 44pt dots button opening a "مغادرة الغرفة" menu
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
│   │       ├── GameCanvas.swift / CanvasPlacement.swift / GameLayout.swift # 852×393 canvas, full-bleed top band, scale-down; canvasCenter(x:y:) in mockup coordinates
│   │       ├── ClueTile.swift           # 84pt picture tile (board / main-idea / secondary-idea / 56pt preview) with its tag pinned top-left
│   │       ├── ClueTagIcon.swift / ClueTag+DesignSystem.swift / Difficulty+DesignSystem.swift # Tag art sizes, names, asset names
│   │       ├── ClueTileButtonStyle.swift # Board tiles keep their tint when disabled
│   │       ├── EmptyClueSlot.swift / BadgeOptionCard.swift / RoundTimerPill.swift / WaitingDots.swift / AvatarLabelCapsule.swift / GuessRow.swift
│   │       ├── GameTopBar.swift / SecretWordCard.swift
│   │       ├── DescriberStatusPill.swift # The waiting screen's black "<name> تختار الكلمة" pill, to its mockup: solid 26pt avatar disc, white ExtraBold 16, hugs its text
│   │       ├── BoardScrollIndicator.swift / ScrollOffsetPreferenceKey.swift # The board's always-visible scroll bar
│   │       ├── BurstShape.swift / ChevronShape.swift # Shared shapes (copy chip + word card burst; back + send chevrons)
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
    ├── JoinRoomViewModelTests.swift # Code-entry rules, transitions, JoinOutcome resolver, onJoined, per-box styles
    ├── CreateRoomViewModelTests.swift # Defaults, options, submit builds the owner's room/session, blank name
    ├── LocalRoomCodeTests.swift  # Four ASCII digits, never 8701, redraw on exclusion
    ├── WaitingRoomSessionTests.swift # joining appends a not-ready participant; nil when full
    ├── WaitingRoomViewModelTests.swift # Ready count, slots, toggle/remove/copy/round-length rules, start and auto-start, leave
    ├── WaitingRoomViewTests.swift # fitScale at 852/778/narrow widths
    ├── PlayerWaitingCardModelTests.swift # Caption, highlight, remove rules per viewer; accessibility labels
    ├── SnapshotRenderer.swift    # Window-based PNG renderer (UIWindow + drawHierarchy) for mockup comparison
    ├── CreateRoomSnapshotTests.swift # Create Room snapshot (the no-visual-change baseline)
    ├── WaitingRoomSnapshotTests.swift # Owner, participant, 2-of-4 and starting snapshots
    ├── WaitingRoomFixtures.swift # The mockups' lobby (test target only)
    ├── GameFixtures.swift / GameRepositoryFake.swift / WordRepositoryStub.swift / MutableDate.swift # Game builders, a save-counting store, fixed words, a hand-moved clock
    ├── RoundTests.swift / GameTests.swift / RandomIndexPickerTests.swift # Entity derivations, remaining time, turn distance
    ├── TurnOrderTests.swift / ClueMarkRulesTests.swift / ScoringRulesTests.swift / ArabicTextNormalizerTests.swift / GuessMatcherTests.swift
    ├── GameLifecycleUseCaseTests.swift / DescriberTurnUseCaseTests.swift / GuessUseCaseTests.swift / RoundTimerUseCaseTests.swift # incl. "refusals save nothing"
    ├── GameRepositoryImplTests.swift / WordRepositoryImplTests.swift
    ├── CountdownFormatterTests.swift / GameClockTests.swift / GameLayoutTests.swift
    ├── WaitingForWordViewModelTests.swift / DifficultyPickerViewModelTests.swift / WordCardViewModelTests.swift
    ├── DescriberBoardViewModelTests.swift / GuesserBoardViewModelTests.swift / GameViewModelTests.swift
    └── GameSnapshotTests.swift  # The seven round screens in their mockups' states
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

`guessGameApp.swift` is the composition root. It builds the game's use cases once with `GameUseCases.live()` (`App/GameUseCases+Live.swift`, the only file outside `Data/` that names Data types) and hands them to `HomeView(gameUseCases:)`; it also does the app-wide RTL setup: forcing `UIView.appearance().semanticContentAttribute = .forceRightToLeft` in `init()` (so UIKit-backed chrome like `NavigationStack`'s back-chevron placement mirrors correctly) and applying `.environment(\.layoutDirection, .rightToLeft)` to the root view. `HomeView` has no ViewModel — it owns its own `NavigationStack` and push-navigation state directly via `@State private var path: [HomeDestination]`, since it has no business logic to separate out. Its injection points are `gameUseCases` and `joinResolver`, the seam where the future join use case will plug in; the resolver defaults to `JoinRoomViewModel.noRoomsYet`, which rejects every code. `HomeView` also owns the hand-off from Join Room to Enter Name: it passes Join Room's view-model an `onJoined` closure that appends `.enterName(room)` to `path`. It owns the hand-offs into the Waiting Room too: Create Room's `onCreate` appends `.waitingRoom(session)` with the owner's session, and Enter Name's `onSubmit` builds a participant session with `WaitingRoomSession.joining` (a full room yields none, so nothing is pushed). It gives the waiting room's view-model the pasteboard (`UIPasteboard`, kept out of the view-model), `onLeave` (back to Home via `path.removeAll()`) and `onStartGame`, which starts the game from the room through `gameUseCases.lifecycle` and pushes `.game(viewerId:)` as the device's player. That destination builds `GameView` with a `GameViewModel` over the same use cases, a `GameClock` on the real date and `onExit` (back to Home). Round view models never save the game themselves: they read it through `lifecycle.currentGame` (Observation tracks the read through the protocol, so every screen redraws on any save) and change it only through the use cases. Time comes from the injected `GameClock`, refreshed by intents and by `GameView`'s 250 ms tick; only `RoundCountdownPill` reads it, so ticks redraw the countdown alone.

## Testing Strategy

XCTest only (not Swift Testing) per project convention. The Domain entities are plain data, so they have no tests of their own beyond `PlayerColorTests`; the Presentation layer has the real logic and real tests (the old `PlaceholderTests` stub is gone). The screens themselves are pure declarative SwiftUI with no logic to assert, so they're intentionally untested; `Font+DesignSystem`/`Color+DesignSystem` are trivial accessors wrapping platform APIs, also intentionally untested. Presentation logic with real branching is covered: `AvatarBadge.initial(from:placeholder:)`, which derives the avatar letter from the entered name, by `AvatarBadgeTests`, Join Room's entry rules (capacity, delete, error clearing on edit, submit with an incomplete or complete code via an injected `JoinOutcome` resolver, `onJoined`, retry, per-box styles, announcements) by `JoinRoomViewModelTests`, and Enter Name's rules (count text computed from the room, owner-only caption, name trimming, `canSubmit`/`submit`, narrow-screen scale) by `PlayerRowModelTests`, `EnterNameViewModelTests` and `EnterNameViewTests`. Create Room's room building (`CreateRoomViewModelTests`), the stub room code (`LocalRoomCodeTests`), joining a room (`WaitingRoomSessionTests`), the waiting-room card rules (`PlayerWaitingCardModelTests`), the waiting room's rules — ready count, slots, ready toggle, remove, copy confirmation, round length, the start rule, auto-start and the lock while starting — (`WaitingRoomViewModelTests`) and its narrow-screen scale (`WaitingRoomViewTests`) are covered the same way. A snapshot harness (`SnapshotRenderer`, hosting the screen in a real `UIWindow` and capturing it with `drawHierarchy`, since `ImageRenderer` can't draw `Menu` or `TextField`) renders Create Room and the waiting room at 852×393 for comparison against the mockups; those tests are skipped unless `TEST_RUNNER_SNAPSHOT_DIR` is set: `TEST_RUNNER_SNAPSHOT_DIR=<dir> xcodebuild -project guessGame.xcodeproj -scheme guessGame -destination 'id=<simulator UDID>' test`. The round flow is covered the same way, from the bottom up: the entities' derivations (`RoundTests`, `GameTests`), the pure rules — turn order, the three independent tag caps, scoring and Arabic guess matching — (`TurnOrderTests`, `ClueMarkRulesTests`, `ScoringRulesTests`, `ArabicTextNormalizerTests`, `GuessMatcherTests`), the use cases against `GameRepositoryFake`, which counts saves so every refusal is proven to write nothing (`GameLifecycleUseCaseTests`, `DescriberTurnUseCaseTests`, `GuessUseCaseTests`, `RoundTimerUseCaseTests`), the word bank (`WordRepositoryImplTests`) and every round view model against real use cases with a hand-moved `MutableDate` clock (`WaitingForWordViewModelTests`, `DifficultyPickerViewModelTests`, `WordCardViewModelTests`, `DescriberBoardViewModelTests`, `GuesserBoardViewModelTests`, `GameViewModelTests`). `GameSnapshotTests` renders the seven round screens in their mockups' states with the same harness. Test on this machine with `-destination 'id=<simulator UDID>'` from `xcodebuild -showdestinations` when the name-based destination above doesn't resolve.

## Design System

See [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) for the full visual design system — colors, typography, spacing, and Apple HIG compliance rules. Follow it for every UI/frontend task; treat it as the source of truth over any values inferred from mockup images or screenshots. Token helpers live in `Presentation/DesignSystem/`. Note: DESIGN_SYSTEM.md's single `Ink/Stroke & Ink/Text` token was split into two color assets, `InkStroke` and `InkText` — identical in Light Mode, but `InkStroke` stays dark in Dark Mode (it's a comic-outline color around shapes) while `InkText` inverts to a warm off-white (it's body/label text color and needs contrast against the dark Paper background). The Create Room screen added five swatch colors (`AvatarTeal`, `AvatarPurple`, `AvatarPink`, `AvatarBlue`, `AvatarGold`, identical in both appearances because they identify a player) — its greens and reds reuse `BrandLime`/`BrandRed`. The How to Play screen added three colors measured from its mockup: `BrandLimeDeep` (green card border) and the `TintRed` / `TintLime` card fills. Cards that are literally white or yellow in the mockup keep literal black text in both appearances; only the tinted cards use `InkText`. The Join Room screen added `LockedFill` / `LockedStroke` / `LockedText` for its disabled (room-full) code boxes, plus five fonts (`codeDigit`, `labelPrompt`, `messageBanner`, `bodyStrong`, `badgeMono`); its red, green and yellow surfaces reuse `BrandRed`, `TintRed`, `BrandLime` and `BrandYellow`. The Enter Name screen added one font (`avatarInitialSmall`) and no colors — everything on it reuses existing tokens (`BrandYellow`, `BrandLime`, the avatar swatch colors, `InkStroke`, black at 25%/45%/50% for the divider, caption/footer and hint). The Waiting Room added one color, `CardHighlight` (the Paper tone, fixed in both appearances, for your own card), and two fonts, `bodySmallStrong` (Bold 11, its card captions and auto-start caption) and `pillMono` (SF Mono Semibold 20, its duration pills); its compact pills, lobby/header/copy buttons, 36pt medium avatar and vector copy burst are listed under DESIGN_SYSTEM.md's Components. The round screens added no colors — they reuse `BrandLime`/`BrandLimeDeep`/`TintLime` (main idea), `BrandRed`/`TintRed` (secondary idea), `BrandYellow`, `Paper` and the `Locked*` trio (used-up tags) — and seven fonts fitted to their mockups' ink: `wordDisplay` (ExtraBold 40), `titleLarge` (ExtraBold 26), `bodyLarge` (Regular 14), `bodyMedium` (Regular 13), `captionStrong` (Bold 13), and `timerMono`/`counterMono` (SF Mono Bold 20/16, DESIGN_SYSTEM.md's Numeric/Mono pair). The tag art is the existing `badge-question` / `badge-cube` / `badge-exclaim` assets. Their components are listed under DESIGN_SYSTEM.md's Components.

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
- No real room/networking logic yet — Enter Name is a real screen built to its mockup (name field with a live avatar preview, swatches, the players-in-room card driven by a `Room`), but it is not reachable in the shipping flow yet: Join Room's default resolver rejects every code, so nothing ever produces a `.joined(room)` outcome. It is reachable through previews (`Room.sample`, `#if DEBUG`) and an injected resolver (`HomeView(joinResolver:)`). Its "دخول الغرفة" button now opens the Waiting Room as a participant (the join itself is still local — no join use case exists), and a room with 0 players (the future owner path) renders the card with an empty list. The player list is a fixed 208pt card whose 123.75pt list scrolls past three rows, because six rows would not fit the 393pt-tall screen. Join Room is a real screen built to its three mockups (entering, invalid code, room full), driven by one `JoinRoomState` enum and a `JoinRoomViewModel`, but its join step is a stub: the injectable resolver defaults to "no rooms exist, so every submitted code is invalid" until the join use case lands, and the room-full state is reachable only through an injected resolver or previews. Create Room is a real screen built to its mockup; its choices live in `CreateRoomViewModel`, and its create button builds a **local** room (no create-room use case or server yet) with the creator as the ready owner and opens the Waiting Room. The room code comes from the stub `LocalRoomCode`: four random ASCII digits that never equal 8701, the mockups' example code that previews and test fixtures use, so a real room can't look like sample data. The Waiting Room is a real screen built to its owner and participant mockups, but rooms are local-only: nobody else can join a created room, and no other device sees changes. Its rules are deliberate assumptions until the networking contract lands: the owner may start with 3 or more players even if some aren't ready; the game auto-starts, on each device locally, once 3 or more players are all ready (checked after a ready toggle or a removal, not on opening); starting locks the room ("جارٍ بدء اللعبة…") and opens the round flow on that device. It shows an empty "بانتظار لاعب" seat for each free place up to capacity (no mockup exists for it), and it ignores the safe area like Home, so its footer runs under the home indicator. It pins `.dynamicTypeSize(.large)` and scales its column down below 734pt for the same reasons as How to Play. How to Play is a real, static rules screen (`HowPlayView`) built to its mockup; it pins `.dynamicTypeSize(.large)` because its card and line heights are fixed pixel measurements, and it scales its content column down uniformly on screens narrower than 734pt (iPhone SE class). See `/Users/rana/Desktop/Takhmeen Handoff Plan.pdf` for the planned full screen flow and the future `roomState`/`roundState` networking contract.
- No `Localizable.strings`/`NSLocalizedString` infrastructure — single hardcoded Arabic language via `Presentation/DesignSystem/Strings.swift`. A future real localization pass is a mechanical extraction from there, not a rewrite.
- The round flow is local to one device, like rooms: one in-memory `GameRepositoryImpl` holds the game and every screen on the device reads it. A game with 3+ players is therefore only reachable through an injected join resolver until networking exists. DEBUG builds carry a `ViewerSwitcher` (top center of every round screen) that views the shared game as any player, so one person can play every seat; Release builds show only the device's own player. Who may tap "الجولة التالية" once games span devices (anyone, locally, today) is a networking-phase decision.
- The round-result screen isn't built yet (the user has its design and will provide it): an ended round (correct guess, time up or "إنهاء جولة") stays on screen, with the correct guess checked in the guess list and the board and timer frozen, and 4 seconds later (`GameViewModel.roundEndPause`) the next round opens; after the last round the game returns Home. `continueAfterRound()` is the hook that screen will call. Until then VoiceOver users hear the correct guess (announced from the guess list) but get no cue when time runs out. Scores are kept in `Game.scores` but nothing shows them yet. Leaving mid-round uses a system `.alert` in place of the ExitConfirm design, and holds the round while it's up.
- Example player names live only in DEBUG-only code: `Presentation/Samples` (`Room+Sample`, `Game+Sample`), `App/GameUseCases+Preview.swift`, the `ViewerSwitcher`, and every `#Preview`, which are all inside `#if DEBUG`, plus the test target. A Release build fails to compile if shipping code references any of them, and Release binaries have been checked to contain none of the names.
- Round decisions made where the mockups disagreed or were silent: points are 1/2/3 (+1 for the describer), matching How to Play and the word card rather than the level screen's +2/+4/+8; the tag wording follows the confirmed meanings and the tag picker's labels ("?" الفكرة الرئيسية, cube تفصيل إضافي, "!" فكرة فرعية), not the board legend's older wording; a game has one round per player; tags are final (a tagged image can't be retagged); guessing opens with the first image; text naming a player is worded without gender, which the game doesn't know, except the waiting screen's describer pill, which follows its mockup exactly ("<name> تختار الكلمة", a feminine verb for every player); the guessers' typing dots are omitted (no presence data locally); the word card's burst is a vector (`BurstShape`) because the `starburst` asset carries the wordmark; the tag picker's cancel button is 44pt tall (the mockup's 39pt is under the tap-target minimum); the guess list sits against its bottom edge so new guesses stay visible above the keyboard.
- Clue tiles are blank placeholders: a tile's identity is its board index until real images exist.
- The round screens are drawn on their 852×393 landscape mockups and, like the waiting room, only scale down by width in portrait.
