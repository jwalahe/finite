# Finite — Craft Specification

> Supplement to PRD.md — Technical parameters for premium execution  
> **Version:** 1.0.0  
> **Last Updated:** December 15, 2024

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
| View mode toggle | 0.6s | 0 | `.easeOut` | Wash/paint effect |
| Spectrum slider thumb | 0.1s | 0.2 | `.snappy` | Snap to notch |

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
```

**Technical parameters:**
- Fill rate: 20ms per week (50 weeks/second)
- Total duration for 29 years: ~30 seconds
- Year boundary haptic: `.medium` impact
- Final haptic: `.heavy` impact
- Pulse begins 100ms after final fill
- Sound: Soft pencil/graphite scratching, volume 0.3, fade out over 500ms

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
| View mode toggle | Impact | `.medium` | On toggle |
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

### Grid Colors

**B&W Mode:**
| Token | Light Mode | Dark Mode | Use |
|-------|------------|-----------|-----|
| `week-empty` | #E0E0E0 | #3A3A3A | Unfilled weeks |
| `week-filled` | #2A2A2A | #E5E5E5 | Filled weeks |
| `week-current` | #1A1A1A | #FFFFFF | Current week (with pulse) |

**Color Mode (Spectrum):**
| Rating | Label | Hex | Use |
|--------|-------|-----|-----|
| 1 | Awful | #DC2626 | Deep red |
| 2 | Hard | #EA580C | Orange |
| 3 | Okay | #D97706 | Amber |
| 4 | Good | #65A30D | Soft green |
| 5 | Great | #16A34A | Deep green |

### Color Rules

1. Never use pure black (#000000) or pure white (#FFFFFF) for backgrounds
2. Spectrum colors are for week fills only — no spectrum colors in UI chrome
3. Maintain WCAG AA contrast (4.5:1) for all text

---

## 7. Component Specifications

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
- Filled (B&W): solid fill, week-filled color
- Filled (Color): solid fill, spectrum color
- Current: filled + pulse animation
- Tapped: scale 0.9x for 100ms, then expand to detail
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

**Settings (if applicable):**
- Not applicable — settings always have defaults

### Error State

- Horizontal shake: 3 oscillations, 0.15s each
- Haptic: `.error` notification
- Color: text turns `#DC2626` briefly
- Recovery: clear error after 2s or on user action

### Success State

- Scale: 1.0 → 1.1 → 1.0 over 0.3s
- Haptic: `.success` notification (only for significant actions)
- For week marking: color bloom is the success feedback

### Partial State

- Grid with some weeks marked, some empty
- No special treatment — this is the normal state

---

## 9. The Signature: What Makes Finite Finite

### Primary Signature: The Reveal

The first time a user sees their life visualized is the signature moment. It must create an emotional "oh" — the gut punch of mortality made visible.

**What makes it signature:**
- Not instant (takes 30 seconds — time has weight)
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

### What Finite Will NOT Do

- No streaks (trivializes reflection)
- No badges (gamification inappropriate)
- No celebrations (sobriety about mortality)
- No sharing prompts (this is private)
- No AI suggestions (this is human reflection)
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

### Haptics
- [ ] All taps have haptic feedback
- [ ] Correct generator type per spec
- [ ] `.prepare()` called before time-sensitive haptics
- [ ] No haptics on scroll
- [ ] Haptics align with visual change moment

### Spacing
- [ ] All values multiples of 8pt
- [ ] Screen margins are 24pt
- [ ] Touch targets minimum 44pt
- [ ] Consistent spacing within component type

### Typography
- [ ] Maximum 4 type sizes on screen
- [ ] Correct weight per spec
- [ ] Proper line height
- [ ] No orphaned words on titles

### Color
- [ ] Correct tokens used (not hardcoded hex)
- [ ] Dark mode tested
- [ ] Contrast meets WCAG AA
- [ ] Spectrum colors only on week fills

### States
- [ ] Loading state designed
- [ ] Empty state designed
- [ ] Error state designed
- [ ] Success feedback exists

---

## 11. Files to Add to Repository

Add this document and the design prompts to your repo:

```
finite-ios/
├── docs/
│   ├── PRD.md                    # Product requirements
│   ├── CRAFT_SPEC.md             # This document
│   ├── DESIGN_PROMPTS.md         # Gemini prompts for mockups
│   └── designs/                  # Generated mockups
│       ├── 01-onboarding.png
│       ├── 02-grid-empty.png
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
- Animation durations: 0.1-0.15s for taps, 0.2-0.25s for state changes, 0.3-0.4s for modals
- Spacing: all values multiples of 8pt, screen margins 24pt
- The Reveal animation is the signature moment — implement it exactly per spec
- Use SwiftUI's .snappy, .smooth, .bouncy presets
- Prepare haptic generators before triggering

Current task: [describe what you're building]
```

---

*This document ensures every implementation decision aligns with the craft standard defined in research. Update as decisions evolve.*