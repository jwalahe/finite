# Finite — Craft Specification

> Supplement to PRD.md — Technical parameters for premium execution  
> **Version:** 1.2.0
> **Last Updated:** December 17, 2024

---

## Purpose

This document translates design intent into precise technical specifications. Use alongside PRD.md when implementing any interaction.

---

## 1. Emotional Tone Definition

**Finite's personality in three words:** Stark. Weighty. Contemplative.

**Tone calibration (reference table):**

| Element | Finite's Choice | Rationale |
|---------|-----------------|-----------|
| Color | Muted, limited palette | Serious, not playful |
| Typography | Clean SF Pro, limited weights | Clarity over personality |
| Animation | Subtle, purposeful | Gravity without sluggishness |
| Spacing | Generous negative space | Room for contemplation |
| Illustrations | None | Content IS the visualization |
| Haptics | Minimal, precise | Confirming, not celebrating |
| Sounds | Rare, significant | Only for the reveal |

**What Finite is NOT:**
- Not warm/encouraging like Fabulous
- Not playful/fun like Duolingo
- Not celebratory like Apple Fitness
- Not clinical/cold like a medical app

**Closest reference:** Things 3's calm precision, but with more existential weight.

---

## 2. Animation Specifications

### Global Animation Parameters

| Interaction Type | Duration | Spring Bounce | Easing | Notes |
|------------------|----------|---------------|--------|-------|
| Button tap | 0.12s | 0 | `.snappy` | Scale to 0.96x |
| Toggle switch | 0.22s | 0.15 | `.smooth` | Color/position change |
| Bottom sheet present | 0.35s | 0 | `.smooth` | Slide up with dim |
| Bottom sheet dismiss | 0.25s | 0 | `.smooth` | Faster exit |
| Week cell fill | 0.08s | 0 | — | During reveal cascade |
| Week cell mark | 0.25s | 0.15 | `.snappy` | Color bloom |
| Current week pulse | 2.0s | — | `.easeInOut` | Scale 1.0 → 1.08 → 1.0, repeat |
| View mode swipe | 0.2s | 0 | `.easeOut` | Crossfade between color schemes |
| Mode label flash | 0.8s | 0 | `.easeOut` | Appear, hold, fade |
| Ghost number summon | 0.2s | 0 | `.easeOut` | 8% → 100% opacity |
| Ghost number fade | 0.3s | 0 | `.easeOut` | 100% → 8% opacity |
| Breathing Aura shift | 0.5s | 0 | `.easeInOut` | Phase color transition |
| Spine label appear | 0.15s | 0.1 | `.snappy` | Scale + fade in |
| Spine label dismiss | 0.2s | 0 | `.easeOut` | Fade out |
| Phase highlight dim | 0.25s | 0.1 | `.snappy` | Dim non-phase weeks |
| Phase highlight undim | 0.2s | 0 | `.easeOut` | Restore full opacity |
| Loupe appear | 0.15s | 0.1 | `.snappy` | Scale + fade in |
| Loupe dismiss | 0.1s | 0 | `.easeOut` | Scale + fade out |
| Header crossfade | 0.2s | 0 | `.easeOut` | Mode-specific header |
| Spectrum slider thumb | 0.1s | 0.2 | `.snappy` | Snap to notch |
| Modal present | 0.3s | 0.1 | `.smooth` | Slide up from bottom |
| Year wheel scroll | — | 0.15 | `.smooth` | Native picker feel |

### SwiftUI Implementation

```swift
// Button tap
.scaleEffect(isPressed ? 0.96 : 1.0)
.animation(.snappy(duration: 0.12), value: isPressed)

// Toggle
.animation(.smooth(duration: 0.22), value: isOn)

// Bottom sheet
.animation(.smooth(duration: 0.35), value: isPresented)

// Week mark bloom
.animation(.snappy(duration: 0.25, extraBounce: 0.15), value: isMarked)

// Current week pulse
.scaleEffect(isPulsing ? 1.08 : 1.0)
.animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isPulsing)

// View mode crossfade
.animation(.easeOut(duration: 0.2), value: currentViewMode)

// Mode label flash
.opacity(showModeLabel ? 1.0 : 0.0)
.animation(.easeOut(duration: 0.8), value: showModeLabel)

// Phase highlight dim
.overlay(dimOverlay)
.animation(.snappy(duration: 0.25, extraBounce: 0.1), value: highlightedPhase)

// Loupe appear
.scaleEffect(loupeState.isActive ? 1.0 : 0.8)
.opacity(loupeState.isActive ? 1.0 : 0.0)
.animation(.snappy(duration: 0.15, extraBounce: 0.1), value: loupeState.isActive)
```

### The Reveal Animation (Signature Moment)

The reveal is Finite's signature. It must be unforgettable.

**Sequence:**
```
T+0ms:      Screen transitions to empty grid
T+500ms:    Beat of silence (anticipation)
T+500ms:    First week fills
T+510ms:    Second week fills
...         Continue at ~50 weeks/second (20ms per week)
            Pencil SFX plays continuously (soft, scratching)
T+every 52 weeks: Haptic thud (.medium) at year boundaries
T+~30s:     Fill reaches current week
T+30.1s:    Heavy haptic thud (.heavy)
T+30.2s:    Current week begins pulsing
T+30.5s:    Pencil SFX fades out
T+31.5s:    Phase prompt modal slides up
```

**Technical parameters:**
- Fill rate: 20ms per week (50 weeks/second)
- Total duration for 29 years: ~30 seconds
- Year boundary haptic: `.medium` impact
- Final haptic: `.heavy` impact
- Pulse begins 100ms after final fill
- Sound: Soft pencil/graphite scratching, volume 0.3, fade out over 500ms
- Phase prompt: 1 second after pulse begins

**Why this timing:** Fast enough to feel like time flying by, slow enough to comprehend the accumulation. The year-boundary haptics create rhythm without overwhelming. The final heavy thud signals "you are here."

---

## 3. Haptic Specifications

### Haptic Palette

| Interaction | Generator | Style | Timing |
|-------------|-----------|-------|--------|
| Button tap | Impact | `.light` | On press start |
| Toggle | Impact | `.medium` | On state change |
| Long press recognized | Impact | `.light` | At 200ms threshold |
| Spectrum slider notch | Selection | — | On each notch |
| Category select | Impact | `.light` | On selection |
| Week mark confirm | Impact | `.medium` | On sheet dismiss |
| Year boundary (reveal) | Impact | `.medium` | When year completes |
| Reveal complete | Impact | `.heavy` | Single thud |
| View mode swipe | Impact | `.light` | On mode change |
| Year wheel tick | Selection | — | On year change |
| Phase add confirm | Impact | `.medium` | On "Add Chapter" |
| Time Spine tap | Impact | `.light` | On phase tap |
| Phase highlight (spine) | Impact | `.light` | On spine tap |
| Loupe activate | Impact | `.light` | At 300ms threshold |
| Loupe week hover | Selection | — | On week change while dragging |
| Loupe release | Impact | `.medium` | On week selection |
| Direct week tap | Impact | `.light` | On Quality mode tap |
| Ghost number summon | Impact | `.light` | On tap to reveal |
| Error | Notification | `.error` | On validation fail |

### Implementation

```swift
// Create generators once, reuse
let lightImpact = UIImpactFeedbackGenerator(style: .light)
let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
let selectionFeedback = UISelectionFeedbackGenerator()
let notificationFeedback = UINotificationFeedbackGenerator()

// Prepare before use (reduces latency)
lightImpact.prepare()

// Trigger
lightImpact.impactOccurred()
selectionFeedback.selectionChanged()
notificationFeedback.notificationOccurred(.error)
```

### Haptic Rules for Finite

1. **Never on scroll** — No haptic feedback while scrolling the grid
2. **Prepare before trigger** — Call `.prepare()` when interaction is anticipated
3. **Align with visual** — Haptic fires at moment of visual state change, not before
4. **Restrained by default** — When in doubt, omit the haptic
5. **Meaningful only** — Every haptic should confirm a state change or action

---

## 4. Spacing System

### Base Unit: 8pt

All spacing values must be multiples of 8pt.

| Token | Value | Use |
|-------|-------|-----|
| `spacing-xs` | 4pt | Exception only (tight icon padding) |
| `spacing-sm` | 8pt | Related elements |
| `spacing-md` | 16pt | Section internal padding |
| `spacing-lg` | 24pt | Screen edge margins |
| `spacing-xl` | 32pt | Section separation |
| `spacing-2xl` | 48pt | Major section breaks |

### Touch Targets

- Minimum: 44×44pt (Apple HIG)
- Preferred: 48×48pt
- Grid cells: Can be smaller visually, but tap target extends to 44pt
- Year wheel rows: 44pt height minimum

### Screen Layout

```
┌─────────────────────────────────────┐
│← 24pt →                    ← 24pt →│  Screen margins
│                                     │
│  ┌─────────────────────────────┐   │
│  │       Content Area          │   │
│  │                             │   │
│  │  Elements: 16pt internal    │   │
│  │  Groups: 8pt between items  │   │
│  │  Sections: 32pt separation  │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│← Safe area respected at all edges →│
└─────────────────────────────────────┘
```

---

## 5. Typography Scale

### Type Ramp (SF Pro)

| Style | Size | Weight | Line Height | Use |
|-------|------|--------|-------------|-----|
| `title-lg` | 34pt | Bold | 41pt | Screen titles |
| `title-md` | 28pt | Bold | 34pt | Section headers |
| `title-sm` | 22pt | Semibold | 28pt | Card titles |
| `body` | 17pt | Regular | 22pt | Primary content |
| `body-emphasis` | 17pt | Semibold | 22pt | Emphasized body |
| `caption` | 13pt | Regular | 18pt | Secondary info |
| `caption-sm` | 11pt | Regular | 13pt | Tertiary info |
| `mode-label` | 15pt | Medium | 20pt | View mode flash label |

### Type Rules

1. Maximum 4 sizes per screen
2. Never use more than 2 weights per screen
3. Title case for titles, sentence case for body
4. No ALL CAPS except for very short labels (2-3 words max)

---

## 6. Color Specifications

### Light Mode

| Token | Hex | RGB | Use |
|-------|-----|-----|-----|
| `bg-primary` | #FAFAFA | 250,250,250 | Screen background |
| `bg-secondary` | #F5F5F5 | 245,245,245 | Card background |
| `bg-tertiary` | #EFEFEF | 239,239,239 | Grouped sections |
| `text-primary` | #1A1A1A | 26,26,26 | Primary text |
| `text-secondary` | #6B6B6B | 107,107,107 | Secondary text |
| `text-tertiary` | #9A9A9A | 154,154,154 | Placeholder, disabled |
| `border` | #E5E5E5 | 229,229,229 | Dividers, outlines |

### Dark Mode

| Token | Hex | RGB | Use |
|-------|-----|-----|-----|
| `bg-primary` | #0A0A0A | 10,10,10 | Screen background |
| `bg-secondary` | #1C1C1E | 28,28,30 | Card background |
| `bg-tertiary` | #2C2C2E | 44,44,46 | Grouped sections |
| `text-primary` | #F5F5F5 | 245,245,245 | Primary text |
| `text-secondary` | #8E8E93 | 142,142,147 | Secondary text |
| `text-tertiary` | #636366 | 99,99,102 | Placeholder, disabled |
| `border` | #38383A | 56,56,58 | Dividers, outlines |

### Grid Colors — Focus Mode (B&W)

| Token | Light Mode | Dark Mode | Use |
|-------|------------|-----------|-----|
| `week-empty` | #E0E0E0 | #3A3A3A | Unfilled weeks |
| `week-filled` | #2A2A2A | #E5E5E5 | Filled weeks |
| `week-current` | #1A1A1A | #FFFFFF | Current week (with pulse) |

### Grid Colors — Quality Mode (Spectrum)

| Rating | Label | Hex | Use |
|--------|-------|-----|-----|
| 1 | Awful | #DC2626 | Deep red |
| 2 | Hard | #EA580C | Orange |
| 3 | Okay | #D97706 | Amber |
| 4 | Good | #65A30D | Soft green |
| 5 | Great | #16A34A | Deep green |

### Grid Colors — Chapters Mode (Phase Colors)

| Phase Type | Hex | Notes |
|------------|-----|-------|
| Childhood | #78716C | Warm gray |
| School | #6366F1 | Slate blue |
| College | #4F46E5 | Indigo |
| Early Career | #0D9488 | Teal |
| Career | #059669 | Emerald |
| Custom 1 | #9333EA | Purple |
| Custom 2 | #E11D48 | Rose |
| Custom 3 | #0284C7 | Sky |

Auto-assignment order: Colors assigned in sequence as phases are created. User can change any phase color in Settings.

### Color Rules

1. Never use pure black (#000000) or pure white (#FFFFFF) for backgrounds
2. Spectrum colors are for Quality mode week fills only
3. Phase colors are for Chapters mode week fills only
4. Focus mode uses only B&W palette
5. Maintain WCAG AA contrast (4.5:1) for all text

---

## 7. Component Specifications

### Header Per View Mode

```
┌─────────────────────────────────────┐
│                                     │
│           finite                    │  ← App title (always visible)
│           College                   │  ← Subtitle (varies by mode)
│                                     │
└─────────────────────────────────────┘

View-specific subtitles:
- Chapters: Current phase name (e.g., "College", "Career")
           If no current phase: "Chapters" in tertiary color
- Quality: "2,647 weeks remaining" countdown
- Focus: Empty (no subtitle shown)

Title styling:
- App name: body, text-primary
- Subtitle: caption, text-secondary (or text-tertiary if no phase)

Behavior:
- Crossfade between subtitles when mode changes (0.2s)
- Subtitle updates in real-time as user scrolls through phases
```

### Week Cell

```
┌───────┐
│   ●   │  Filled state: solid circle
│       │  Empty state: stroke circle
└───────┘

Visual size: 6pt diameter
Tap target: 44pt × 44pt (invisible, centered on visual)
Stroke width (empty): 1pt
Corner radius: 50% (circle)

States:
- Empty: stroke only, week-empty color
- Filled (Focus): solid fill, week-filled color
- Filled (Quality): solid fill, spectrum color based on rating
- Filled (Chapters): solid fill, phase color
- Current: filled + pulse animation
- Tapped: scale 0.9x for 100ms, then expand to detail
```

### View Mode Indicator (Dot Indicator)

```
    ● ○ ○           ○ ● ○           ○ ○ ●
  Chapters        Quality          Focus

Dot size: 8pt diameter
Spacing between dots: 8pt
Active dot: text-primary color
Inactive dot: text-tertiary color
Position: Bottom center of grid, 16pt above safe area
Transition: Crossfade 0.2s when mode changes
```

### Time Spine (Chapters View Only)

```
┌──┬──────────────────────────────────┐
│██│  Grid                            │
│██│                                  │  ← Childhood (warm gray)
│▓▓│                                  │
│▓▓│                                  │  ← College (indigo)
│▓▓│                                  │
│░░│                                  │  ← Career (teal)
│░░│◉                                 │  ← Current position
│  │                                  │  ← Future (empty)
└──┴──────────────────────────────────┘

Visual width: 12pt
Tap target width: 44pt (extends invisibly into grid area)
Position: Left edge, full height of grid
Segments: Proportionally sized to phase duration in weeks

Colors: Match phase colors from Phase Colors palette
Current position marker: Small notch or line indicating current week
Future area: bg-tertiary or empty

Interaction:
- Tap anywhere on spine (44pt zone)
- Floating label appears next to tap point:
  ┌─────────────────┐
  │ College         │
  │ 2014-2018       │
  └─────────────────┘
- Label: bg-secondary background, 8pt padding, 6pt corner radius
- Phase name: body-emphasis
- Date range: caption, text-secondary
- Dismiss: after 2s, or on next tap, or on scroll
- Haptic: .light on tap
```

### Breathing Aura (Chapters View Only)

```
┌─────────────────────────────────────────┐
│ ░░░                               ░░░   │  ← Subtle edge glow
│ ░░                                 ░░   │
│ ░                                   ░   │
│                                         │
│              [Grid]                     │
│                                         │
│ ░                                   ░   │
│ ░░                                 ░░   │
│ ░░░                               ░░░   │
└─────────────────────────────────────────┘

Effect: Radial gradient at screen edges
Color: Current phase color at 15% opacity
Radius: 80pt from each edge
Blend mode: Normal (or Soft Light for subtlety)

Behavior:
- Color shifts as user scrolls through different phases
- Transition: 0.5s ease-in-out when phase changes
- Should feel ambient, not attention-grabbing
```

### Magnification Loupe (Quality View Only)

```
┌─────────────────────────────────────────┐
│                                         │
│         ┌─────────────┐                 │  ← Loupe floats above finger
│         │  ●  ●  ●    │                 │
│         │  ●  ◎  ●    │  80pt radius    │  ◎ = highlighted week
│         │  ●  ●  ●    │  1.5x magnified │
│         └─────────────┘                 │
│                                         │
│              [Grid]                     │
│                👆                        │  ← User's finger (long press)
│                                         │
└─────────────────────────────────────────┘

Technical specifications:
- Loupe radius: 80pt
- Magnification: 1.5x
- Border: 2pt, bg-secondary color
- Shadow: black 20% opacity, 12pt blur, 4pt y-offset
- Position: Centered above touch point, 20pt gap from finger

Activation:
- Trigger: Long press 300ms on grid
- Appear animation: 0.15s snappy with slight bounce
- Haptic: .light on activation

During drag:
- Loupe follows finger position
- Magnified view updates in real-time
- Highlighted week shown with weekCurrent color ring (2pt stroke)
- Haptic: selection feedback on each week change

Release:
- If over valid week: Opens week detail sheet
- Haptic: .medium on selection
- Dismiss animation: 0.1s ease-out

Rendering:
- Use Canvas for performance
- Clip to circular shape
- Draw magnified versions of nearby week cells
- Only show weeks within loupe bounds
```

### Ghost Number (Focus View Only)

```
┌─────────────────────────────────────────┐
│                                         │
│              [Grid]                     │
│                                         │
│                                         │
│              2,647                      │  ← 8% opacity (ghost state)
│                                         │
│              ● ○ ○                      │
└─────────────────────────────────────────┘

Default state:
- Number: weeks remaining
- Font: title-lg (34pt Bold)
- Color: text-primary at 8% opacity
- Position: Centered, above dot indicator

Summoned state (after tap):
- Opacity animates: 8% → 100% over 0.2s
- Holds at 100% for 2s
- Fades: 100% → 8% over 0.3s
- Haptic: .light on summon

Interaction:
- Tap anywhere on empty grid space (not on weeks)
- Tap target: Full grid area excluding week cells

Animation implementation:
```swift
// Ghost number state
@State private var numberOpacity: Double = 0.08

// Tap gesture on grid background
.onTapGesture {
    summonNumber()
}

func summonNumber() {
    lightImpact.impactOccurred()
    withAnimation(.easeOut(duration: 0.2)) {
        numberOpacity = 1.0
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        withAnimation(.easeOut(duration: 0.3)) {
            numberOpacity = 0.08
        }
    }
}
```
```

### Phase Highlight (Chapters View Only)

```
Normal state:                       Highlighted state (spine tapped):
┌──┬──────────────────────┐        ┌──┬──────────────────────┐
│██│ ● ● ● ● ● ● ● ● ● ● │        │██│ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ │  ← Dimmed (30%)
│██│ ● ● ● ● ● ● ● ● ● ● │        │██│ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ │
│▓▓│ ● ● ● ● ● ● ● ● ● ● │ ← tap  │▓▓│ ● ● ● ● ● ● ● ● ● ● │  ← Full opacity
│▓▓│ ● ● ● ● ● ● ● ● ● ● │        │▓▓│ ● ● ● ● ● ● ● ● ● ● │
│░░│ ● ● ● ● ● ● ● ● ● ● │        │░░│ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ │  ← Dimmed (30%)
└──┴──────────────────────┘        └──┴──────────────────────┘

Interaction:
1. User taps a phase segment on Time Spine
2. All weeks OUTSIDE that phase dim to 30% opacity
3. Weeks INSIDE the tapped phase remain at full opacity
4. Floating label appears showing phase name and date range
5. Auto-dismiss after 3 seconds, or on grid tap

Implementation:
- Overlay Canvas draws bg-primary at 70% opacity on non-phase weeks
- Animation: 0.25s snappy on highlight, 0.2s ease-out on dismiss
- Haptic: .light on spine tap

Use case:
- Helps user focus on a specific life chapter
- Visual isolation without navigation
- Encourages reflection on bounded time periods
```

### Phase Context Bar (Chapters Footer)

```
┌─────────────────────────────────────────┐
│                                         │
│              [Grid]                     │
│                                         │
│  ━━━━━━━━━━━━━━━━●━━━━━━━━━━━━━━━━━    │  ← Progress bar (phase color)
│           3 years in Career             │  ← Context label
│                                         │
│              ○ ● ○                      │  ← Dot indicator
└─────────────────────────────────────────┘

Progress bar:
- Track: bg-tertiary, 6pt height, 3pt corner radius
- Fill: Current phase color, proportional to progress within phase
- Animation: 0.2s ease-out on progress change

Context label:
- Font: 12pt medium
- Color: text-secondary
- Format options:
  - "X years in [Phase]" — if phase is ongoing
  - "Year X of Y" — if phase has defined end
  - "No chapter defined" — if current week has no phase

Position:
- Below grid, above dot indicator
- Horizontal padding: 24pt (screen margins)
- Replaces generic "X lived / Y remaining" footer for Chapters view
```

### Footer by View Mode (Summary)

| View | Left Edge | Footer Center | Behavior |
|------|-----------|---------------|----------|
| Chapters | Time Spine (12pt) | Phase Context Bar + Dot indicator | Breathing Aura on edges |
| Quality | None | Dot indicator | Direct tap or long-press loupe for selection |
| Focus | None | Ghost number + Dot indicator | Tap to summon number |

### View Mode Label (Flash)

```
┌─────────────────────────────────────────┐
│                                         │
│              "Quality"                  │  ← Centered, fades after 0.8s
│                                         │
│              ○ ● ○                      │
└─────────────────────────────────────────┘

Font: mode-label (15pt Medium)
Color: text-primary
Background: bg-primary with 80% opacity, 8pt padding, 6pt corner radius
Animation: Fade in 0.1s, hold 0.5s, fade out 0.2s
```

### Swipe View Toggle

```
Gesture: Horizontal swipe on grid area
Direction:
  - Swipe left: Next mode (Chapters → Quality → Focus → Chapters)
  - Swipe right: Previous mode (Focus → Quality → Chapters → Focus)
Threshold: 50pt horizontal movement
Animation: Grid crossfades between color schemes (0.2s)
Feedback:
  - Mode label flashes
  - Dot indicator updates
  - Light haptic on change
First-time hint: "← Swipe to change view →" appears once, fades after 3s
```

### Week Selection by View Mode

**Philosophy:** Intentionality over convenience. Each view mode has a purpose-built selection model that reinforces its character.

```
┌────────────┬─────────────────────┬──────────────────────────────────┐
│ View Mode  │ Selection Method    │ Behavior                         │
├────────────┼─────────────────────┼──────────────────────────────────┤
│ Chapters   │ Spine → Week        │ Tap spine to highlight phase,    │
│            │                     │ then tap week within phase       │
│            │                     │ → Opens week detail sheet        │
├────────────┼─────────────────────┼──────────────────────────────────┤
│ Quality    │ Direct tap OR       │ Single tap: Opens week detail    │
│            │ Long-press loupe    │ Long-press: Magnification loupe  │
│            │                     │ for precise selection            │
├────────────┼─────────────────────┼──────────────────────────────────┤
│ Focus      │ Disabled            │ No selection allowed.            │
│            │                     │ Focus mode is for viewing only.  │
└────────────┴─────────────────────┴──────────────────────────────────┘

Design rationale:
- NO global navigation slider — forces engagement with the grid itself
- Chapters requires two-step selection — reinforces chapter context
- Quality has direct access — this is the active reflection mode
- Focus blocks selection — this view is for contemplation, not action
- Long-press loupe for precision — small cells demand intentional gesture
```

### Spectrum Slider

```
┌─────────────────────────────────────────────┐
│  ●────────────●────────────●────────────●────────────●  │
│  Awful       Hard        Okay        Good       Great   │
└─────────────────────────────────────────────┘

Track height: 6pt
Track corner radius: 3pt
Track background: gradient from #DC2626 to #16A34A
Thumb size: 28pt diameter
Thumb color: white with subtle shadow
Notch positions: 0%, 25%, 50%, 75%, 100%
Snap behavior: thumb snaps to nearest notch with selection haptic

Shadow (thumb):
  - Color: black 15% opacity
  - Offset: 0pt x 2pt
  - Blur: 4pt
```

### Category Icons

```
┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐
│  💼  │ │  ❤️  │ │  📚  │ │  👥  │ │  🌙  │ │  🧭  │
│ Work │ │Health│ │Growth│ │ Rel. │ │ Rest │ │Advent│
└──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘

Icon size: 24pt (SF Symbol)
Touch target: 48pt × 48pt
Spacing between: 12pt
Unselected: text-secondary color, no background
Selected: text-primary color, bg-secondary circle behind

Selection animation:
  - Scale: 1.0 → 1.1 → 1.0 over 0.2s
  - Haptic: .light impact
```

### Bottom Sheet

```
┌─────────────────────────────────────────────┐
│                 ───────                      │  Grab handle: 36pt × 5pt, corner radius 2.5pt
│                                             │
│  Week 1,547                                 │  title-sm, text-primary
│  December 9–15, 2024                        │  caption, text-secondary
│                                             │
│  [═══════════════●═══════════]              │  Spectrum slider
│  Awful   Hard   Okay   Good   Great         │  caption-sm, text-tertiary
│                                             │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ │  Category icons
│  │    │ │    │ │    │ │    │ │    │ │    │ │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘ │
│                                             │
│  ┌─────────────────────────────────────┐   │  Phrase input
│  │ One line about this week...         │   │  
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │              Done                    │   │  Primary button
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘

Sheet height: ~55% of screen
Background: bg-primary with top corner radius 16pt
Dim overlay: black 40% opacity
Present animation: 0.35s ease-out
Dismiss: swipe down or tap Done
```

### Phase Prompt Modal

```
┌─────────────────────────────────────────────┐
│                                             │
│                                             │
│         Your past is empty.                 │  title-md, text-primary, centered
│         Add life chapters?                  │  body, text-secondary, centered
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │        Yes, add chapters            │   │  Primary button
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │           Skip for now              │   │  Secondary button (text only)
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘

Position: Centered modal with dim background
Background: bg-primary, corner radius 16pt
Dim overlay: black 50% opacity
Present: 1s after Reveal completes
Animation: Slide up 0.3s with slight bounce
```

### Phase Builder

```
┌─────────────────────────────────────────────┐
│  [Grid preview - mini version]              │
│  ▪▪▪▪▪▪▪▪▪▪████████████████▪▪▪▪▪▪▪▪▪▪     │  Selected range highlighted
│  ▪▪▪▪▪▪▪▪▪▪████████████████▪▪▪▪▪▪▪▪▪▪     │
│─────────────────────────────────────────────│
│                                             │
│  Chapter name                               │  caption, text-secondary
│  ┌─────────────────────────────────────┐   │
│  │ College                              │   │  TextField, body
│  └─────────────────────────────────────┘   │
│                                             │
│        From              To                 │  caption, text-secondary
│    ┌─────────┐      ┌─────────┐            │
│    │  2013   │      │  2017   │            │  Year wheel pickers
│    │ >2014<  │      │ >2018<  │            │  Selected year emphasized
│    │  2015   │      │  2019   │            │
│    └─────────┘      └─────────┘            │
│                                             │
│  How was it overall?                        │  caption, text-secondary
│           ○ ○ ● ○ ○                        │  Rating dots (optional)
│           1 2 3 4 5                         │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │           Add Chapter               │   │  Primary button
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘

Grid preview: ~30% of screen height, live updates as years change
Year wheels: Native Picker style, haptic on year change
Rating: Optional, defaults to middle (3) if not changed
```

### Phase Confirmation Screen

```
┌─────────────────────────────────────────────┐
│                                             │
│  ✓ Added "College" (2014-2018)              │  body-emphasis, text-primary
│                                             │
│  |░░░░░░░░░░░░|████|░░░░░░░|               │  Timeline visualization
│  1995       2014  2018    2025              │  caption-sm, text-tertiary
│                                             │
│  19 years before. 7 years after.            │  body, text-secondary
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │           Add another               │   │  Primary button
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │          Done for now               │   │  Secondary button (text only)
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘

Timeline bar:
  - Total width: screen width - 48pt (margins)
  - Height: 8pt
  - Corner radius: 4pt
  - Unfilled sections: bg-tertiary
  - Filled section: phase color
Year labels: caption-sm, positioned at start, phase boundaries, end
```

---

## 8. State Specifications

Every screen has 5 states. All must be designed.

### Loading State

- Use skeleton shimmer, not spinner
- Shimmer: left-to-right wave, 1.5s duration, repeat
- Skeleton matches layout shape

### Empty State

**Grid (no weeks marked):**
- Show full grid with all weeks empty
- Current week pulses
- No placeholder text needed — the empty grid IS the state

**Grid with phases but no marks:**
- Phases show in Chapters mode
- Quality mode shows empty (no ratings yet)
- Focus mode shows B&W

### Error State

- Horizontal shake: 3 oscillations, 0.15s each
- Haptic: `.error` notification
- Color: text turns `#DC2626` briefly
- Recovery: clear error after 2s or on user action

### Success State

- Scale: 1.0 → 1.1 → 1.0 over 0.3s
- Haptic: `.success` notification (only for significant actions)
- For week marking: color bloom is the success feedback
- For phase adding: checkmark + timeline update

### Partial State

- Grid with some weeks marked, some empty
- Phases partially covering life
- No special treatment — this is the normal state

---

## 9. The Signature: What Makes Finite Finite

### Primary Signature: The Reveal

The first time a user sees their life visualized is the signature moment. It must create an emotional "oh" — the gut punch of mortality made visible.

**What makes it signature:**
- Not instant (takes ~30 seconds — time has weight)
- Not silent (pencil sound makes it feel like drawing your life)
- Not smooth (year-boundary haptics create rhythm of years passing)
- Not passive (the grid is being drawn FOR you)

**Implementation priority:** This is the most important 30 seconds of the app. Spend disproportionate time on it.

### Secondary Signature: The Mark

Each weekly marking should feel like a small ritual, not a checkbox.

**What makes it signature:**
- Long press, not tap (intentionality required)
- Spectrum forces reflection (you can't mark neutral)
- Color bloom on confirm (the week takes on meaning)
- Single category (what DEFINED this week?)

### Tertiary Signature: The Three Lenses

The swipe between view modes reinforces the philosophical core.

**What makes it signature:**
- Same data, three perspectives (chapters of life, quality of moments, raw mortality)
- Gesture is perspective shift, not navigation
- Focus mode strips away color — just you and the countdown
- No labels needed on grid — the mode tells the story

**Each view has its own personality:**
- **Chapters:** Time Spine + Breathing Aura — your life as colored story
- **Quality:** Edit button — active reflection mode
- **Focus:** Ghost number — mortality lurks, summon it when ready

### Quaternary Signature: The Ghost Number

The remaining weeks are always present at 8% opacity. Subliminal. You feel it more than see it. Tap to confront it directly—it rises, holds, then recedes back into the background.

*The truth is always there. You choose when to look.*

### What Finite Will NOT Do

- No streaks (trivializes reflection)
- No badges (gamification inappropriate)
- No celebrations (sobriety about mortality)
- No sharing prompts (this is private)
- No AI suggestions (this is human reflection) — *Note: V1.5 will add optional AI insights*
- No push notification spam (one number, that's it)

---

## 10. Quality Checklist

Before any PR, verify:

### Animation
- [ ] All interactive elements have visual feedback
- [ ] Animation durations match spec (±20ms tolerance)
- [ ] Spring parameters match spec
- [ ] No animation blocks user progress
- [ ] Animations can be interrupted
- [ ] View mode crossfade is smooth (0.2s)
- [ ] Mode label flash timing correct (0.8s total)

### Haptics
- [ ] All taps have haptic feedback
- [ ] Correct generator type per spec
- [ ] `.prepare()` called before time-sensitive haptics
- [ ] No haptics on scroll
- [ ] Haptics align with visual change moment
- [ ] Year wheel has selection haptic
- [ ] View mode swipe has light haptic

### Spacing
- [ ] All values multiples of 8pt
- [ ] Screen margins are 24pt
- [ ] Touch targets minimum 44pt
- [ ] Consistent spacing within component type
- [ ] Dot indicator positioned correctly

### Typography
- [ ] Maximum 4 type sizes on screen
- [ ] Correct weight per spec
- [ ] Proper line height
- [ ] No orphaned words on titles

### Color
- [ ] Correct tokens used (not hardcoded hex)
- [ ] Dark mode tested
- [ ] Contrast meets WCAG AA
- [ ] Spectrum colors only in Quality mode
- [ ] Phase colors only in Chapters mode
- [ ] Focus mode is strictly B&W

### States
- [ ] Loading state designed
- [ ] Empty state designed
- [ ] Error state designed
- [ ] Success feedback exists
- [ ] All three view modes tested

### View Modes
- [ ] Chapters mode shows phase colors correctly
- [ ] Quality mode shows rating spectrum correctly
- [ ] Focus mode is strictly B&W
- [ ] Swipe gesture recognized reliably
- [ ] Dot indicator updates on mode change
- [ ] Mode label flashes and fades correctly
- [ ] First-time hint shows once only

### Footer System
- [ ] Time Spine visible only in Chapters view
- [ ] Spine tap target is 44pt despite 12pt visual
- [ ] Spine label appears on tap, dismisses after 2s
- [ ] Breathing Aura visible only in Chapters view
- [ ] Aura color shifts when scrolling through phases
- [ ] Phase Context Bar visible only in Chapters view
- [ ] Context bar shows progress within current phase
- [ ] Ghost number visible only in Focus view
- [ ] Ghost number at 8% opacity by default
- [ ] Tap summons ghost number to 100%, fades back
- [ ] Light haptic on ghost number summon

### Week Selection
- [ ] No global navigation slider exists
- [ ] Header shows view-mode-specific subtitle
- [ ] Chapters: Current phase name or "Chapters" fallback
- [ ] Quality: Weeks remaining countdown
- [ ] Focus: No subtitle
- [ ] Chapters mode: Spine tap highlights phase, dims others
- [ ] Chapters mode: Phase highlight auto-dismisses after 3s
- [ ] Quality mode: Direct tap opens week detail
- [ ] Quality mode: Long-press activates magnification loupe
- [ ] Loupe appears after 300ms hold
- [ ] Loupe radius is 80pt, magnification is 1.5x
- [ ] Loupe tracks finger position smoothly
- [ ] Selection haptic on week change while dragging
- [ ] Medium haptic on week selection release
- [ ] Focus mode: No week selection allowed

---

## 11. Files to Add to Repository

Add this document and the design prompts to your repo:

```
finite-ios/
├── docs/
│   ├── PRD.md                    # Product requirements
│   ├── CRAFT_SPEC.md             # This document
│   ├── APPLE_INTELLIGENCE_SPEC.md # V1.5 AI integration spec
│   ├── DESIGN_PROMPTS.md         # Gemini prompts for mockups
│   └── designs/                  # Generated mockups
│       ├── 01-onboarding.png
│       ├── 02-grid-reveal.png
│       ├── 03-phase-prompt.png
│       ├── 04-phase-builder.png
│       ├── 05-grid-chapters.png       # With Time Spine + Breathing Aura
│       ├── 06-grid-chapters-label.png # Spine tapped, label visible
│       ├── 07-grid-quality.png        # With Edit button
│       ├── 08-grid-focus.png          # Ghost number at 8%
│       ├── 09-grid-focus-summoned.png # Ghost number at 100%
│       └── ...
```

---

## 12. Prompt for Claude Code

When starting development, give Claude Code this context:

```
Read these documents in order:
1. docs/PRD.md — Product requirements and scope
2. docs/CRAFT_SPEC.md — Technical specifications for animations, haptics, spacing, colors

Key principles:
- Every tap needs visual feedback (scale 0.96x) + haptic (.light)
- Animation durations: 0.1-0.15s for taps, 0.2s for view mode changes, 0.3-0.4s for modals
- Spacing: all values multiples of 8pt, screen margins 24pt
- The Reveal animation is the signature moment — implement it exactly per spec
- Three view modes: Chapters (phase colors), Quality (rating spectrum), Focus (B&W)
- Swipe left/right to change view modes with dot indicator
- Phase builder uses dual year wheel pickers with live grid preview
- Use SwiftUI's .snappy, .smooth, .bouncy presets
- Prepare haptic generators before triggering

Current task: [describe what you're building]
```

---

*This document ensures every implementation decision aligns with the craft standard defined in research. Update as decisions evolve.*