# Finite: Complete Product Specification
## Unified PRD — Source of Truth + Virality System

> **Version:** 4.0 — Unified  
> **Status:** Implementation Ready  
> **Last Updated:** December 2025  
> **Target Market:** Adults 29+ seeking authentic tools for intentional living  
> **Philosophy:** Your life has a past AND a future. Both deserve visualization. Privacy creates depth. Shareability creates reach.

---

# Part I: Product Foundation

---

## 1. Vision & Philosophy

### 1.1 The Product

Finite visualizes human life as a grid of ~4,000 weeks. It transforms abstract mortality into tangible awareness, creating urgency and intentionality.

**Core Insight:** Mortality IS the ultimate deadline. When you see your life as finite weeks, every week becomes a choice.

### 1.2 The Feeling

Users should feel like they're opening the book of their own life — one that rewards attention, reveals layers over time, and treats their existence with the gravity it deserves.

We draw emotional architecture from complex narratives (Game of Thrones, Attack on Titan, One Piece) and craft standards from the world's slickest apps (Things 3, Linear, Superhuman, Arc Browser).

### 1.3 Narrative UX Framework

Great stories create specific feelings through structural patterns. These patterns are encoded into our interaction design:

| Narrative Element | Emotional Effect | UX Translation |
|-------------------|------------------|----------------|
| **Layered Revelation** | "There's more than I first saw" | Progressive disclosure; features unlock over use; patterns emerge from data |
| **Interconnection** | "Everything is connected" | Visual threads between milestones; tap a week, see what it touches |
| **Weight & Consequence** | "The past shapes the future" | Lived weeks feel different than empty ones; accumulation has texture |
| **Scale Beyond View** | "I'm part of something vast" | Grid implies infinity; subtle depth effects; breathing at edges |
| **Perspective Shifts** | "Same story, new meaning" | View modes as plot twists; same data, transformed understanding |

### 1.4 Craft Standards

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

## 2. Target Market: The 29+ Demographic

### 2.1 Why 29+?

Adults 29+ are fundamentally different from younger users. They represent Finite's ideal market because mortality awareness is no longer abstract — they've experienced loss and feel time's weight.

### 2.2 What 29+ Users Have

- **Higher stakes:** Careers, mortgages, relationships, aging parents
- **Less time tolerance:** No patience for gamification that feels juvenile
- **Genuine mortality awareness:** Unlike 22-year-olds, they've confronted finitude
- **Disposable income:** Willing to pay for tools that genuinely work
- **Decision fatigue:** Value simplicity and clarity over feature bloat

### 2.3 What 29+ Users DON'T Want

- Streaks that feel like manipulation (Duolingo owl energy)
- Badges and achievements that feel patronizing
- Confetti, celebrations, and performative positivity
- Social features that feel like social media
- Complexity masquerading as depth

### 2.4 What 29+ Users WANT

- Tools that respect their intelligence
- Privacy and personal reflection space
- Meaningful visualization of abstract concepts (time, life, progress)
- Rituals that feel earned, not prescribed
- Confrontation over comfort

---

## 3. Design Principles

### 3.1 Core Principles

1. **Earned Complexity** — Start simple. Let depth reveal itself over time.
2. **Weight Without Heaviness** — Life is serious; the app shouldn't be oppressive.
3. **Every Pixel Means Something** — No decoration. Every element serves purpose.
4. **Signature Moments** — 2-3 interactions that are *unmistakably* Finite.
5. **Temporal Gravity** — Past, present, and future should feel different.

### 3.2 Friction Philosophy

- Lowest possible friction for primary actions
- Deliberate friction for irreversible actions (delete confirmation)
- Zero friction for exploration (swipe between views freely)

### 3.3 Information Hierarchy

1. **The Grid** — Always primary, always visible
2. **Current Week** — The anchor point, always prominent
3. **View-Specific Context** — Footer/context bar changes per mode
4. **Navigation** — Minimal, discoverable through gesture

---

## 4. Behavioral Psychology Framework

Most apps use surface-level psychology (streaks, badges, notifications). Finite goes deeper because mortality awareness IS the core product. The psychology doesn't need to be grafted on — it's intrinsic.

### 4.1 Mortality Salience (Terror Management Theory)

**Research Source:** Greenberg, Pyszczynski & Solomon (Terror Management Theory); PLOS One 2021

**The Science:** Terror Management Theory shows that awareness of death triggers psychological defense mechanisms that profoundly change behavior. Mortality salience activates both proximal defenses (immediate coping) and distal defenses (pursuing meaningful goals, self-esteem enhancement).

**What Competitors Miss:** Apps like WeCroak send death reminders but don't channel the response. They trigger anxiety without providing a constructive outlet. Research shows mortality salience increases prosocial behavior, goal pursuit, and self-regulation when channeled properly.

**Finite's Advantage:** The grid IS the constructive outlet. When users feel mortality salience from seeing their life visualized, they need a place to put that energy. The weekly rating ritual transforms anxiety into reflection. The milestone feature transforms it into intentional planning.

**Implementation:** Instead of push notifications that say "You have X weeks left" (WeCroak style), show the grid with a subtle animation of the current week fading. Visual representations of time create stronger mortality salience than text. Immediate ability to rate the week or set a milestone channels the emotion constructively.

### 4.2 Fresh Start Effect (Temporal Landmarks)

**Research Source:** Dai, Milkman & Riis (2014), Management Science

**The Science:** Temporal landmarks (birthdays, new years, Mondays, month beginnings) motivate aspirational behavior by creating psychological "fresh starts" that help people distance themselves from past failures. Birthdays are the strongest trigger.

**What Competitors Miss:** Most apps treat all days equally. They might offer "New Year" features but miss the hundreds of micro-landmarks throughout the year.

**Finite's Advantage:** Every week IS a temporal landmark. Every row (year) is a fresh start. Every life phase transition is a major landmark. This is built into Finite's DNA.

**Implementation:** Sunday evening prompt: "Week 1,547 is complete. Rate it and begin Week 1,548." Year-row transitions get special treatment — visual celebration when moving to a new row. Birthday weeks highlighted as major landmarks with special grid visualization.

### 4.3 Loss Aversion & The Endowment Effect

**Research Source:** Kahneman & Tversky (Prospect Theory, 1979)

**The Science:** Losses are psychologically twice as powerful as equivalent gains. The Endowment Effect extends this: once we "own" something, we value it more and fear losing it.

**What Competitors Miss:** Apps use loss aversion crudely through streak breaking. "Your 50-day streak!" feels manipulative because the streak has no intrinsic value — it's artificial scarcity.

**Finite's Advantage:** The weeks themselves are the scarcity. You can't get them back. This is REAL loss, not manufactured. The filled circles on your grid represent actual time invested — the ultimate endowment.

**Implementation:** "The Irreversible Mark" — Once a week is rated, it cannot be changed (or requires significant friction to change). Each rating decision matters. Unrated past weeks show as faded/empty — representing "lost" opportunities to capture that time.

### 4.4 Commitment Devices & Pre-Commitment

**Research Source:** Rogers et al. (2014), JAMA

**The Science:** Commitment devices — self-imposed constraints that increase the cost of deviation — significantly improve goal achievement. People actively choose to bind their future selves because they recognize their own self-control problems.

**Finite's Advantage:** "Horizons" feature creates commitment without external punishment. Setting a milestone ("Run a marathon by Week 1,600") on the grid creates psychological commitment. The deadline IS mortality.

**Implementation:** Users place future milestones on the grid — they become visible markers. The closer you get to a milestone, the more prominent it becomes. If deadline passes without completion, the milestone remains visible as a question mark — not punishment, but honest record.

### 4.5 Implementation Intentions

**Research Source:** Gollwitzer (1999); Fabulous app case study

**The Science:** Planning the specific when/where/how of a behavior dramatically increases follow-through. The Fabulous app saw 40% improvement in D7/D14 retention by adding "commitment contracts" with specific timing.

**Finite's Advantage:** The weekly ritual IS an implementation intention. "Every Sunday at 8pm, I rate my week." This habit loop naturally emerges from the product structure.

**Implementation:** "The Sunday Ritual" — Users set their preferred "Week End" time during onboarding. Single gentle notification at that time: "Week 1,547 awaits your reflection." The ritual takes <60 seconds — low friction, high meaning. Over time, this becomes identity: "I'm someone who reflects on their weeks."

---

# Part II: Core Product Specification

---

## 5. Data Model

### 5.1 User

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
    var streaksEnabled: Bool = false  // OFF by default for 29+ market
    
    init(birthDate: Date, expectedLifespanYears: Int = 80) {
        self.birthDate = birthDate
        self.expectedLifespanYears = expectedLifespanYears
    }
}
```

### 5.2 Week

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

### 5.3 Milestone

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

### 5.4 LifePhase

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

### 5.5 StreakData (Optional Feature)

```swift
struct StreakData {
    var currentRatingStreak: Int = 0
    var longestRatingStreak: Int = 0
    var lastRatedWeek: Int = 0
    
    mutating func recordRating(for weekNumber: Int) {
        if weekNumber == lastRatedWeek + 1 {
            currentRatingStreak += 1
        } else if weekNumber > lastRatedWeek + 1 {
            currentRatingStreak = 1
        }
        lastRatedWeek = weekNumber
        longestRatingStreak = max(longestRatingStreak, currentRatingStreak)
    }
}
```

### 5.6 Query Patterns

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

### 5.7 CRUD Operations (Bug Fix Pattern)

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

## 6. View Modes

### 6.1 Overview

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

### 6.2 Chapters View

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

### 6.3 Quality View

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

### 6.4 Focus View

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

### 6.5 Horizons View

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

## 7. Signature Interactions

These are the "plot twist" moments — interactions users will remember and tell others about.

### 7.1 View Mode Transitions (The Perspective Shift)

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

### 7.2 First Launch Sequence (The Scale Revelation)

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

### 7.3 The Ghost Number (Focus View)

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

### 7.4 Connection Web (Horizons View — V2)

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

### 7.5 Breathing Aura (All Views)

Edges of grid have slow-pulsing gradient that implies life beyond the frame.

```
- 15% opacity, shifts slowly
- Chapters: warm gradient (life extending)
- Focus: cool gradient (infinite void)
- Horizons: forward-facing gradient (future pulling)
- Animation: 4s cycle, ease-in-out
```

---

## 8. Screen Specifications

### 8.1 Main Grid View (All Modes)

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
│  │  ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●◉○○○○○○○○○  │   │
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

### 8.2 Horizons Context Bar

#### Empty State

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

#### With Milestones

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

### 8.3 Milestone List Sheet

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

### 8.4 Milestone Builder Sheet

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

### 8.5 Milestone Detail Sheet

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

## 9. User Flows

### 9.1 First-Time User (Horizons)

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

### 9.2 Adding Milestone

**Entry Points:**
1. Tap [+] in context bar → pre-selected: 1 year from now
2. Tap future week on grid → pre-selected: that week
3. Long-press future week → pre-selected: that week + haptic

All lead to Builder sheet in add mode.

### 9.3 Viewing All Milestones

```
Tap context bar (main area, not [+])
    ↓
List sheet opens at .medium detent
    ↓
Sections: Upcoming, Overdue, Completed
    ↓
Tap row → List dismisses (0.3s delay) → Detail opens
```

### 9.4 Viewing Single Milestone

```
Tap milestone marker on grid
    ↓
Detail sheet opens
Shows: Icon, name, category, stats (weeks/age/target), notes
Actions: Mark Complete, Edit Horizon
```

### 9.5 Editing Milestone

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

### 9.6 Completing Milestone

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

### 9.7 Deleting Milestone

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

## 10. Grid System

### 10.1 Visual Elements

| Element | Symbol | Size | Description |
|---------|--------|------|-------------|
| Past week | ● | 6pt | Lived, filled |
| Current week | ◉ | 6pt + pulse | Now, animated |
| Future week | ○ | 6pt | Remaining, empty |
| Milestone | ⬡ | 8pt | Goal anchor, hexagon |
| Completed | ✓ | 8pt | Achieved, faded |
| Overdue | ⬡! | 8pt + badge | Past due, red tint |

### 10.2 Week Rendering Logic

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

### 10.3 View-Specific Colors

#### Chapters
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

#### Quality
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

#### Focus
```swift
func focusColor(for weekNumber: Int) -> Color {
    weekNumber < currentWeekNumber ? .white : .black
}
```

#### Horizons
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

### 10.4 Marker Density Handling

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

## 11. Design Tokens

### 11.1 Typography

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

### 11.2 Colors

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

### 11.3 Spacing

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

## 12. Animations & Haptics

### 12.1 Animation Curves

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

### 12.2 Animation Specifications

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

### 12.3 Haptic Vocabulary

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

### 12.4 Current Week Pulse

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

## 13. Progressive Disclosure

### 13.1 Week 1 Experience

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

### 13.2 Week 2 Experience

**Unlocked:**
- Quality view mode
- Week rating (this week only)
- First prompt: "How was last week? Rate it."

**Gradual reveals:**
- Rate 3 weeks → unlock rating for any past week
- Rate 7+ weeks → pattern hints appear

### 13.3 Week 3-4 Experience

**Unlocked:**
- Focus view mode (with ghost number intro)
- Horizons view mode
- Milestone creation

**First Milestone Prompt:**
"You've been here for 3 weeks. What's one thing you're working toward?"

### 13.4 Month 2+ Experience

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

## 14. Edge Cases

### 14.1 Milestone Edge Cases

| Case | Handling |
|------|----------|
| Milestone on current week | Status = `.thisWeek`, context bar shows "This week" |
| Multiple same-week milestones | Count badge, tap opens filtered list |
| Overdue milestone | Red tint, "Overdue" section in list, still completable |
| Far future (beyond expectancy) | Allow it, no warning |
| Empty name | Save button disabled |
| Rapid add/delete | SwiftData handles; haptic per action |

### 14.2 Grid Edge Cases

| Case | Handling |
|------|----------|
| User at end of expected lifespan | Extended grid, no hard cutoff |
| Scroll beyond lifespan | Subtle resistance, then allow with faded grid |
| Milestone beyond visible grid | Indicator: "X milestones beyond view" |

### 14.3 State Edge Cases

| Case | Handling |
|------|----------|
| App opens after weeks away | "Welcome back. X weeks have passed." |
| Milestone became "this week" | Subtle notification on launch |
| Data corruption | Error state with reset option, iCloud backup |
| No network (if sync added) | "Your life continues offline" |

### 14.4 Empty States

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

## 15. Accessibility

### 15.1 VoiceOver Labels

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

### 15.2 Dynamic Type

- All text scales with system settings
- Grid cell size fixed (accessibility alternative: list view)
- Minimum touch targets: 44pt

### 15.3 Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation {
    reduceMotion ? .none : .finiteSpring
}
```

### 15.4 Color Contrast

- All text meets WCAG AA
- Milestone markers: sufficient contrast on grid
- Category colors have accessible variants

---

# Part III: Virality & Growth System

---

## 16. The Virality Problem

### 16.1 Current State

Finite is a deeply personal, private experience. Users see their life as ~4,000 weeks, rate their time, set future milestones. The emotional impact is powerful. **But nothing leaves the app.**

```
User downloads → Uses app → Loves it → ... (dead end)
                                         ↑
                                    No viral loop
```

### 16.2 The Virality Gap

| What Finite Has | What Finite Lacks |
|-----------------|-------------------|
| Emotional punch | Shareable artifact |
| Retention depth | Acquisition hook |
| Personal meaning | Social identity signal |
| Daily utility | "Show and tell" moment |

### 16.3 The Core Tension

**Privacy creates depth. Shareability creates reach.**

The solution isn't to make Finite less private — it's to create **optional, user-controlled moments** where the experience can escape into the social graph.

### 16.4 Benchmark Apps

| App | Viral Mechanic | What They Share |
|-----|----------------|-----------------|
| Spotify | Wrapped | Listening stats, personality |
| Strava | Activity cards | Runs, achievements |
| Duolingo | Streak badges | Consistency, progress |
| BeReal | Daily photo | Authenticity, FOMO |
| Wordle | Score grid | Daily puzzle result |
| WeCroak | Death reminders | Controversy, philosophy |

**Common thread:** Each has a **shareable artifact** that signals identity and creates curiosity.

---

## 17. AIDA Framework Applied

### 17.1 The Flow

```
ATTENTION: "What's that?"
→ User sees Week Card on friend's Instagram story

INTEREST: "Tell me more"
→ Clicks link → Web preview shows their week number

DESIRE: "I need this"
→ Sees full grid, realizes the concept, wants to track own life

ACTION: "Let me download"
→ Downloads app → First "wow" moment → Creates own shareable
```

### 17.2 Feature Mapping to AIDA

| Feature | Primary Stage | Psychology Used |
|---------|--------------|-----------------|
| Week Card | Attention | Identity Signaling |
| Web Preview | Interest | Mortality Salience |
| Widget | Attention | Passive Reminder |
| Life Wrapped | Desire → Action | Annual Reflection |
| Horizons | Retention | Commitment Devices |
| Streak System (Optional) | Action | Loss Aversion |

---

## 18. Viral Feature: Week Card

**The shareable identity artifact**

### 18.1 Concept

A beautiful, minimal card showing the user's current week number. One tap to generate, one tap to share. This becomes the user's "mortality signature" — a conversation starter that creates curiosity.

**The Insight:** "What's your week number?" becomes a social question, like "What's your sign?" but grounded in mortality awareness.

### 18.2 Visual Variants

#### Default Card (Dark)

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            W E E K                      │
│                                         │
│             1,547                       │
│                                         │
│       ████████████░░░░░░░░░░░░░░        │
│              37%                        │
│                                         │
│            ~ finite ~                   │
│                                         │
└─────────────────────────────────────────┘

Dimensions: 1080 x 1920px (Stories) or 1080 x 1080px (Square)
Background: #0A0A0A (near black)
Week number: 120pt, SF Pro Display Light
Progress bar: 4pt height, rounded
Percentage: 17pt, secondary color
Logo: 14pt, 20% opacity
```

#### Light Variant

```
Background: #FAFAFA (near white)
Text: #1A1A1A
```

#### Minimal Variant (No Progress)

Week number only, no progress bar.

#### Grid Variant (Show Context)

Shows life grid with current week highlighted.

### 18.3 Entry Points

1. **Profile/Settings** — "Share My Week" button
2. **Main Grid** — Long-press current week → "Share"
3. **Context Action** — Shake device (optional, delightful)

### 18.4 Technical Implementation

```swift
struct WeekCard: View {
    let weekNumber: Int
    let totalWeeks: Int
    let style: WeekCardStyle
    let format: WeekCardFormat
    
    enum WeekCardStyle {
        case dark, light, minimal, grid
    }
    
    enum WeekCardFormat {
        case stories  // 1080 x 1920
        case square   // 1080 x 1080
    }
    
    var percentageLived: Int {
        Int((Double(weekNumber) / Double(totalWeeks)) * 100)
    }
}

// Export function
func exportWeekCard(style: WeekCardStyle, format: WeekCardFormat) -> UIImage {
    let renderer = ImageRenderer(content: WeekCard(...))
    renderer.scale = 3.0  // High resolution
    return renderer.uiImage ?? UIImage()
}
```

### 18.5 Metadata for Link Previews

```html
<meta property="og:title" content="Week 1,547">
<meta property="og:description" content="I've lived 37% of my expected life. What week are you in?">
<meta property="og:image" content="https://finite.app/cards/1547.png">
<meta property="og:url" content="https://finite.app/week/1547">
```

---

## 19. Viral Feature: Home Screen Widget

**The passive viral surface**

### 19.1 Concept

A home screen widget showing the user's current week. When friends see the widget on the user's phone, it creates organic curiosity: "What's that app? What's week 1,547?"

**The Insight:** Widgets are **always visible**. Unlike posts that disappear from feeds, a widget is a permanent signal on someone's phone. It's passive virality.

### 19.2 Widget Sizes

#### Small (2x2)

```
┌───────────────────┐
│                   │
│    WEEK 1,547     │
│                   │
│    2,613 left     │
│                   │
│      finite       │
└───────────────────┘
```

#### Medium (4x2)

```
┌───────────────────────────────────────┐
│                                       │
│   WEEK 1,547              2,613 left  │
│                                       │
│   ████████████████░░░░░░░░░░░░░░░░░   │
│                37%                    │
│                              finite   │
└───────────────────────────────────────┘
```

#### Large (4x4)

Week + mini grid + next horizon.

### 19.3 Configuration Options

- **Show:** Week number / Weeks remaining / Percentage lived
- **Theme:** Dark / Light / Auto
- **Show Next Milestone:** Toggle on/off

### 19.4 Technical Implementation

```swift
import WidgetKit
import SwiftUI

struct FiniteWidget: Widget {
    let kind: String = "FiniteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FiniteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Your Week")
        .description("See your current week number.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct Provider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // Update weekly (every Monday at midnight)
        let nextUpdate = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(weekday: 2, hour: 0),
            matchingPolicy: .nextTime
        )!
        
        let entry = SimpleEntry(date: Date(), weekNumber: calculateCurrentWeek())
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
```

---

## 20. Viral Feature: Milestone Share

**The achievement celebration**

### 20.1 Concept

When a user completes a milestone, create a moment of celebration that naturally invites sharing. The share artifact communicates accomplishment anchored to mortality — "I did this thing at week 1,547 of my life."

### 20.2 Trigger Flow

1. User taps "✓ Mark Complete" on a milestone
2. Optional: Completion notes prompt ("How did it feel?")
3. Celebration screen with subtle animation (NOT confetti — dignified)
4. "Share This Win" button → generates share card
5. Native share sheet opens

### 20.3 Share Card Design

```
┌─────────────────────────────────────────┐
│                                         │
│                  ✓                      │
│                                         │
│          H O R I Z O N                  │
│           R E A C H E D                 │
│                                         │
│        "Run a marathon"                 │
│                                         │
│    ───────────────────────────────      │
│                                         │
│         43 weeks in the making          │
│                                         │
│        Week 1,590  ·  Age 30            │
│                                         │
│           ~ finite ~                    │
│                                         │
└─────────────────────────────────────────┘
```

### 20.4 Design Note (29+ Market)

The celebration should be dignified, not juvenile. A single checkmark animation with a gentle haptic — NOT confetti, balloons, or excessive celebration. The weight of completing a life milestone doesn't need decoration.

---

## 21. Viral Feature: Life Wrapped

**The annual summary — Finite's "Spotify Wrapped"**

### 21.1 Concept

At the end of each year (or on demand), generate a beautiful, shareable summary of the user's year in weeks. This is the highest-impact viral feature, designed to be shared widely during the natural "year in review" moment.

### 21.2 Timing

- **Auto-trigger:** Last week of December
- **Manual access:** "Generate My Year" in settings (any time)
- **Historical:** "View 2024 Wrapped" for past years

### 21.3 The Sequence (7 screens)

1. **Opening:** "YOUR 2025" — 52 weeks. One life.
2. **The Grid:** Shows this year's row highlighted on full life grid
3. **Quality Summary:** Weeks rated, average rating, overall assessment
4. **Best Week:** Highlight of the year with user's notes
5. **Milestones:** Horizons set, horizons reached
6. **The Number:** "X weeks remain in your life. Make them count."
7. **Share Card:** Final summary → "Share My Year"

### 21.4 Final Share Card

```
┌─────────────────────────────────────────┐
│                                         │
│            M Y   2 0 2 5                │
│                                         │
│       52 weeks lived                    │
│       47 weeks rated                    │
│       Average: 3.8 ★                    │
│                                         │
│       2 horizons reached                │
│       2 horizons set                    │
│                                         │
│    ───────────────────────────────      │
│                                         │
│       Week 1,538 → 1,590                │
│       2,570 weeks remaining             │
│                                         │
│           ~ finite ~                    │
│                                         │
└─────────────────────────────────────────┘
```

### 21.5 Push Notification

End of December:
```
Your 2025 Wrapped is ready 🎉
Tap to see your year in weeks.
```

---

## 22. Psychology-Deep Features

### 22.1 Horizons — Future Milestone Visualization

**Psychology:** Commitment Devices + Temporal Scarcity

Users place future milestones directly on the grid. These become visible markers that anchor goals to specific weeks of their life. The closer you get to a milestone, the more prominent it becomes.

**Implementation:**
- Tap any future week on the grid → "Set Horizon"
- Enter milestone title (e.g., "Run a marathon")
- Milestone appears on grid as distinct marker
- As current week approaches, milestone grows/glows
- If deadline passes without completion: milestone shows as "?" — not punishment, honest record

### 22.2 Birthday Landmark Treatment

**Psychology:** Fresh Start Effect (birthdays are the strongest trigger)

Birthday weeks get special treatment on the grid. Research from Dai, Milkman & Riis shows birthdays are the single most powerful temporal landmark for motivating aspirational behavior.

**Implementation:**
- Birthday weeks highlighted with subtle ring/glow on grid
- On birthday week: special prompt "Beginning year [X] of your life"
- Optional: "What will define this year?" intention prompt
- Shareable "New Year of Life" card

### 22.3 Year-Row Transition Animation

**Psychology:** Fresh Start Effect + Temporal Landmark

When moving from one row (year of life) to the next, create a meaningful visual moment.

**Implementation:**
- When current week moves to new row: subtle animation
- New row "lights up" or pulses briefly
- Single deep haptic
- Optional notification: "Year 31 of your life begins."

### 22.4 The Irreversible Mark

**Psychology:** Loss Aversion + Endowment Effect (authentic, not manufactured)

Once a week is rated, it cannot be easily changed. This creates real weight — each rating decision matters.

**Implementation:**
- Ratings are permanent by default
- To change: Settings → "Edit Past Rating" → friction (confirm dialog)
- Unrated past weeks show as faded/empty on grid
- Visual: Rated weeks have "permanence" — slightly different fill style

---

## 23. Optional Feature: Streak System

### 23.1 Critical Design Decision

**STREAKS ARE OFF BY DEFAULT.** Users must explicitly enable them in Settings. This respects the 29+ market while serving users who find streaks motivating.

### 23.2 Implementation

- Settings → "Enable Streak Tracking" → Toggle OFF by default
- When enabled: Shows rating streak count
- Streak type: Consecutive weeks rated (not check-ins)
- Milestones: 4, 12, 26, 52, 104 weeks

### 23.3 Streak Break Handling (Gentle)

```
"Your streak paused. You were at 8 weeks."
"Life happens. Start fresh."

Shows longest streak ever achieved.
```

### 23.4 Streak Share Card

At milestone (e.g., 52 weeks):

```
┌─────────────────────────────────────────┐
│                                         │
│                 🏆                       │
│                                         │
│          52 WEEK STREAK                 │
│                                         │
│    I rated every single week of         │
│    my life for an entire year.          │
│                                         │
│    ████████████████████████████████     │
│                                         │
│    Weeks 1,538 → 1,590                  │
│                                         │
│           ~ finite ~                    │
│                                         │
└─────────────────────────────────────────┘
```

---

## 24. Web Preview

**Try before download — reduce friction to "aha"**

### 24.1 Concept

A simple web page (finite.app/preview) where anyone can enter their birth date and instantly see their week number. This removes the download barrier and creates the "aha" moment before commitment.

### 24.2 URL Structure

- `finite.app/preview` — Main calculator
- `finite.app/week/1547` — Direct link to a week (for sharing)

### 24.3 Technical Requirements

- **No login required** — Instant calculation
- **No data stored** — Privacy by design
- **Fast** — Result appears within 500ms
- **Mobile-first** — Primary traffic will be mobile
- **Deep link ready** — finite.app/week/1547 pre-fills result

### 24.4 Conversion Path

```
Visit preview → See week number → Emotional impact → 
"See Your Full Grid" → App Store → Download
```

---

## 25. The Complete Viral Loop

### 25.1 The Flow

```
ATTENTION:
User A shares Week Card on Instagram Stories
→ User B sees it, thinks: "What's that?"

INTEREST:
User B taps link → finite.app/preview
→ Enters birth date → Sees own week number
→ "Oh wow, I'm in week 1,823. That's... a lot."

DESIRE:
User B sees the grid visualization
→ Realizes the concept: life as finite weeks
→ "I need to track this."

ACTION:
User B downloads app
→ Completes onboarding → First "wow" moment
→ Sets first milestone

RETENTION:
User B uses app weekly
→ Rates weeks, tracks milestones
→ Builds relationship with grid

SHARE TRIGGER:
User B completes milestone → "Share This Win"
OR: Year ends → Life Wrapped
OR: Just wants to share week number

LOOP RESTARTS:
User B shares → User C sees it → ATTENTION
```

### 25.2 Viral Coefficient Targets

| Metric | Target | How to Achieve |
|--------|--------|----------------|
| % users who share | 15% | Easy share flows, beautiful cards |
| Views per share | 200 | Instagram/Twitter optimization |
| Click-through rate | 5% | Compelling hook, clear value |
| Web → Download | 20% | Smooth preview, clear CTA |
| K-factor | >0.5 | All of the above |

---

# Part IV: Implementation

---

## 26. Implementation Priority & Timeline

### Phase 1: Foundation (Weeks 1-2)

| Feature | Effort | Impact |
|---------|--------|--------|
| Data Layer (all models) | 3 days | Foundation |
| Grid rendering | 3 days | Core experience |
| Week Card (4 styles) | 2 days | Very High |
| Widget (Small) | 2 days | High |

**Goal:** Core app + first shareable artifacts.

### Phase 2: View Modes (Weeks 3-4)

| Feature | Effort | Impact |
|---------|--------|--------|
| Chapters View | 2 days | High |
| Quality View | 2 days | High |
| Focus View | 1 day | Medium |
| Horizons View | 3 days | High |
| Milestone Share | 2 days | Medium |

**Goal:** All view modes functional.

### Phase 3: Web Funnel (Weeks 5-6)

| Feature | Effort | Impact |
|---------|--------|--------|
| Web Preview (finite.app/preview) | 5 days | Very High |
| Deep Links | 2 days | Medium |
| OG/Twitter Cards | 1 day | Medium |

**Goal:** Acquisition path from social shares.

### Phase 4: Psychology-Deep (Weeks 7-8)

| Feature | Effort | Impact | Psychology |
|---------|--------|--------|------------|
| Horizons (Future Milestones) | 5 days | High | Commitment Devices |
| Birthday Landmarks | 2 days | Medium | Fresh Start Effect |
| Irreversible Ratings | 1 day | Medium | Loss Aversion |
| Year-Row Transition | 1 day | Low | Temporal Landmark |

**Goal:** Deepen retention with psychology-backed features.

### Phase 5: Signature Polish (Week 9)

| Feature | Effort | Impact |
|---------|--------|--------|
| First Launch Sequence | 3 days | High |
| View Transitions | 2 days | Medium |
| Ghost Number | 1 day | Medium |
| Breathing Aura | 1 day | Low |

**Goal:** Signature moments that create word-of-mouth.

### Phase 6: Big Moment (November-December)

| Feature | Effort | Impact |
|---------|--------|--------|
| Life Wrapped (7-screen sequence) | 2 weeks | Very High |
| Wrapped Push Notification | 1 day | Medium |
| Wrapped Share Flow | 3 days | High |

**Goal:** Capitalize on "year in review" for maximum virality.

### Phase 7: Market Expansion (Q1 Next Year)

| Feature | Effort | Impact |
|---------|--------|--------|
| Streak System (Optional toggle) | 4 days | Medium |
| Widget (Medium/Large) | 2 days | Low |
| Shared Grids | 1 week | Medium |
| Mortality Quotes | 2 days | Low |

---

## 27. Metrics & Success Criteria

### 27.1 Primary Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| Share Rate | % of WAU who share any card | 15% |
| Viral Coefficient (K) | New users per existing user | >0.5 |
| Web → Download | Conversion rate from preview | 20% |
| Weekly Rating Rate | % of users who rate their week | 60% |
| Widget Install Rate | Users with active widget | 40% |

### 27.2 Secondary Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| Cards Generated | Total share cards created | 10K/month |
| Wrapped Completion | Users who finish 7-screen sequence | 80% |
| Horizons Set | % of users with active milestones | 30% |
| Press Mentions | Articles published | 5 in Q1 |

### 27.3 Tracking Events

```swift
enum AnalyticsEvent {
    case cardGenerated(type: ShareCardType)
    case cardShared(type: ShareCardType, destination: ShareDestination)
    case webPreviewVisited(source: String?)
    case webPreviewConverted
    case widgetInstalled(size: WidgetSize)
    case milestoneCreated(category: String?)
    case milestoneCompleted(weeksToComplete: Int)
    case weekRated(rating: Int)
    case viewModeChanged(from: ViewMode, to: ViewMode)
    case wrappedStarted
    case wrappedCompleted
    case wrappedShared
}
```

---

## 28. What to Explicitly AVOID

Features and patterns that would alienate the 29+ market:

- **Daily check-in requirements** — Weekly is enough. Respect their time.
- **Aggressive notifications** — One gentle reminder per week max. No push notification spam.
- **Badges and achievements** — Feels patronizing. The grid itself is the achievement.
- **Confetti and excessive celebrations** — This is a serious app about mortality. Sobriety, not celebration.
- **Social comparison/leaderboards** — Life isn't a competition. Personal reflection only.
- **AI suggestions** — Human reflection, not algorithmic optimization.
- **Complex journaling** — Keep it to spectrum + category + optional note. No friction.
- **Required social features** — Everything social should be opt-in, not default.
- **Streaks by default** — Only for users who explicitly enable them.

---

## 29. Press & Controversy Strategy

### 29.1 Narrative Angles

1. **"The Death App"** — "This App Shows You Exactly How Many Weeks You Have Left to Live"
2. **"Life-Changing Perspective"** — "The App That Made Me Quit My Job and Chase My Dreams"
3. **"Design as Meaning"** — "How a Grid of 4,000 Dots Can Change Your Life"

### 29.2 Target Publications

| Tier | Publications | Angle |
|------|--------------|-------|
| Tech | TechCrunch, The Verge, Wired | Design/Product |
| Lifestyle | Fast Company, Esquire | Philosophy/Impact |
| Design | Dezeen, It's Nice That | Craft/Aesthetics |
| Wellness | Well+Good, Headspace blog | Mindfulness |
| General | NYT, Guardian | Culture/Trend |

### 29.3 Controversy Playbook

**If criticized as "morbid":**
> "We don't create mortality, we illuminate it. Denial doesn't extend life — awareness might improve it."

**If compared to death reminder apps:**
> "Finite isn't about death, it's about life. The grid isn't empty weeks until you die — it's full weeks you get to design."

---

## 30. Bug Fix Reference

### The Problem

Milestones overwrite instead of accumulating.

### The Cause

Either:
1. Single-object query instead of array
2. Always fetching first record
3. Not using INSERT for new records

### The Fix

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

### Verification Test

1. Add "A" → verify appears
2. Add "B" → verify BOTH appear
3. Add "C" → verify ALL THREE appear
4. Edit "B" → verify A and C unchanged
5. Delete "A" → verify B and C remain

---

## Appendix: Quick Reference

### View Modes at a Glance

| Mode | Purpose | Grid Color | Footer |
|------|---------|------------|--------|
| Chapters | Life as story | Phase colors | Time Spine |
| Quality | Reflection | Rating spectrum | Scrubber |
| Focus | Mortality | B&W | Ghost Number |
| Horizons | Goals | Dimmed past + markers | Context Bar |

### Haptic Vocabulary

```
View switch    → .medium (chapter turn)
Week selected  → .light (touch time)
Milestone made → .success (achievement)
Milestone done → .success (done!)
Ghost summon   → .heavy (truth)
Delete         → .medium (removed)
```

### Animation Timings

```
Primary action: 250ms max
View transition: 300ms
Stagger: 50-100ms
Pulse cycle: 1.2s / 2s
Never exceed: 400ms
```

### Psychology Quick Reference

| Concept | Research Source | Finite Implementation |
|---------|-----------------|----------------------|
| Mortality Salience | Terror Management Theory | Grid visualization, Ghost Number |
| Fresh Start Effect | Dai, Milkman & Riis (2014) | Weekly ritual, Birthday landmarks |
| Loss Aversion | Kahneman & Tversky (1979) | Irreversible ratings, real time scarcity |
| Commitment Devices | Rogers et al. (2014) | Horizons feature |
| Implementation Intentions | Gollwitzer (1999) | Sunday Ritual, specific timing |

---

**Document History:**
- v1.0 — Initial Horizons PRD
- v2.0 — Narrative UX integration
- v3.0 — Unified source of truth
- v4.0 — Combined with Virality PRD, behavioral psychology, 29+ market analysis

---

*"Good design isn't just about solving surface-level pain points — it's about going deeper, redefining problems, and changing behavior."*

*"The best marketing doesn't feel like marketing. It feels like sharing something meaningful."*

*"Finite isn't about death, it's about life. The grid isn't empty weeks until you die — it's full weeks you get to design."*