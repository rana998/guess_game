# Design System

Extracted from the Figma spec. Use these exact values for all UI/frontend work — don't approximate from screenshots or mockup images.

## Colors

| Token | Role | Hex |
|---|---|---|
| Brand/Lime | Primary, main concept | `#5CD62B` |
| Brand/Red | Danger, sub-concept | `#EE1C25` |
| Brand/Yellow | Accent, celebrate | `#FFE300` |
| Ink/Stroke & Ink/Text | Outlines, text | `#0A0A0A` |
| Paper | Background | `#FFF8EC` |

Define these as named Color assets/tokens (Assets.xcassets color sets or a `Color` extension). Add sensible Dark Mode variants even though the source design is Light Mode only — the source spec does not define them, so choose values that preserve contrast and brand identity rather than inverting mechanically.

## Typography

Font family is **Almarai** throughout (Arabic-first UI). All line-heights are 100%.

| Token | Weight | Size |
|---|---|---|
| Display/Logo | ExtraBold | 78pt |
| Display/CTA | ExtraBold | 30pt |
| Title/Screen | ExtraBold | 20pt |
| Title/Card | ExtraBold | 16pt |
| Label/Section | ExtraBold | 14pt |
| Label/Chip | ExtraBold | 12–13pt |
| Body/Meta | Light (300) | 11–12pt, color `rgba(0,0,0,0.55)` |
| Body/Regular | Regular | 11–13pt |
| Numeric/Mono (room code & timer only) | Bold, or SF Mono Heavy | 20/16pt, or 17pt (SF Mono Heavy) |

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

Continuous/squircle style in SwiftUI (`.continuous` corner style), not perfect circles.

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

## Safe Areas & Layout

- Respect iOS safe area insets on all sides.
- Landscape on notched iPhones: keep 48pt clear left/right (sensor housing) + 16pt content margin (64pt total from the physical edge); clear the home indicator area at the bottom.
- Layout direction is **RTL** (right-to-left) throughout — mirror all layouts correctly for Arabic; back button top-right; badges/pins anchor to the outer corner (left, in RTL).
