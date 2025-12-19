# Finite: Source of Truth
## Complete Product & Engineering Specification

> **Version:** 3.0 — Unified  
> **Status:** Implementation Ready  
> **Last Updated:** December 2025  
> **Philosophy:** Your life has a past AND a future. Both deserve visualization.

---

## Table of Contents

1. [Vision & Philosophy](#1-vision--philosophy)
2. [Design Principles](#2-design-principles)
3. [Data Model](#3-data-model)
4. [View Modes](#4-view-modes)
5. [Signature Interactions](#5-signature-interactions)
6. [Screen Specifications](#6-screen-specifications)
7. [User Flows](#7-user-flows)
8. [Grid System](#8-grid-system)
9. [Design Tokens](#9-design-tokens)
10. [Animations & Haptics](#10-animations--haptics)
11. [Progressive Disclosure](#11-progressive-disclosure)
12. [Edge Cases](#12-edge-cases)
13. [Accessibility](#13-accessibility)
14. [Implementation Checklist](#14-implementation-checklist)

---

# 1. Vision & Philosophy

## 1.1 The Product

Finite visualizes human life as a grid of ~4,000 weeks. It transforms abstract mortality into tangible awareness, creating urgency and intentionality.

**Core Insight:** Mortality IS the ultimate deadline. When you see your life as finite weeks, every week becomes a choice.

## 1.2 The Feeling

Users should feel like they're opening the book of their own life — one that rewards attention, reveals layers over time, and treats their existence with the gravity it deserves.

We draw emotional architecture from complex narratives (Game of Thrones, Attack on Titan, One Piece) and craft standards from the world's slickest apps (Things 3, Linear, Superhuman, Arc Browser).

## 1.3 Narrative UX Framework

Great stories create specific feelings through structural patterns. These patterns are encoded into our interaction design:

| Narrative Element | Emotional Effect | UX Translation |
|-------------------|------------------|----------------|
| **Layered Revelation** | "There's more than I first saw" | Progressive disclosure; features unlock over use; patterns emerge from data |
| **Interconnection** | "Everything is connected" | Visual threads between milestones; tap a week, see what it touches |
| **Weight & Consequence** | "The past shapes the future" | Lived weeks feel different than empty ones; accumulation has texture |
| **Scale Beyond View** | "I'm part of something vast" | Grid implies infinity; subtle depth effects; breathing at edges |
| **Perspective Shifts** | "Same story, new meaning" | View modes as plot twists; same data, transformed understanding |

## 1.4 Craft Standards

**From Things 3:**
- Every detail matters — custom UI components, consistent corners
- "It blends in so well I didn't even think about it — the epitome of good design"

**From Linear:**
- Speed as feature; actions feel instant
- Settings as onboarding — use customization to educate

**From Superhuman:**
- Obsessive attention to detail commands respect
- "Like getting a flashlight that's a little brighter, a pen that's a bit slicker"

**From Arc Browser:**
- Multi-sensory onboarding; make users *feel* something from first launch
- Optimize for feelings over data

---

# 2. Design Principles

## 2.1 Core Principles

1. **Earned Complexity** — Start simple. Let depth reveal itself over time.
2. **Weight Without Heaviness** — Life is serious; the app shouldn't be oppressive.
3. **Every Pixel Means Something** — No decoration. Every element serves purpose.
4. **Signature Moments** — 2-3 interactions that are *unmistakably* Finite.
5. **Temporal Gravity** — Past, present, and future should feel different.

## 2.2 Friction Philosophy

- Lowest possible friction for primary actions
- Deliberate friction for irreversible actions (delete confirmation)
- Zero friction for exploration (swipe between views freely)

## 2.3 Information Hierarchy

1. **The Grid** — Always primary, always visible
2. **Current Week** — The anchor point, always prominent
3. **View-Specific Context** — Footer/context bar changes per mode
4. **Navigation** — Minimal, discoverable through gesture

---

# 3. Data Model

## 3.1 Core Entities

### User

```swift
import SwiftData
import Foundation

@Model
final class User {
    @Attribute(.unique) var id: UUID = UUID()
    
    // Core
    var birthDate: Date
    var expectedLifespanYears: Int = 80
    
    // Computed
    var currentWeekNumber: Int {
        Calendar.current.dateComponents([.weekOfYear], from: birthDate, to: Date()).weekOfYear ?? 0
    }
    
    var totalWeeks: Int {
        expectedLifespanYears * 52
    }
    
    var weeksRemaining: Int {
        max(0, totalWeeks - currentWeekNumber)
    }
    
    // Settings
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    
    init(birthDate: Date, expectedLifespanYears: Int = 80) {
        self.birthDate = birthDate
        self.expectedLifespanYears = expectedLifespanYears
    }
}
```

### Week

```swift
@Model
final class Week {
    @Attribute(.unique) var id: UUID = UUID()
    
    var weekNumber: Int
    var rating: Int?  // 1-5
    var notes: String?
    var phase: String?
    
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init(weekNumber: Int) {
        self.weekNumber = weekNumber
    }
}
```

### Milestone

```swift
@Model
final class Milestone {
    // Identity
    @Attribute(.unique) var id: UUID = UUID()
    
    // Core Properties
    var name: String
    var targetWeekNumber: Int
    
    // Optional Properties
    var category: String?  // "career", "health", "growth", "relationships", "rest", "adventure"
    var notes: String?
    var iconName: String?  // SF Symbol name
    
    // State
    var isCompleted: Bool = false
    var completedAt: Date?
    var completedWeekNumber: Int?
    
    // Metadata
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // CRITICAL: New UUID for each milestone
    init(name: String, targetWeekNumber: Int, category: String? = nil) {
        self.id = UUID()
        self.name = name
        self.targetWeekNumber = targetWeekNumber
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

extension Milestone {
    enum Status {
        case upcoming
        case thisWeek
        case overdue
        case completed
    }
    
    func status(currentWeek: Int) -> Status {
        if isCompleted { return .completed }
        if targetWeekNumber < currentWeek { return .overdue }
        if targetWeekNumber == currentWeek { return .thisWeek }
        return .upcoming
    }
    
    func weeksRemaining(from currentWeek: Int) -> Int {
        max(0, targetWeekNumber - currentWeek)
    }
    
    func targetAge(birthDate: Date) -> Int {
        targetWeekNumber / 52
    }
}
```

### LifePhase

```swift
@Model
final class LifePhase {
    @Attribute(.unique) var id: UUID = UUID()
    
    var name: String
    var startWeekNumber: Int
    var endWeekNumber: Int
    var colorName: String
    
    init(name: String, startWeek: Int, endWeek: Int, color: String) {
        self.name = name
        self.startWeekNumber = startWeek
        self.endWeekNumber = endWeek
        self.colorName = color
    }
}
```

## 3.2 Query Patterns

```swift
// Milestones - CRITICAL: Query returns array, not single object
@Query(sort: \Milestone.targetWeekNumber) 
private var allMilestones: [Milestone]

// Filtered views
private var upcomingMilestones: [Milestone] {
    allMilestones.filter { !$0.isCompleted && $0.targetWeekNumber >= currentWeekNumber }
}

private var nextMilestone: Milestone? {
    upcomingMilestones.first
}

private var overdueMilestones: [Milestone] {
    allMilestones.filter { !$0.isCompleted && $0.targetWeekNumber < currentWeekNumber }
}

// O(1) lookup for grid rendering
private var milestonesByWeek: [Int: [Milestone]] {
    Dictionary(grouping: upcomingMilestones, by: { $0.targetWeekNumber })
}
```

## 3.3 CRUD Operations (Bug Fix Pattern)

```swift
// ✅ CREATE NEW
func createMilestone(name: String, targetWeekNumber: Int, category: String?, notes: String?) {
    let milestone = Milestone(
        name: name,
        targetWeekNumber: targetWeekNumber,
        category: category
    )
    milestone.notes = notes
    modelContext.insert(milestone)  // ← INSERT
    try? modelContext.save()
}

// ✅ UPDATE EXISTING
func updateMilestone(_ milestone: Milestone, name: String, targetWeekNumber: Int, category: String?, notes: String?) {
    milestone.name = name
    milestone.targetWeekNumber = targetWeekNumber
    milestone.category = category
    milestone.notes = notes
    milestone.updatedAt = Date()
    try? modelContext.save()
}

// ✅ DELETE
func deleteMilestone(_ milestone: Milestone) {
    modelContext.delete(milestone)
    try? modelContext.save()
}

// ✅ COMPLETE
func completeMilestone(_ milestone: Milestone, currentWeek: Int) {
    milestone.isCompleted = true
    milestone.completedAt = Date()
    milestone.completedWeekNumber = currentWeek
    try? modelContext.save()
}
```

---

# 4. View Modes

## 4.1 Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│    CHAPTERS ←→ QUALITY ←→ FOCUS ←→ HORIZONS                    │
│       ↑           ↑          ↑          ↑                       │
│    Past by      Past by    Raw       Future                     │
│    life stage   feeling    mortality  goals                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Swipe order: Chapters → Quality → Focus → Horizons → Chapters...
Dot indicator: ● ○ ○ ○ (4 dots)
```

## 4.2 Chapters View

**Purpose:** See your life as narrative arcs, not just time passed.

| Element | Specification |
|---------|---------------|
| Grid coloring | Life phases as distinct color regions |
| Header subtitle | Current phase name |
| Footer | Time Spine (left edge) + phase stats |
| Unique feature | Phase transitions with gradient blends |

**Visual Treatment:**
- Phase boundaries: 5-week gradient blend between colors
- Current phase: Name pulses once on view entry
- Tap phase region → sheet shows phase details, adjustable boundaries

## 4.3 Quality View

**Purpose:** Reflect on how you've spent your time. Rate weeks. See patterns.

| Element | Specification |
|---------|---------------|
| Grid coloring | Rating spectrum (red 1 → green 5) |
| Unrated weeks | Muted gray — visual "holes" |
| Header subtitle | Average rating or prompt |
| Footer | Week scrubber + rating tools |

**Visual Treatment:**
- Consecutive rated weeks: subtle connecting line (streaks)
- Weeks with notes: micro-indicator dot
- High-quality streaks (3+ weeks of 4-5): subtle glow

**Interactions:**
- Tap any past week → rate it (1-5 scale)
- Pinch → zoom to year view

## 4.4 Focus View

**Purpose:** Confront mortality. Create urgency. Pure black and white.

| Element | Specification |
|---------|---------------|
| Grid coloring | B&W only (lived = white, future = black) |
| Header subtitle | None (stark) |
| Footer | Ghost number (8% opacity) |

**Visual Treatment:**
- Zero decoration — deliberately stark
- Breathing aura at edges: cool, dark pulse
- Ghost number: tap to summon (100% for 2s, then fades)

**Interactions:**
- Minimal — this view is for contemplation
- Long-press grid → shows remaining time in years/months/days

## 4.5 Horizons View

**Purpose:** Forward-looking. Goals become visible landmarks in time.

| Element | Specification |
|---------|---------------|
| Grid coloring | Past at 30% opacity, future full |
| Milestone markers | Hexagons at target weeks |
| Header subtitle | Next milestone name (or "Set your first horizon") |
| Footer | Milestone context bar |

**Visual Treatment:**
- Milestone markers: 8pt hexagons, category-colored
- Foreshadowing: weeks before milestone have subtle gradient toward marker
- Current week has forward-facing glow

**Interactions:**
- Tap [+] → Milestone builder
- Tap marker → Milestone detail sheet
- Tap context bar → Milestone list sheet
- Long-press marker → Connection web (V2)

---

# 5. Signature Interactions

These are the "plot twist" moments — interactions users will remember and tell others about.

## 5.1 View Mode Transitions (The Perspective Shift)

Switching views isn't a filter change — it's a *recontextualization* of your entire life.

```
Chapters → Quality:
1. Grid pauses (50ms)
2. Colors desaturate to grayscale (150ms, ease-out)
3. Beat of stillness (100ms)
4. New colors bloom from current week outward (300ms, spring)
5. Haptic: single subtle pulse at color arrival

Chapters → Focus:
1. Colors drain toward edges (200ms)
2. Screen dims slightly (10% darker)
3. Ghost number fades in from below (400ms, ease-out-back)
4. Haptic: slow, heavy pulse

Focus → Horizons:
1. Ghost number rises and fades (200ms)
2. Past weeks dim to 30% (250ms)
3. Milestone markers pulse once in sequence (50ms each)
4. Context bar slides up (300ms, spring)
5. Haptic: ascending sequence of 3 soft taps
```

## 5.2 First Launch Sequence (The Scale Revelation)

```
1. FADE IN: Black screen (500ms)

2. TITLE: "finite" in center
   - Fades in (400ms), holds (800ms), fades out (300ms)

3. ZOOM: Single dot appears center screen
   - Label: "This is one week"
   - Holds (1.5s)

4. EXPAND: Grid expands around it
   - 52 dots form a row: "This is one year"
   - Holds (1.2s)

5. FULL GRID: Entire life zooms out
   - Current week pulses
   - Lived weeks filled, future empty
   - Haptic: heavy single pulse
   - Label: "[X] weeks lived. [Y] weeks possible."
   - Holds (2s)

6. TRANSITION: Grid settles into normal view
```

## 5.3 The Ghost Number (Focus View)

The barely-visible weeks-remaining counter that can be summoned.

```
Default state:
- 8% opacity (nearly invisible)
- Large display font at bottom of screen

Summon (tap):
- Animate to 100% opacity (200ms)
- Haptic: hollow, resonant pulse
- Hold at 100% for 2 seconds
- Fade back to 8% (400ms, ease-out)
```

## 5.4 Connection Web (Horizons View — V2)

Long-press milestone to reveal its narrative connections.

```
Trigger: Long-press milestone marker (500ms)

Response:
1. Selected milestone grows (1.1x, 150ms)
2. Radial pulse emanates
3. Lines draw to:
   - Previous milestone (what led here)
   - Next milestone (what follows)
   - Current week (distance from now)
4. Lines: 1pt, category color @ 40%, gradient fade
5. Connected milestones pulse softly
6. Haptic: soft tick per connection
```

## 5.5 Breathing Aura (All Views)

Edges of grid have slow-pulsing gradient that implies life beyond the frame.

```
- 15% opacity, shifts slowly
- Chapters: warm gradient (life extending)
- Focus: cool gradient (infinite void)
- Horizons: forward-facing gradient (future pulling)
- Animation: 4s cycle, ease-in-out
```

---

# 6. Screen Specifications

## 6.1 Main Grid View (All Modes)

```
┌─────────────────────────────────────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ SAFE AREA ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│                                                                 │
│                          finite                                 │ ← Title: 28pt semibold
│                     [Subtitle varies]                           │ ← 17pt regular, secondary
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─ GRID ──────────────────────────────────────────────────┐   │
│  │                                                         │   │
│  │  ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●  │   │
│  │  ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●◉○○○○○○○○○  │   │
│  │  ○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○  │   │
│  │  ○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○  │   │
│  │                                                         │   │
│  │  Cell: 6pt, Spacing: 2pt, Padding: 16pt                │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─ FOOTER (varies by mode) ───────────────────────────────┐   │
│  │                                                         │   │
│  │  [Mode-specific content]                                │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│                         ● ○ ○ ○                                 │ ← View mode dots
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 6.2 Horizons Context Bar

### Empty State

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ╭──╮                                                      │
│   │+ │   Set your first horizon                        ▶   │
│   ╰──╯   Pin a goal to your future                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Border: Dashed (6, 4), text-tertiary
Background: Transparent
Corner radius: 12pt
Tap: Entire bar → Opens Builder
```

### With Milestones

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ⬡        Run marathon                               43    │
│ 16pt      Age 30 · Health · 4 horizons             weeks   │
│           ↑                                          [+]   │
│           Tap main → List    Tap [+] → Builder       24pt  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Background: .ultraThinMaterial
Corner radius: 12pt
Padding: 16pt H, 12pt V
```

## 6.3 Milestone List Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ─────────────────────────────────────── (Drag indicator)       │
│                                                                 │
│                        Your Horizons                            │
│                                                                 │
│  UPCOMING                                                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ⬡   Run marathon                               43 wks  │   │
│  │       Age 30 · Health                                ▶  │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │  ⬡   Launch startup                             78 wks  │   │
│  │       Age 31 · Career                                ▶  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  OVERDUE (if any)                                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ⬡!  Learn piano                               -12 wks  │   │
│  │       Was due Age 29 · Growth                        ▶  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  COMPLETED (if any)                                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ✓   Get promoted                            Completed   │   │
│  │       Age 28 · Career                                ▶  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Presentation: .sheet with detents([.medium, .large])          │
│  Row tap → Dismisses, opens Detail sheet                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 6.4 Milestone Builder Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ─────────────────────────────────────── (Drag indicator)       │
│                                                                 │
│  [Cancel]           Add Horizon              [Set Horizon]      │
│              (or "Edit Horizon" / "Save")                       │
│                                                                 │
│  ───────────────────────────────────────────────────────────── │
│                                                                 │
│  WHAT'S YOUR HORIZON?                                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Run a marathon                                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ░░░░░░░░░░░░◉○○○○○○○○○○○⬡○○○○○○○○○○○○○○○○○○○○○○○○○  │   │
│  │              43 weeks · Age 30                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  TARGET                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ◀  April 2026  ▶  │  Week 1,590  │   Age 30           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  CATEGORY (optional)                                            │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                    │
│  │ 💼 │ │ 💚 │ │ 📚 │ │ 👥 │ │ 🌙 │ │ 🧭 │                    │
│  │Work│ │Hlth│ │Grow│ │Rel.│ │Rest│ │Advn│                    │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘                    │
│                                                                 │
│  NOTES (optional)                                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ What does achieving this look like?                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │            🗑️ Delete Horizon                             │   │ ← ONLY in edit mode
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Presentation: .sheet with detents([.large])                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 6.5 Milestone Detail Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ─────────────────────────────────────── (Drag indicator)       │
│                                                                 │
│                         ⬡                                      │
│                   Run marathon                                  │
│                      Health                                     │
│                                                                 │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐                    │
│  │    43    │   │    30    │   │ Apr 2026 │                    │
│  │  weeks   │   │   age    │   │  target  │                    │
│  └──────────┘   └──────────┘   └──────────┘                    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ "Complete my first 26.2 miles. Cross the finish line." │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              ✓ Mark Complete                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │               Edit Horizon                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Presentation: .sheet with detents([.medium])                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

# 7. User Flows

## 7.1 First-Time User (Horizons)

```
User swipes to Horizons → Empty state context bar visible
    ↓
Tap context bar → Builder opens (add mode)
    ↓
Fill name, select week, optional category/notes
    ↓
Tap "Set Horizon" → INSERT new Milestone
    ↓
Sheet dismisses → Grid shows new marker
Context bar shows this milestone
Haptic: .success
```

## 7.2 Adding Milestone

**Entry Points:**
1. Tap [+] in context bar → pre-selected: 1 year from now
2. Tap future week on grid → pre-selected: that week
3. Long-press future week → pre-selected: that week + haptic

All lead to Builder sheet in add mode.

## 7.3 Viewing All Milestones

```
Tap context bar (main area, not [+])
    ↓
List sheet opens at .medium detent
    ↓
Sections: Upcoming, Overdue, Completed
    ↓
Tap row → List dismisses (0.3s delay) → Detail opens
```

## 7.4 Viewing Single Milestone

```
Tap milestone marker on grid
    ↓
Detail sheet opens
Shows: Icon, name, category, stats (weeks/age/target), notes
Actions: Mark Complete, Edit Horizon
```

## 7.5 Editing Milestone

```
From Detail sheet: Tap "Edit Horizon"
    ↓
Detail dismisses (0.3s delay)
    ↓
Builder opens in edit mode
    ↓
All fields pre-filled
Delete button visible at bottom
    ↓
Tap "Save" → UPDATE existing record
    ↓
Sheet dismisses, grid updates
```

## 7.6 Completing Milestone

```
From Detail sheet: Tap "✓ Mark Complete"
    ↓
milestone.isCompleted = true
milestone.completedAt = Date()
milestone.completedWeekNumber = currentWeek
    ↓
Sheet dismisses
Haptic: .success
    ↓
Grid: Marker changes to ✓, fades to 50%
Context bar: Updates to next milestone
```

## 7.7 Deleting Milestone

```
From Builder (edit mode): Tap "🗑️ Delete Horizon"
    ↓
Confirmation dialog
    ↓
Confirm → modelContext.delete(milestone)
    ↓
Sheet dismisses
Haptic: .medium
Grid: Marker removed with fade
```

---

# 8. Grid System

## 8.1 Visual Elements

| Element | Symbol | Size | Description |
|---------|--------|------|-------------|
| Past week | ● | 6pt | Lived, filled |
| Current week | ◉ | 6pt + pulse | Now, animated |
| Future week | ○ | 6pt | Remaining, empty |
| Milestone | ⬡ | 8pt | Goal anchor, hexagon |
| Completed | ✓ | 8pt | Achieved, faded |
| Overdue | ⬡! | 8pt + badge | Past due, red tint |

## 8.2 Week Rendering Logic

```swift
func weekView(for weekNumber: Int, in viewMode: ViewMode) -> some View {
    let milestone = milestonesByWeek[weekNumber]?.first
    
    // Shape
    let shape: some Shape = {
        if milestone != nil { return Hexagon() }
        return Circle()
    }()
    
    // Size
    let size: CGFloat = milestone != nil ? 8 : 6
    
    // Color
    let color = weekColor(weekNumber, viewMode: viewMode, milestone: milestone)
    
    // Animation
    let shouldPulse = weekNumber == currentWeekNumber
    
    return shape
        .fill(color)
        .frame(width: size, height: size)
        .modifier(PulseModifier(active: shouldPulse))
}
```

## 8.3 View-Specific Colors

### Chapters
```swift
func chaptersColor(for weekNumber: Int) -> Color {
    guard let phase = phase(for: weekNumber) else {
        return weekNumber < currentWeekNumber 
            ? Color("week-filled") 
            : Color("week-empty")
    }
    return Color(phase.colorName)
}
```

### Quality
```swift
func qualityColor(for weekNumber: Int) -> Color {
    guard weekNumber < currentWeekNumber else {
        return Color("week-empty")
    }
    guard let rating = weekRating(for: weekNumber) else {
        return Color("week-unrated")  // Muted gray
    }
    return Color("quality-\(rating)")  // 1-5 spectrum
}
```

### Focus
```swift
func focusColor(for weekNumber: Int) -> Color {
    weekNumber < currentWeekNumber ? .white : .black
}
```

### Horizons
```swift
func horizonsColor(for weekNumber: Int, milestone: Milestone?) -> Color {
    if let milestone = milestone {
        switch milestone.status(currentWeek: currentWeekNumber) {
        case .upcoming, .thisWeek:
            return milestone.category?.color ?? Color("text-primary")
        case .overdue:
            return Color.red.opacity(0.8)
        case .completed:
            return Color("text-secondary").opacity(0.5)
        }
    }
    
    if weekNumber < currentWeekNumber {
        return Color("week-filled").opacity(0.3)
    } else if weekNumber == currentWeekNumber {
        return Color("week-current")
    } else {
        return Color("week-empty")
    }
}
```

## 8.4 Marker Density Handling

**Adjacent Milestones (1-2 weeks apart):**
- Both markers show, may overlap slightly
- Creates visual "cluster" effect

**Same Week Milestones:**
- Show first marker with count badge: `⬡²`
- Tap opens list filtered to that week

```swift
func markerForWeek(_ weekNumber: Int) -> some View {
    let milestones = milestonesByWeek[weekNumber] ?? []
    
    if milestones.count > 1 {
        MilestoneMarker(milestone: milestones.first!)
            .overlay(alignment: .topTrailing) {
                Text("\(milestones.count)")
                    .font(.system(size: 6, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(2)
                    .background(Circle().fill(Color.red))
                    .offset(x: 4, y: -4)
            }
    } else if let milestone = milestones.first {
        MilestoneMarker(milestone: milestone)
    } else {
        EmptyWeekDot()
    }
}
```

---

# 9. Design Tokens

## 9.1 Typography

```swift
struct FiniteTypography {
    // Display - Ghost number, onboarding
    static let displayLarge = Font.system(size: 96, weight: .ultraLight)
    
    // Title - App title
    static let title = Font.system(size: 28, weight: .semibold)
    
    // Title2 - Sheet headers
    static let title2 = Font.system(size: 22, weight: .semibold)
    
    // Title3 - Stat numbers
    static let title3 = Font.system(size: 20, weight: .semibold)
    
    // Subtitle - Phase/milestone names
    static let subtitle = Font.system(size: 17, weight: .regular)
    
    // Body - Descriptions
    static let body = Font.system(size: 15, weight: .regular)
    
    // Caption - Week counts
    static let caption = Font.system(size: 13, weight: .medium)
    
    // Caption2 - Tertiary labels
    static let caption2 = Font.system(size: 11, weight: .regular)
    
    // Mono - Updating numbers
    static let mono = Font.system(size: 15, weight: .medium, design: .monospaced)
}
```

## 9.2 Colors

```swift
extension Color {
    // Semantic
    static let finitePrimary = Color("Primary")
    static let finiteSecondary = Color("Secondary")
    static let finiteAccent = Color("Accent")
    
    // Text hierarchy
    static let textPrimary = Color("text-primary")
    static let textSecondary = Color("text-secondary")
    static let textTertiary = Color("text-tertiary")
    
    // Backgrounds
    static let bgPrimary = Color("bg-primary")
    static let bgSecondary = Color("bg-secondary")
    
    // Week states
    static let weekFilled = Color("week-filled")
    static let weekEmpty = Color("week-empty")
    static let weekCurrent = Color("week-current")
    static let weekUnrated = Color("week-unrated")
    
    // Life Phases
    static let phaseChildhood = Color("phase-childhood")   // Soft yellow
    static let phaseEducation = Color("phase-education")   // Sky blue
    static let phaseCareer = Color("phase-career")         // Forest green
    static let phaseFamily = Color("phase-family")         // Warm coral
    static let phaseRetirement = Color("phase-retirement") // Soft purple
    
    // Quality Spectrum
    static let quality1 = Color("quality-1")  // Deep red
    static let quality2 = Color("quality-2")  // Orange
    static let quality3 = Color("quality-3")  // Yellow
    static let quality4 = Color("quality-4")  // Light green
    static let quality5 = Color("quality-5")  // Vibrant green
    
    // Category Colors
    static let categoryCareer = Color(hex: "#007AFF")
    static let categoryHealth = Color(hex: "#34C759")
    static let categoryGrowth = Color(hex: "#AF52DE")
    static let categoryRelationships = Color(hex: "#FF2D55")
    static let categoryRest = Color(hex: "#FF9500")
    static let categoryAdventure = Color(hex: "#5AC8FA")
}
```

## 9.3 Spacing

```swift
struct FiniteSpacing {
    // Grid
    static let gridCellSize: CGFloat = 6
    static let gridCellSpacing: CGFloat = 2
    static let gridPadding: CGFloat = 16
    static let milestoneCellSize: CGFloat = 8
    
    // Components
    static let sheetCornerRadius: CGFloat = 24
    static let cardCornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 8
    
    // Layout
    static let contextBarHeight: CGFloat = 64
    static let footerHeight: CGFloat = 48
    static let timeSpineWidth: CGFloat = 12
    
    // Standard spacing
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}
```

---

# 10. Animations & Haptics

## 10.1 Animation Curves

```swift
extension Animation {
    // Standard curves
    static let finiteSpring = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let finiteEaseOut = Animation.easeOut(duration: 0.25)
    static let finiteSlowReveal = Animation.easeOut(duration: 0.6)
    static let finitePulse = Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)
    
    // View transitions
    static let viewTransition = Animation.easeInOut(duration: 0.3)
}
```

## 10.2 Animation Specifications

| Action | Animation | Duration | Curve |
|--------|-----------|----------|-------|
| Marker appear | Scale 0→1 + fade | 0.25s | .spring |
| Marker disappear | Scale 1→0 + fade | 0.2s | .easeOut |
| Marker complete | Morph + color | 0.3s | .easeInOut |
| Context bar change | Crossfade | 0.25s | .easeInOut |
| View mode switch | Crossfade colors | 0.3s | .easeInOut |
| Ghost summon | 0→100% opacity | 0.2s | .easeOut |
| Ghost fade | 100→8% opacity | 0.4s | .easeOut |
| Current week pulse | Scale 1→1.3→1 | 2s loop | .easeInOut |
| List row tap | Highlight flash | 0.1s | .easeOut |

## 10.3 Haptic Vocabulary

| Action | Type | Style | Feeling |
|--------|------|-------|---------|
| View switch | UIImpactFeedback | .medium | "Chapter turn" |
| Week selected | UIImpactFeedback | .light | "Touch time" |
| Tap [+] button | UIImpactFeedback | .light | "Ready" |
| Long-press week | UIImpactFeedback | .medium | "Engaged" |
| Save milestone | UINotificationFeedback | .success | "Achievement" |
| Complete milestone | UINotificationFeedback | .success | "Done!" |
| Delete milestone | UIImpactFeedback | .medium | "Removed" |
| Ghost summon | UIImpactFeedback | .heavy | "Confronting truth" |
| Week picker change | UISelectionFeedback | — | "Tick" |
| Edge reached | UIImpactFeedback | .light | "Boundary" |

## 10.4 Current Week Pulse

```swift
struct PulsingDot: View {
    @State private var scale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        Circle()
            .fill(Color("week-current"))
            .frame(width: 6, height: 6)
            .scaleEffect(scale)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    scale = 1.3
                }
            }
    }
}
```

---

# 11. Progressive Disclosure

## 11.1 Week 1 Experience

**Available:**
- Grid view (Chapters mode only)
- Current week highlighted
- Weeks remaining display
- Basic info sheet on week tap

**Hidden:**
- Other view modes (dots visible but locked)
- Quality rating
- Milestones
- Connection web

**Why:** First week is about *seeing* your life. Don't overwhelm.

## 11.2 Week 2 Experience

**Unlocked:**
- Quality view mode
- Week rating (this week only)
- First prompt: "How was last week? Rate it."

**Gradual reveals:**
- Rate 3 weeks → unlock rating for any past week
- Rate 7+ weeks → pattern hints appear

## 11.3 Week 3-4 Experience

**Unlocked:**
- Focus view mode (with ghost number intro)
- Horizons view mode
- Milestone creation

**First Milestone Prompt:**
"You've been here for 3 weeks. What's one thing you're working toward?"

## 11.4 Month 2+ Experience

**Unlocked:**
- Full connection web
- Annual zoom
- Export/share
- Custom life phases

**Emergent features:**
- Pattern recognition: "Your Wednesdays average 3.2"
- Milestone predictions
- Streak celebrations

---

# 12. Edge Cases

## 12.1 Milestone Edge Cases

| Case | Handling |
|------|----------|
| Milestone on current week | Status = `.thisWeek`, context bar shows "This week" |
| Multiple same-week milestones | Count badge, tap opens filtered list |
| Overdue milestone | Red tint, "Overdue" section in list, still completable |
| Far future (beyond expectancy) | Allow it, no warning |
| Empty name | Save button disabled |
| Rapid add/delete | SwiftData handles; haptic per action |

## 12.2 Grid Edge Cases

| Case | Handling |
|------|----------|
| User at end of expected lifespan | Extended grid, no hard cutoff |
| Scroll beyond lifespan | Subtle resistance, then allow with faded grid |
| Milestone beyond visible grid | Indicator: "X milestones beyond view" |

## 12.3 State Edge Cases

| Case | Handling |
|------|----------|
| App opens after weeks away | "Welcome back. X weeks have passed." |
| Milestone became "this week" | Subtle notification on launch |
| Data corruption | Error state with reset option, iCloud backup |
| No network (if sync added) | "Your life continues offline" |

## 12.4 Empty States

**No Milestones (Horizons):**
```
"The future is unwritten.
What are you moving toward?"
[Create First Horizon]
```

**No Ratings (Quality):**
```
"Every week is a story.
How was this one?"
[Rate This Week]
```

---

# 13. Accessibility

## 13.1 VoiceOver Labels

```swift
// Milestone marker
MilestoneMarker(milestone: milestone)
    .accessibilityLabel("\(milestone.name)")
    .accessibilityValue("Target age \(milestone.targetAge), \(milestone.weeksRemaining) weeks remaining")
    .accessibilityHint("Double tap to view details")
    .accessibilityAddTraits(.isButton)

// Context bar
MilestoneContextBar(...)
    .accessibilityLabel("Next horizon: \(milestone.name)")
    .accessibilityValue("\(milestone.weeksRemaining) weeks until age \(milestone.targetAge)")
    .accessibilityHint("Double tap to see all horizons")

// Future week
Circle()
    .accessibilityLabel("Week \(weekNumber), age \(weekAge)")
    .accessibilityHint("Double tap to set a horizon")
    .accessibilityAddTraits(.isButton)

// Ghost number
GhostNumber(value: weeksRemaining)
    .accessibilityLabel("\(weeksRemaining) weeks remaining")
    .accessibilityHint("Double tap to reveal")
```

## 13.2 Dynamic Type

- All text scales with system settings
- Grid cell size fixed (accessibility alternative: list view)
- Minimum touch targets: 44pt

## 13.3 Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation {
    reduceMotion ? .none : .finiteSpring
}
```

## 13.4 Color Contrast

- All text meets WCAG AA
- Milestone markers: sufficient contrast on grid
- Category colors have accessible variants

---

# 14. Implementation Checklist

## Phase 1: Foundation (Weeks 1-2)

### Data Layer
- [ ] User model with computed properties
- [ ] Week model for ratings
- [ ] Milestone model with `@Attribute(.unique) var id`
- [ ] LifePhase model
- [ ] Query patterns (array, not single)
- [ ] CRUD operations (INSERT vs UPDATE fix)

### Grid
- [ ] Grid performance (<16ms render)
- [ ] Week rendering by view mode
- [ ] Current week pulse
- [ ] Touch handling per element

### Tokens
- [ ] Typography system
- [ ] Color tokens
- [ ] Spacing constants

## Phase 2: View Modes (Weeks 3-4)

### Chapters
- [ ] Phase color rendering
- [ ] Time spine component
- [ ] Phase boundary gradients

### Quality
- [ ] Rating color spectrum
- [ ] Week scrubber
- [ ] Rating sheet

### Focus
- [ ] B&W rendering
- [ ] Ghost number component
- [ ] Summon animation

### Horizons
- [ ] 30% past opacity
- [ ] Milestone markers (hexagon)
- [ ] Context bar (empty + populated)

## Phase 3: Milestones (Weeks 5-6)

### Builder
- [ ] Add mode
- [ ] Edit mode
- [ ] State initialization in `init()`
- [ ] Mini grid preview
- [ ] Week picker
- [ ] Category chips

### Detail
- [ ] Stats display
- [ ] Complete action
- [ ] Edit transition

### List
- [ ] Sections: Upcoming, Overdue, Completed
- [ ] Row → Detail navigation

### Grid Integration
- [ ] Markers render at weeks
- [ ] Tap → Detail
- [ ] Same-week handling

## Phase 4: Signature Moments (Weeks 7-8)

### View Transitions
- [ ] Chapters → Quality
- [ ] Quality → Focus
- [ ] Focus → Horizons
- [ ] Horizons → Chapters

### First Launch
- [ ] Onboarding sequence
- [ ] Scale revelation animation

### Ghost Number
- [ ] Default 8% opacity
- [ ] Tap to summon
- [ ] Fade back

### Polish
- [ ] Haptics per spec
- [ ] Breathing aura
- [ ] Edge effects

## Phase 5: Quality (Week 9)

### Accessibility
- [ ] VoiceOver labels
- [ ] Dynamic Type
- [ ] Reduce Motion

### Edge Cases
- [ ] All 12 cases handled

### Performance
- [ ] Grid: <16ms
- [ ] Transitions: <400ms
- [ ] Cold launch: <1.5s

---

# Appendix A: State Management

## Builder Mode Pattern

```swift
enum MilestoneBuilderMode {
    case add(preselectedWeek: Int?)
    case edit(Milestone)
    
    var isEditMode: Bool {
        if case .edit = self { return true }
        return false
    }
    
    var existingMilestone: Milestone? {
        if case .edit(let m) = self { return m }
        return nil
    }
}
```

## Sheet Coordination

```swift
@State private var showMilestoneList = false
@State private var showMilestoneBuilder = false
@State private var showMilestoneDetail = false
@State private var builderMode: MilestoneBuilderMode = .add(preselectedWeek: nil)
@State private var selectedMilestone: Milestone?

// List → Detail transition
private func selectMilestoneFromList(_ milestone: Milestone) {
    showMilestoneList = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        selectedMilestone = milestone
        showMilestoneDetail = true
    }
}

// Detail → Edit transition
private func openBuilderForEdit(_ milestone: Milestone) {
    showMilestoneDetail = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        builderMode = .edit(milestone)
        showMilestoneBuilder = true
    }
}
```

---

# Appendix B: Bug Fix Reference

**The Problem:** Milestones overwrite instead of accumulating.

**The Cause:** Either:
1. Single-object query instead of array
2. Always fetching first record
3. Not using INSERT for new records

**The Fix:**

```swift
// ✅ Query returns array
@Query var allMilestones: [Milestone]

// ✅ State initialized correctly
init(mode: Mode) {
    switch mode {
    case .add:
        _name = State(initialValue: "")
    case .edit(let m):
        _name = State(initialValue: m.name)
    }
}

// ✅ Save handles both
func save() {
    switch mode {
    case .add:
        modelContext.insert(Milestone(...))
    case .edit(let existing):
        existing.name = name
    }
}
```

**Verification Test:**
1. Add "A" → verify appears
2. Add "B" → verify BOTH appear
3. Add "C" → verify ALL THREE appear
4. Edit "B" → verify A and C unchanged
5. Delete "A" → verify B and C remain

---

# Appendix C: Quick Reference Card

## View Modes at a Glance

| Mode | Purpose | Grid Color | Footer |
|------|---------|------------|--------|
| Chapters | Life as story | Phase colors | Time Spine |
| Quality | Reflection | Rating spectrum | Scrubber |
| Focus | Mortality | B&W | Ghost Number |
| Horizons | Goals | Dimmed past + markers | Context Bar |

## Haptic Vocabulary

```
View switch    → .medium (chapter turn)
Week selected  → .light (touch time)
Milestone made → .success (achievement)
Milestone done → .success (done!)
Ghost summon   → .heavy (truth)
Delete         → .medium (removed)
```

## Animation Timings

```
Primary action: 250ms max
View transition: 300ms
Stagger: 50-100ms
Pulse cycle: 1.2s / 2s
Never exceed: 400ms
```

---

**Document History:**
- v1.0 — Initial Horizons PRD
- v2.0 — Narrative UX integration
- v3.0 — Unified source of truth (this document)

---

*"Good design isn't just about solving surface-level pain points — it's about going deeper, redefining problems, and changing behavior."*