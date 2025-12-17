# Finite — Product Requirements Document

> **Version:** 1.1.0  
> **Last Updated:** December 17, 2024  
> **Status:** Pre-Development  
> **Owner:** Jwala

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Product Vision](#product-vision)
3. [Team Structure](#team-structure)
4. [User Research & Market Analysis](#user-research--market-analysis)
5. [Product Requirements](#product-requirements)
6. [Design Specifications](#design-specifications)
7. [Technical Architecture](#technical-architecture)
8. [Security & Privacy](#security--privacy)
9. [Sprint Planning](#sprint-planning)
10. [Feature Backlog](#feature-backlog)
11. [Success Metrics](#success-metrics)
12. [Open Questions & Decisions Log](#open-questions--decisions-log)
13. [Appendix](#appendix)

---

## Executive Summary

**Finite** is an iOS app that visualizes a human life as a grid of weeks, creating visceral awareness of time's passage. Unlike wellness-focused competitors that emphasize "mindfulness" and "cherishing moments," Finite takes a stark, philosophical approach—confronting users with mortality to inspire urgency and intentional living.

### Key Differentiators
- **Emotional posture:** Confrontation, not comfort
- **Design quality:** Apple Design Award-level craft with premium animations and haptics
- **Simplicity:** Radically focused feature set
- **Business model:** Free core experience (freemium later)

### App Identity
| Attribute | Value |
|-----------|-------|
| App Name | Finite |
| Subtitle | "Your life in weeks." |
| Bundle ID | com.jwala.finite |
| Category | Lifestyle / Productivity |
| Target iOS | 17.0+ |
| Price | Free |

---

## Product Vision

### Mission Statement
Create a sense of urgency that transforms how people approach their limited time.

### Core Philosophy
> "Hurry up and live." — Seneca

The app embodies Stoic philosophy: confronting mortality not to depress, but to liberate. Each interaction should feel weighty, intentional, and profound.

### Product Principles

1. **Stark over soft** — No wellness fluff. Raw numbers. Honest confrontation.
2. **Craft over features** — Fewer things, done exceptionally well.
3. **Ritual over utility** — The weekly marking is a meditation, not a task.
4. **Privacy as default** — Your mortality is yours alone.

### The Three Moments
Every design and engineering decision serves one of these three moments:

| Moment | Description | Emotion |
|--------|-------------|---------|
| **The Reveal** | First time seeing your life as weeks | Gut punch, awe |
| **The Mark** | Weekly ritual of acknowledging time passed | Solemn, intentional |
| **The Glance** | Daily widget confrontation | Quiet urgency |

---

## Team Structure

Since this is a solo development project, the following role separation helps maintain clarity and serves as context for AI assistants:

### 🎯 Product (PM Role)
**Responsibilities:**
- Feature prioritization and scope decisions
- User story definition
- Sprint planning
- Success metrics

**Current Decisions Owner:** Jwala + Claude (advisory)

### 🎨 Design (Design Role)
**Responsibilities:**
- UX flows and wireframes
- UI specifications
- Animation design
- Haptic patterns

**Tools:** Gemini image models for UI generation, Figma (optional)

### 🛠 Engineering (Eng Role)
**Responsibilities:**
- Technical architecture
- Implementation
- Code review
- Testing

**Tools:** Xcode, Claude Code, GitHub Copilot

---

## User Research & Market Analysis

### Target User
- Age: 25-45
- Mindset: Philosophically curious, achievement-oriented
- Motivation: Wants to "wake up" from autopilot living
- Technical comfort: iPhone user, comfortable with apps

### Competitive Landscape

| App | Positioning | Weakness |
|-----|-------------|----------|
| Life Calendar | "Capture moments" | Generic, cluttered |
| Lifetime | "Be mindful, value your time" | Soft wellness tone |
| Life Dots | "Beautifully simple" | Monthly (not weekly), less granular |
| Entire.Life | "Intentional living" | Web-focused, feature-heavy |

### Competitive Advantage
| Them | Finite |
|------|--------|
| "Be mindful" | "Time is running out" |
| Soft, wellness-coded | Stark, philosophical |
| Feature-cluttered | Radically simple |
| Subscription for basics | Free core experience |
| Generic animations | Apple Design Award-quality craft |

### Tim Urban Origin
The "life in weeks" concept was popularized by Tim Urban's 2014 Wait But Why post "Your Life in Weeks." This is the canonical reference for the visualization.

---

## Product Requirements

### MVP Scope (v1.0)

#### Included ✅
- [ ] Birthday-only onboarding
- [ ] Animated grid reveal (pencil SFX, haptic thuds, current week pulse)
- [ ] Life Phases system (year-level chapters with optional rating)
- [ ] Three view modes: Chapters / Quality / Focus
- [ ] Swipe view toggle with dot indicator
- [ ] Long-press to mark weeks
- [ ] Bottom sheet with spectrum rating (1-5)
- [ ] Category selection (6 categories)
- [ ] Optional phrase input
- [ ] Widget showing weeks remaining
- [ ] Daily notification (raw number)
- [ ] Milestone notifications
- [ ] Local-only data storage

#### Explicitly Excluded (v1.0) ❌
- Zoom navigation
- Individual past week reconstruction (backfilling week-by-week)
- Social sharing
- Cloud sync
- Account system
- Analytics / tracking
- Face ID/Touch ID lock (iOS has native app lock)

### User Stories

#### Onboarding
```
US-001: As a new user, I want to enter only my birthday so I can see my life grid immediately without friction.

Acceptance Criteria:
- Single date picker input
- No account creation required
- Immediate transition to grid reveal
- Birthday stored locally
```

#### Grid Reveal
```
US-002: As a new user, I want to see my weeks fill in dynamically so I feel the weight of time already passed.

Acceptance Criteria:
- Weeks fill one-by-one rapidly (not all at once)
- Pencil/sketch sound effect accompanies fill
- Haptic thuds punctuate the animation
- Current week pulses after reveal completes
- Total duration: ~30 seconds for full life
```

#### Life Phases
```
US-009: As a new user, after seeing The Reveal, I want the option to add life chapters so my past isn't just empty weeks.

Acceptance Criteria:
- Modal prompt appears after Reveal: "Your past is empty. Add life chapters?" with [Yes] / [Skip] options
- Skip is always available; phases can be added later from settings
- Phase input uses dual year wheel pickers with live grid preview
- Each phase has: name, start year, end year, optional overall rating (1-5)
- After adding a phase, user sees visual timeline with gap counts
- User can add multiple phases or tap "Done for now"
- Phases auto-assign colors from curated palette (editable in settings)
```

```
US-010: As a user, I want to see my life through different lenses so I can reflect in multiple ways.

Acceptance Criteria:
- Three view modes: Chapters (phase colors), Quality (rating spectrum), Focus (B&W)
- Swipe left/right on grid to switch modes
- Dot indicator shows current mode (● ○ ○)
- Mode name flashes briefly on switch (e.g., "Quality")
- First-time hint: "← Swipe to change view →" (fades after 3s, shown once)
```

#### Weekly Marking
```
US-003: As a returning user, I want to mark the current week with a rating and category so I can build a record of my life.

Acceptance Criteria:
- Long press (200ms) on any week triggers bottom sheet
- Haptic pulse confirms hold recognized
- Spectrum slider with 5 notches (haptic tick per notch)
- 6 category icons, single selection
- Optional text field for phrase
- Confirm dismisses sheet and animates circle color
```

#### View Toggle
```
US-004: As a user, I want to swipe between view modes so I can see my life through different lenses.

Acceptance Criteria:
- Swipe left/right on grid changes view mode
- Three modes: Chapters / Quality / Focus
- Grid crossfades to new color scheme (200ms)
- Mode name appears briefly, then fades
- Dot indicator updates (● ○ ○ → ○ ● ○)
- Haptic feedback on mode change
- Preference persisted locally
```

#### Widget
```
US-005: As a user, I want a home screen widget showing weeks remaining so I'm confronted with mortality daily.

Acceptance Criteria:
- Displays single number (weeks remaining)
- Updates weekly
- Tapping opens app
- Supports small and medium widget sizes
```

#### Notifications
```
US-006: As a user, I want a daily notification with just a number so I'm reminded of finite time without being annoyed.

Acceptance Criteria:
- Morning notification (user-configurable time)
- Body text: raw number only (e.g., "2,647")
- No title, no explanation
- Can be disabled in settings
```

```
US-007: As a user, I want milestone notifications so significant life moments are marked.

Acceptance Criteria:
- Triggers on: decade birthdays, halfway point, streak achievements
- Example: "You've now lived 30 years. 2,600 weeks."
- Cannot be disabled (core to app philosophy)
```

---

## Design Specifications

### Design Language

#### Emotional Tone
- **Stark** — Not sterile, but unadorned
- **Weighty** — Interactions feel consequential
- **Quiet** — No celebration animations, no gamification
- **Timeless** — Design that ages well, no trends

#### Color Palette

**Spectrum Ratings (Primary Visual)**
| Rating | Label | Color | Hex |
|--------|-------|-------|-----|
| 1 | Awful | Deep Red | #DC2626 |
| 2 | Hard | Orange | #EA580C |
| 3 | Okay | Amber | #D97706 |
| 4 | Good | Soft Green | #65A30D |
| 5 | Great | Deep Green | #16A34A |

**Phase Colors (Auto-Assigned)**
| Phase Type | Color | Hex |
|------------|-------|-----|
| Childhood | Warm Gray | #78716C |
| School | Slate Blue | #6366F1 |
| College | Indigo | #4F46E5 |
| Early Career | Teal | #0D9488 |
| Career | Emerald | #059669 |
| Custom 1 | Purple | #9333EA |
| Custom 2 | Rose | #E11D48 |
| Custom 3 | Sky | #0284C7 |

*Colors auto-assigned in order; user can change in settings*

**UI Colors**
| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Background | Off-white (#FAFAFA) | Near-black (#0A0A0A) |
| Grid (unfilled) | Light gray (#E0E0E0) | Dark gray (#3A3A3A) |
| Grid (filled, B&W mode) | Charcoal (#2A2A2A) | Light gray (#E5E5E5) |
| Current week pulse | Accent | Accent |
| Text | Near-black (#1A1A1A) | Off-white (#F5F5F5) |

#### Typography
- System fonts (SF Pro) for maximum iOS coherence
- Limited hierarchy: Title, Body, Caption only
- No decorative fonts

#### Categories

| Category | Icon | Description |
|----------|------|-------------|
| Work | 💼 or custom | Career, professional, shipping |
| Health | 🏃 or custom | Fitness, physical wellbeing |
| Growth | 📚 or custom | Learning, skill-building |
| Relationships | 👥 or custom | Family, friends, social |
| Rest | 😴 or custom | Recovery, downtime, reset |
| Adventure | ✈️ or custom | Travel, new experiences |

*Note: Final icons to be custom SF Symbols or minimal line icons, not emoji*

### Interaction Design

#### The Reveal Animation
```
Sequence:
1. Birthday submitted → screen transitions to empty grid
2. Beat of silence (500ms)
3. Weeks begin filling from top-left (week 1)
4. Fill rate: ~50 weeks/second (entire life in ~30 sec)
5. Each fill accompanied by subtle pencil SFX
6. Haptic thuds at year boundaries (every 52 weeks)
7. Fill stops at current week
8. Current week begins pulsing (scale 1.0 → 1.08 → 1.0, loop)
9. Final haptic: single heavy thud
```

#### Post-Reveal Phase Prompt
```
Sequence:
1. Reveal completes, current week pulsing
2. After 1s pause, modal slides up:
   ┌─────────────────────────────────────┐
   │                                     │
   │   Your past is empty.               │
   │   Add life chapters?                │
   │                                     │
   │   [Yes, add chapters]               │
   │   [Skip for now]                    │
   │                                     │
   └─────────────────────────────────────┘
3. If Skip → dismiss modal, land on grid
4. If Yes → transition to Phase Builder
```

#### Phase Builder
```
┌─────────────────────────────────────────┐
│  [Grid preview with selection highlighted] │
│  ▪▪▪▪▪▪▪▪▪▪████████████████▪▪▪▪▪▪▪▪▪▪  │
│─────────────────────────────────────────│
│                                         │
│  Chapter name: [College           ]     │
│                                         │
│    ┌─────────┐      ┌─────────┐        │
│    │  2013   │      │  2017   │        │
│    │ >2014<  │  to  │ >2018<  │        │
│    │  2015   │      │  2019   │        │
│    └─────────┘      └─────────┘        │
│                                         │
│  How was it overall?  ○ ○ ● ○ ○        │
│                      1 2 3 4 5          │
│                                         │
│            [Add Chapter]                │
└─────────────────────────────────────────┘

After adding:
┌─────────────────────────────────────────┐
│                                         │
│  ✓ Added "College" (2014-2018)          │
│                                         │
│  |░░░░░░░░░░░░|████|░░░░░░░|           │
│  1995       2014  2018    2025          │
│                                         │
│  19 years before. 7 years after.        │
│                                         │
│  [Add another]         [Done for now]   │
│                                         │
└─────────────────────────────────────────┘
```

#### The Mark Interaction
```
Trigger: Long press on week (200ms threshold)
Feedback: Light haptic pulse

Bottom Sheet Contents (top to bottom):
1. Week identifier: "Week 1,547 • March 2024"
2. Spectrum slider: horizontal, 5 notches
   - Haptic tick at each notch
   - Color gradient updates as thumb moves
   - Labels below: Awful | Hard | Okay | Good | Great
3. Category row: 6 icons, horizontally scrollable if needed
   - Tap selects (scale animation + haptic)
   - Single selection only
4. Phrase field: collapsed by default
   - Tap expands
   - Placeholder: "One line about this week..."
   - Max: 140 characters
5. Confirm button: "Done" or just swipe down

On Confirm:
- Sheet dismisses downward
- Circle on grid blooms with selected color
- Haptic confirmation
```

#### View Mode Toggle
```
Interaction: Swipe left/right on grid
Animation: Grid crossfades between color schemes (200ms)

Modes:
1. Chapters — Weeks colored by phase (College=indigo, Career=teal, etc.)
2. Quality — Weeks colored by rating (1-5 spectrum)
3. Focus — B&W only, week numbers visible (mortality confrontation)

Indicator: Three dots at bottom (● ○ ○)
Feedback: Mode name flashes briefly ("Quality"), haptic on change
First-time: "← Swipe to change view →" hint, fades after 3s
```

### Wireframes

*To be generated using Gemini image models*

Key screens needed:
1. Onboarding — Birthday input
2. Grid Reveal — Animation in progress
3. Phase Prompt — Modal after Reveal
4. Phase Builder — Year wheels + grid preview
5. Grid — Chapters view mode
6. Grid — Quality view mode
7. Grid — Focus view mode
8. Bottom sheet — Week marking
9. Settings
10. Widget (small)
11. Widget (medium)

---

## Technical Architecture

### Tech Stack

| Layer | Technology | Notes |
|-------|------------|-------|
| Language | Swift 5.9+ | Native iOS |
| UI Framework | SwiftUI | Declarative, animation-native |
| Persistence | SwiftData | Modern, type-safe (iOS 17+) |
| Widgets | WidgetKit | Home screen widgets |
| Notifications | UNUserNotificationCenter | Local notifications |
| Audio | AVFoundation | Pencil SFX |
| Haptics | UIFeedbackGenerator | All tactile feedback |

### Data Model

```swift
// User.swift
@Model
class User {
    var birthDate: Date
    var createdAt: Date
    var settings: UserSettings
    
    init(birthDate: Date) {
        self.birthDate = birthDate
        self.createdAt = Date()
        self.settings = UserSettings()
    }
}

// UserSettings.swift
@Model
class UserSettings {
    var dailyNotificationEnabled: Bool = true
    var dailyNotificationTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0))!
    var currentViewMode: ViewMode = .chapters
    var lifeExpectancy: Int = 80 // years, for calculations
}

// ViewMode.swift
enum ViewMode: String, Codable {
    case chapters  // Phase colors
    case quality   // Rating spectrum
    case focus     // B&W, mortality confrontation
}

// Week.swift
@Model
class Week {
    var weekNumber: Int // 1 to ~4160
    var rating: Int? // 1-5, nil if unmarked
    var category: WeekCategory?
    var phrase: String?
    var markedAt: Date?
    var phase: LifePhase? // Reference to containing phase
    var isSeeded: Bool = false // true if filled by phase, false if manually marked
    
    init(weekNumber: Int) {
        self.weekNumber = weekNumber
    }
}

// LifePhase.swift
@Model
class LifePhase {
    var id: UUID
    var name: String // "College", "First Job", etc.
    var startYear: Int
    var endYear: Int
    var defaultRating: Int? // 1-5, overall feeling for this phase
    var colorHex: String // Auto-assigned, editable
    var createdAt: Date
    var sortOrder: Int // For display ordering
    
    init(name: String, startYear: Int, endYear: Int) {
        self.id = UUID()
        self.name = name
        self.startYear = startYear
        self.endYear = endYear
        self.createdAt = Date()
        self.sortOrder = 0
    }
    
    var startWeek: Int {
        // Calculate based on user's birth year
        // Implementation needed
    }
    
    var endWeek: Int {
        // Calculate based on user's birth year
        // Implementation needed
    }
}

// WeekCategory.swift
enum WeekCategory: String, Codable, CaseIterable {
    case work
    case health
    case growth
    case relationships
    case rest
    case adventure
}
```

### Calculated Properties

```swift
extension User {
    var currentWeekNumber: Int {
        // Calculate weeks since birth
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: birthDate, to: Date())
        return (components.weekOfYear ?? 0) + 1
    }
    
    var totalWeeks: Int {
        return settings.lifeExpectancy * 52
    }
    
    var weeksRemaining: Int {
        return max(0, totalWeeks - currentWeekNumber)
    }
    
    var weeksLived: Int {
        return currentWeekNumber
    }
    
    var birthYear: Int {
        return Calendar.current.component(.year, from: birthDate)
    }
}
```

### Project Structure

```
Finite/
├── App/
│   ├── FiniteApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── BirthdayInputView.swift
│   │   └── OnboardingViewModel.swift
│   ├── Grid/
│   │   ├── GridView.swift
│   │   ├── WeekCell.swift
│   │   ├── GridViewModel.swift
│   │   ├── GridRevealAnimation.swift
│   │   └── ViewModeToggle.swift
│   ├── Phases/
│   │   ├── PhasePromptModal.swift
│   │   ├── PhaseBuilderView.swift
│   │   ├── YearWheelPicker.swift
│   │   ├── PhaseTimelinePreview.swift
│   │   └── PhaseViewModel.swift
│   ├── WeekDetail/
│   │   ├── WeekDetailSheet.swift
│   │   ├── SpectrumSlider.swift
│   │   ├── CategoryPicker.swift
│   │   └── WeekDetailViewModel.swift
│   └── Settings/
│       ├── SettingsView.swift
│       ├── PhaseManagerView.swift
│       └── SettingsViewModel.swift
├── Core/
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Week.swift
│   │   ├── LifePhase.swift
│   │   ├── WeekCategory.swift
│   │   └── ViewMode.swift
│   ├── Services/
│   │   ├── HapticService.swift
│   │   ├── AudioService.swift
│   │   ├── NotificationService.swift
│   │   └── PhaseColorService.swift
│   └── Utilities/
│       ├── DateExtensions.swift
│       └── AnimationExtensions.swift
├── Design/
│   ├── Colors.swift
│   ├── PhaseColors.swift
│   ├── Typography.swift
│   └── Components/
│       ├── PulsingCircle.swift
│       ├── DotIndicator.swift
│       └── GapTimeline.swift
├── Widget/
│   ├── FiniteWidget.swift
│   ├── WidgetEntry.swift
│   └── WidgetViews/
│       ├── SmallWidgetView.swift
│       └── MediumWidgetView.swift
└── Resources/
    ├── Assets.xcassets
    ├── Sounds/
    │   └── pencil_fill.mp3
    └── Localizable.strings
```

### Dependencies
- **None** — Pure Apple frameworks only
- This is intentional: fewer dependencies = faster builds, smaller app, no supply chain risk

---

## Security & Privacy

### Data Storage
| Data | Storage Location | Encryption |
|------|------------------|------------|
| Birth date | SwiftData (local) | iOS file encryption |
| Week entries | SwiftData (local) | iOS file encryption |
| Life phases | SwiftData (local) | iOS file encryption |
| Settings | SwiftData (local) | iOS file encryption |

### Privacy Principles
1. **No accounts** — No email, no sign-up
2. **No cloud** — All data stays on device
3. **No analytics** — No tracking, no telemetry
4. **No ads** — Ever
5. **iOS native lock** — Use system-level app lock if needed

### App Privacy Label (App Store)
- **Data Not Collected** — The app does not collect any data

---

## Sprint Planning

### Sprint Duration
2 weeks per sprint

### Sprint 0: Setup (Completed)
- [x] Product definition
- [x] Design specifications
- [x] Technical architecture
- [x] Apple Developer enrollment
- [x] GitHub repo creation
- [x] Xcode project setup

### Sprint 1: The Reveal ✅
**Goal:** Birthday input → Grid reveal animation (the "holy shit" moment)

**Deliverables:**
- Onboarding flow (birthday picker)
- Grid layout (all weeks displayed)
- Reveal animation (sequential fill + SFX + haptics)
- Current week pulse
- Basic navigation structure

**Status:** Complete

### Sprint 2: The Mark ✅
**Goal:** Weekly marking ritual fully functional

**Deliverables:**
- Long-press gesture detection
- Bottom sheet with spectrum slider
- Category selection
- Optional phrase input
- Week state persistence
- Color bloom animation on confirm

**Status:** Complete

### Sprint 3: View Toggle ✅
**Goal:** Color/B&W toggle (legacy) + visual polish

**Deliverables:**
- View mode toggle (instant switching)
- Visual polish pass
- Haptic tuning

**Status:** Complete (modified scope)

### Sprint 4: Widget ✅
**Goal:** Home screen widget

**Deliverables:**
- WidgetKit integration
- Small widget (number only)
- Medium widget (number + context)
- Widget updates weekly

**Status:** Complete

### Sprint 5: Notifications ✅
**Goal:** Daily notification + behavioral nudges

**Deliverables:**
- Local notification scheduling
- Daily raw number notification
- Milestone notification logic
- Settings screen

**Status:** Complete (Face ID removed—iOS has native app lock)

### Sprint 6: Life Phases 🆕
**Goal:** Cold start solution with Life Phases system

**Deliverables:**
- Phase prompt modal (post-Reveal)
- Phase builder with dual year wheels
- Live grid preview during phase creation
- Visual timeline with gap indicators
- Three view modes (Chapters/Quality/Focus)
- Swipe view toggle with dot indicator
- Phase color auto-assignment
- Settings: phase management, color editing

**Definition of Done:**
- User can add phases after Reveal or skip
- Phases display correctly in Chapters view mode
- Swipe toggles between all three view modes
- Phase colors persist and are editable

### Sprint 7: QA & Launch Prep
**Goal:** App Store ready

**Deliverables:**
- Bug fixes from testing
- App Store screenshots
- App Store description
- Privacy policy
- TestFlight beta
- App Store submission

**Definition of Done:**
- App approved and live

---

## Feature Backlog

### v1.0 (MVP) — Sprints 1-7
*See Sprint Planning above*

### v1.5 (Post-Launch Enhancement)
| Feature | Priority | Notes |
|---------|----------|-------|
| Apple Intelligence Integration | High | On-device "Reflect" feature using Foundation Models framework. Query life data, generate insights. iOS 26+, iPhone 15 Pro+ only. See APPLE_INTELLIGENCE_SPEC.md when ready to build. |
| Export | Low | Export grid as image |

### v2.0 (Future)
| Feature | Priority | Notes |
|---------|----------|-------|
| Apple Watch Widget | Medium | Weeks remaining on wrist |
| Siri Shortcut | Low | "How many weeks do I have left?" |
| iCloud Sync | Low | Only if users demand it |
| iPad Layout | Low | Adaptive grid for larger screen |

### Explicitly Never
- Social features / sharing to feed
- Gamification / streaks / badges
- Subscription for core features
- Ads

---

## Success Metrics

### North Star Metric
**Weekly Active Markers** — Users who mark at least one week per week

### Launch Goals (First 90 Days)
| Metric | Target |
|--------|--------|
| Downloads | 1,000 |
| Day 7 Retention | 30% |
| App Store Rating | 4.5+ |
| Weekly Active Markers | 20% of users |

### Quality Metrics
| Metric | Target |
|--------|--------|
| Crash-free rate | 99.5% |
| App launch time | <1 second |
| Animation frame rate | 60fps consistent |

---

## Open Questions & Decisions Log

### Open Questions
| ID | Question | Status | Owner |
|----|----------|--------|-------|
| Q1 | Exact sound effect for pencil fill? | Open | Design |
| Q2 | App icon design? | Open | Design |

### Decision Log
| Date | Decision | Rationale | Decided By |
|------|----------|-----------|------------|
| 2024-12-15 | App name: Finite | Philosophical, distinctive, not crowded | PM |
| 2024-12-15 | SwiftUI only, no UIKit | Modern, animation-native, maintainable | Eng |
| 2024-12-15 | No external dependencies | Smaller app, faster builds, no supply chain risk | Eng |
| 2024-12-15 | Local-only storage | Privacy-first, simpler architecture | PM + Eng |
| 2024-12-15 | Free launch, freemium later | Build audience before monetizing | PM |
| 2024-12-15 | Weekly granularity (not daily/monthly) | Matches original "Life in Weeks" concept, right frequency for reflection | PM |
| 2024-12-15 | 6 categories, single selection | Forces "what defined this week" reflection | PM |
| 2024-12-15 | Spectrum primary, category secondary | Grid shows "how life felt" at a glance | PM |
| 2024-12-15 | Raw number notifications | Stark, no fluff, user supplies meaning | PM |
| 2024-12-17 | Life Phases added to V1 | Solves cold start problem without compromising core USP | PM |
| 2024-12-17 | Three view modes (Chapters/Quality/Focus) | Same life, three lenses—chapters, feelings, mortality | PM |
| 2024-12-17 | Swipe toggle with dot indicator | Immersive, grid as hero, iOS-native gesture | PM |
| 2024-12-17 | Phase input via dual year wheels | Touch target friendly, year-level precision sufficient | PM |
| 2024-12-17 | Phase colors auto-assigned | Zero friction, editable later for power users | PM |
| 2024-12-17 | Apple Intelligence → V1.5 | MVP scope risk, device limitations, need user data first | PM |
| 2024-12-17 | Face ID removed from scope | iOS has native app lock, unnecessary complexity | PM |

---

## Appendix

### A. Reference Materials
- [Wait But Why: Your Life in Weeks](https://waitbutwhy.com/2014/05/life-weeks.html) — Original concept
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit/)

### B. Inspiration
- Seneca quote: "Hurry up and live."
- The reference image shows a poster-style grid with "life in weeks" header and Seneca attribution

### C. Tools & Resources
| Purpose | Tool |
|---------|------|
| IDE | Xcode |
| Code Assistance | Claude Code, GitHub Copilot |
| Version Control | GitHub |
| Design Mockups | Gemini image models |
| Project Tracking | GitHub Issues + this PRD |

### D. Contact
- **Developer:** Jwala
- **Repository:** TBD (github.com/jwala/finite)

---

*This document is the single source of truth for Finite. Update it as decisions are made.*