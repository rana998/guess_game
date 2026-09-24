# Design System

Extracted from the Figma spec. Use these exact values for all UI/frontend work — don't approximate from screenshots or mockup images.

## Colors

| Token | Role | Hex |
|---|---|---|
| Brand/Lime | Primary, main concept | `#5CD62B` |
| Brand/Red | Danger, sub-concept | `#EE1C25` |
| Brand/Yellow | Accent, celebrate | `#FFE300` |
| Brand/Lime Deep | Green info-card border (How to Play) | `#2E9B1F` |
| Tint/Red | Red info-card fill (How to Play) | `#FFE9E7` |
| Tint/Lime | Green info-card fill (How to Play) | `#F0FFE4` |
| Avatar/Teal | Player color swatch (Create Room) | `#00B0C7` |
| Avatar/Purple | Player color swatch (Create Room) | `#7B4DFF` |
| Avatar/Pink | Player color swatch (Create Room) | `#FF6FA8` |
| Avatar/Blue | Player color swatch (Create Room) | `#2C7BE5` |
| Avatar/Gold | Player color swatch (Create Room) | `#F5C518` |
| Locked/Fill | Disabled code-box surface (Join Room, room full) | `#E4E1DA` |
| Locked/Stroke | Disabled code-box outline | `#969490` |
| Locked/Text | Disabled code-box digit | `#898783` |
| Ink/Stroke & Ink/Text | Outlines, text | `#0A0A0A` |
| Paper | Background | `#FFF8EC` |
| Card/Highlight | The current player's card fill (Waiting Room); fixed in both appearances, since the card's text stays black | `#FFF8EC` |

Define these as named Color assets/tokens (Assets.xcassets color sets or a `Color` extension). Add sensible Dark Mode variants even though the source design is Light Mode only — the source spec does not define them, so choose values that preserve contrast and brand identity rather than inverting mechanically.

## Typography

Font family is **Almarai** throughout (Arabic-first UI). All line-heights are 100%.

| Token | Weight | Size |
|---|---|---|
| Display/Logo | ExtraBold | 78pt |
| Display/CTA | Bold | 30pt |
| CTA/Tertiary (Home "كيف تلعب؟") | Bold | 20pt |
| Title/Screen | ExtraBold | 20pt |
| Title/Card | ExtraBold | 16pt |
| Label/Section | ExtraBold | 14pt |
| Label/Chip | ExtraBold | 12–13pt |
| Body/Meta | Light (300) | 11–12pt, color `rgba(0,0,0,0.55)` |
| Body/Regular | Regular | 11–13pt |
| Body/Small (How to Play card descriptions & points bar; Enter Name owner caption & count footer at `rgba(0,0,0,0.45)`) | Regular | 11pt |
| Body/Meta Small (Create Room pill captions) | Light (300) | 11pt, color `rgba(0,0,0,0.55)` |
| Input/Text (Create Room name field & avatar initial) | ExtraBold | 22pt |
| Label/Group (Create Room section labels) | ExtraBold | 15pt |
| Pill/Value (Create Room pill numbers) | ExtraBold | 24pt |
| Display/CTA Heavy (Create Room submit) | ExtraBold | 30pt |
| Code/Digit (Join Room code boxes) | ExtraBold | 32pt |
| Label/Prompt (Join Room "أدخل رمز الغرفة") | ExtraBold | 17pt |
| Message/Banner (Join Room error banner) | ExtraBold | 12pt |
| Body/Strong (Join Room card subtitle & message) | Bold | 12pt |
| Badge/Mono (Join Room "6/6" badge) | SF Mono Heavy | 18pt |
| Avatar/Initial Small (Enter Name player-list avatars) | ExtraBold | 13pt |
| Numeric/Mono (room code & timer only) | Bold, or SF Mono Heavy | 20/16pt, or 17pt (SF Mono Heavy) |

The Waiting Room adds no font token: it reuses Label/Section (avatar initials, "نسخ", the ready count and "مدة الجولة"), Message/Banner ("جاهز"), Body/Small (captions, "في الانتظار", "بانتظار لاعب"), Body/Meta (the auto-start caption), Input/Text (the compact duration pills), Title/Screen (footer buttons) and Title/Card (player names).

Map each token to Dynamic Type where possible for accessibility, without breaking these exact sizes/weights.

## Spacing

Strict 8pt grid (Apple HIG). Never use odd values (7, 9, 11, 13, 18, 22).

- Base unit scale: 4, 8, 12, 16, 20, 24, 32, 48
- Within an element: 8pt
- Between related elements: 12–16pt
- Between groups: 24–32pt

## Tap Targets (non-negotiable, Apple HIG)

- Prominent CTA height: 50pt
- Standard control height: 44pt minimum
- Icon button: 44×44pt minimum
- Anything under 44pt must be **display-only, never tappable** (e.g. a 32pt chip is fine, a 32pt button is not)
- Adjacent tap targets must be ≥8pt apart

## Corner Radii

Continuous/squircle style in SwiftUI (`.continuous` corner style), not perfect circles. Exception: the Home screen's buttons, dashed button and ellipsis badge use `.circular` 14–15pt corners — that is what the Home mockup measures.

| Element | Radius |
|---|---|
| Tile & chip | 8pt |
| Button & input | 12pt |
| Card & sheet | 16pt |
| Large card | 20pt |
| Device frame | 26pt |

## Shadows & Strokes

Brand style — keep as-is, these are **not** HIG-governed.

- Strokes: 2/3/4pt
- Hard offset shadow, never blurred: `(6,4)` for primary elements, `(4,4)` elsewhere
- On press: shadow drops to 0 and the element shifts 3pt

## Components

Measured sizes of the reusable pieces, beyond the tokens above (all `.circular` corners, ink border, hard black shadow unless noted).

| Component | Size | Radius | Stroke | Shadow |
|---|---|---|---|---|
| Selectable pill, regular (Create Room) | width × 64 | 14pt | 4pt | (5,5) |
| Selectable pill, compact (Waiting Room duration) | 49 × 44 | 11pt | 3pt | (3,3) |
| Lobby action (Waiting Room start / ready toggle) | 192 × 53 | 16pt | 3pt | (3,3) |
| Header icon (Waiting Room kebab) | 44 × 44 | 13pt | 3pt | (3,3) |
| Copy chip (Waiting Room "نسخ") | 83 × 44 | 20pt | 3pt | (3,3) |
| Avatar, medium (Waiting Room player card) | 36pt circle | — | 3pt | none |
| Player card (Waiting Room) | 242 × 89 | 14pt | 4pt (Brand/Yellow on your own card) | (5,5) |
| Remove button (Waiting Room) | 39 × 39 visual, 44 × 44 hit area | 11pt | 3pt Brand/Red on Tint/Red | none |
| Ready status pill | 63 × 30 capsule | — | 2pt ink (ready) / 2pt dashed Locked/Text (waiting) | none |

The copy chip's burst is a vector (`CopyBurstIcon`, 22 × 18): a 12-point Brand/Yellow star with a 0.75pt ink outline and a Brand/Lime oval, not an image asset.

## Safe Areas & Layout

- Respect iOS safe area insets on all sides.
- Landscape on notched iPhones: keep 48pt clear left/right (sensor housing) + 16pt content margin (64pt total from the physical edge); clear the home indicator area at the bottom.
- Layout direction is **RTL** (right-to-left) throughout — mirror all layouts correctly for Arabic; back button top-right; badges/pins anchor to the outer corner (left, in RTL).
