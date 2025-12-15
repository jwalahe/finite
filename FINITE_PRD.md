# Finite — Product Requirements Document

> **Version:** 1.0.0-draft  
> **Last Updated:** December 15, 2024  
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
- [ ] Long-press to mark weeks
- [ ] Bottom sheet with spectrum rating (1-5)
- [ ] Category selection (6 categories)
- [ ] Optional phrase input
- [ ] Color/B&W toggle with animations
- [ ] Widget showing weeks remaining
- [ ] Daily notification (raw number)
- [ ] Milestone notifications
- [ ] Face ID/Touch ID lock
- [ ] Local-only data storage

#### Explicitly Excluded (v1.0) ❌
- Life phases / chapters
- Zoom navigation
- Past week reconstruction (backfilling history)
- Social sharing
- Cloud sync
- Account system
- Analytics / tracking

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
- Total duration: 3-5 seconds
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
US-004: As a user, I want to toggle between color and B&W views so I can choose how I confront my time.

Acceptance Criteria:
- Toggle accessible from main grid view
- Color → B&W: wash-away/drain animation
- B&W → Color: paint-brush bloom animation
- Haptic feedback on toggle
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

#### Security
```
US-008: As a user, I want biometric lock so my life data stays private.

Acceptance Criteria:
- Face ID / Touch ID prompt on app launch
- Fallback to device passcode
- Can be disabled in settings
- No data transmitted externally
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
| 1 | Awful | Deep Red | TBD |
| 2 | Hard | Orange-Red | TBD |
| 3 | Okay | Amber/Neutral | TBD |
| 4 | Good | Soft Green | TBD |
| 5 | Great | Deep Green | TBD |

**UI Colors**
| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Background | Off-white | Near-black |
| Grid (unfilled) | Light gray | Dark gray |
| Grid (filled, B&W mode) | Charcoal | Light gray |
| Current week pulse | Accent | Accent |
| Text | Near-black | Off-white |

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
4. Fill rate: ~50 weeks/second (entire life in 3-5 sec)
5. Each fill accompanied by subtle pencil SFX
6. Haptic thuds at year boundaries (every 52 weeks)
7. Fill stops at current week
8. Current week begins pulsing (scale 1.0 → 1.1 → 1.0, loop)
9. Final haptic: single heavy thud
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

#### View Toggle Animation
```
Color → B&W (Wash Away):
- Colors drain downward like ink washing out
- Duration: 600ms
- Easing: ease-out
- Filled circles remain, but desaturated

B&W → Color (Paint Brush):
- Colors bloom outward from each circle
- Slight stagger (not all at once)
- Duration: 800ms
- Easing: ease-in-out
```

### Wireframes

*To be generated using Gemini image models*

Key screens needed:
1. Onboarding — Birthday input
2. Grid — Full life view (zoomed out)
3. Grid — Current year view (zoomed in)
4. Bottom sheet — Week marking
5. Settings
6. Widget (small)
7. Widget (medium)

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
| Auth | LocalAuthentication | Face ID / Touch ID |

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
    var biometricLockEnabled: Bool = true
    var dailyNotificationEnabled: Bool = true
    var dailyNotificationTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0))!
    var colorModeEnabled: Bool = true // false = B&W mode
    var lifeExpectancy: Int = 80 // years, for calculations
}

// Week.swift
@Model
class Week {
    var weekNumber: Int // 1 to ~4160
    var rating: Int? // 1-5, nil if unmarked
    var category: WeekCategory?
    var phrase: String?
    var markedAt: Date?
    
    init(weekNumber: Int) {
        self.weekNumber = weekNumber
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
│   │   └── GridRevealAnimation.swift
│   ├── WeekDetail/
│   │   ├── WeekDetailSheet.swift
│   │   ├── SpectrumSlider.swift
│   │   ├── CategoryPicker.swift
│   │   └── WeekDetailViewModel.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── SettingsViewModel.swift
├── Core/
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Week.swift
│   │   └── WeekCategory.swift
│   ├── Services/
│   │   ├── HapticService.swift
│   │   ├── AudioService.swift
│   │   ├── NotificationService.swift
│   │   └── BiometricService.swift
│   └── Utilities/
│       ├── DateExtensions.swift
│       └── AnimationExtensions.swift
├── Design/
│   ├── Colors.swift
│   ├── Typography.swift
│   └── Components/
│       ├── PulsingCircle.swift
│       └── AnimatedToggle.swift
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
| Settings | SwiftData (local) | iOS file encryption |

### Privacy Principles
1. **No accounts** — No email, no sign-up
2. **No cloud** — All data stays on device
3. **No analytics** — No tracking, no telemetry
4. **No ads** — Ever
5. **Biometric lock** — Optional but default-on

### App Privacy Label (App Store)
- **Data Not Collected** — The app does not collect any data

---

## Sprint Planning

### Sprint Duration
2 weeks per sprint

### Sprint 0: Setup (Current)
- [x] Product definition
- [x] Design specifications
- [x] Technical architecture
- [ ] Apple Developer enrollment
- [ ] GitHub repo creation
- [ ] Xcode project setup
- [ ] CI/CD setup (optional for v1)

### Sprint 1: The Reveal
**Goal:** Birthday input → Grid reveal animation (the "holy shit" moment)

**Deliverables:**
- Onboarding flow (birthday picker)
- Grid layout (all weeks displayed)
- Reveal animation (sequential fill + SFX + haptics)
- Current week pulse
- Basic navigation structure

**Definition of Done:**
- User can enter birthday
- Grid fills with animation, sound, and haptics
- Current week visually distinct
- App runs on physical device

### Sprint 2: The Mark
**Goal:** Weekly marking ritual fully functional

**Deliverables:**
- Long-press gesture detection
- Bottom sheet with spectrum slider
- Category selection
- Optional phrase input
- Week state persistence
- Color bloom animation on confirm

**Definition of Done:**
- User can mark any week
- Data persists across app launches
- Animations feel polished

### Sprint 3: View & Polish
**Goal:** Color/B&W toggle + visual polish

**Deliverables:**
- View mode toggle
- Wash-away animation (Color → B&W)
- Paint-brush animation (B&W → Color)
- Visual polish pass
- Haptic tuning

**Definition of Done:**
- Toggle works with full animations
- App feels cohesive and premium

### Sprint 4: Widget
**Goal:** Home screen widget

**Deliverables:**
- WidgetKit integration
- Small widget (number only)
- Medium widget (number + context)
- Widget updates weekly

**Definition of Done:**
- Widget installable on home screen
- Shows correct weeks remaining
- Tapping opens app

### Sprint 5: Notifications & Security
**Goal:** Daily notification + biometric lock

**Deliverables:**
- Local notification scheduling
- Daily raw number notification
- Milestone notification logic
- Face ID / Touch ID integration
- Settings screen

**Definition of Done:**
- Notifications fire correctly
- Biometric lock works
- User can configure preferences

### Sprint 6: QA & Launch Prep
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

### v1.0 (MVP) — Sprints 1-6
*See Sprint Planning above*

### v1.1 (Post-Launch)
| Feature | Priority | Notes |
|---------|----------|-------|
| Life Phases | High | User-defined chapters (Infancy, School, etc.) |
| Past Week Reconstruction | Medium | Backfill historical weeks |
| Zoom Navigation | Medium | Pinch to zoom between life/decade/year |
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
- AI features
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
| Q1 | Final color palette hex values? | Open | Design |
| Q2 | Custom SF Symbols for categories or icon library? | Open | Design |
| Q3 | Exact sound effect for pencil fill? | Open | Design |
| Q4 | Life expectancy: fixed at 80 or user-adjustable? | Decided: Default 80, adjustable in settings | PM |
| Q5 | App icon design? | Open | Design |

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
