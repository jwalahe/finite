# UX Phase Fix: Chapters View Phase Management

## Overview

This document details UX improvements for phase management in the Finite app.

**Key Changes:**
1. Move phase add/edit from Settings into Chapters view for zero-friction management
2. Keep GhostPhase for quick info (long-press) while adding direct edit (tap)
3. Remove CHAPTERS section from Settings entirely

**Design Goals:**
- Lowest possible friction
- Slick UX
- Best performance
- Edit where you see, not in a buried menu

---

## Current State (Problem)

```
┌─────────────────────────────────────────────────────────────────┐
│  CURRENT PHASE MANAGEMENT FLOW                                  │
│                                                                 │
│  User wants to add/edit a chapter:                              │
│                                                                 │
│  Chapters View → Settings Tab → "Manage Chapters" →             │
│  Phase List → Add/Edit Phase                                    │
│                                                                 │
│  = 4+ taps, context switch, hidden functionality                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Problems:**
- Users don't know phases are editable
- Settings is the wrong place for content creation
- Context switch breaks flow
- Walkthrough can't easily guide to Settings

---

## Target State (Solution)

```
┌─────────────────────────────────────────────────────────────────┐
│  NEW PHASE MANAGEMENT FLOW                                      │
│                                                                 │
│  Option A: Add new phase                                        │
│  Chapters View → Tap "+" on Time Spine → Phase Form Sheet       │
│  = 2 taps, in context                                           │
│                                                                 │
│  Option B: Edit existing phase                                  │
│  Chapters View → Tap phase segment on Time Spine → Edit Sheet   │
│  = 2 taps, in context                                           │
│                                                                 │
│  Option C: Quick phase info (preserved)                         │
│  Chapters View → Long-press phase segment → GhostPhase summon   │
│  = Existing behavior preserved for quick reference              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Visual Design: Enhanced Chapters View

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌───┐                                            Age 29        │
│  │   │  ████████  Childhood                                     │
│  │   │                                                          │
│  │ T │  ████████████  School    ┌─────────────────────────┐    │
│  │ I │                          │                         │    │
│  │ M │  ████████  College       │      LIFE GRID          │    │
│  │ E │                          │      (52 x ~80)         │    │
│  │   │  ████████████████        │                         │    │
│  │ S │  Career ← TAP=EDIT       │   ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪   │    │
│  │ P │         HOLD=INFO        │   ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪   │    │
│  │ I │                          │   ▪▪▪▪████████████▪▪   │    │
│  │ N │  [+] ← ADD BUTTON        │   ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪   │    │
│  │ E │                          └─────────────────────────┘    │
│  └───┘                                                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Career • 2018–present • 312 weeks                  ✎   │   │
│  │  ← TAP TO EDIT CURRENT PHASE                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│                          ● ○ ○                                  │
│                      (view mode dots)                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Changes

### 1. TimeSpine Enhancement

The TimeSpine gains dual interaction:
- **Tap** → Edit phase (new)
- **Long-press** → Show GhostPhase info (existing)
- **"+" button** → Add new phase (new)

```swift
// TimeSpine.swift changes

struct TimeSpine: View {
    // Existing properties...

    // NEW: Callbacks
    let onPhaseTap: ((LifePhase) -> Void)?      // Tap = Edit
    let onAddPhaseTap: (() -> Void)?             // Tap + = Add
    // KEEP: onPhaseTapped for GhostPhase (long-press)

    var body: some View {
        // ... existing canvas rendering ...

        // Add gesture handling:
        // - Tap → onPhaseTap?(phase) → opens edit sheet
        // - Long-press → existing onPhaseTapped behavior → GhostPhase

        // NEW: Add button at bottom
        if showAddButton {
            AddPhaseButton(action: onAddPhaseTap)
        }
    }
}
```

### 2. PhaseContextBar Enhancement

Make the existing PhaseContextBar tappable:

```swift
// PhaseContextBar.swift changes

struct PhaseContextBar: View {
    // Existing properties...

    // NEW: Edit callback
    let onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            // Existing content...

            // NEW: Add pencil icon as edit affordance
            Image(systemName: "pencil")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
    }
}
```

### 3. GridView Integration

Wire up the new interactions:

```swift
// GridView.swift changes

// NEW: State for edit sheet
@State private var phaseToEdit: LifePhase?
@State private var showAddPhaseSheet = false

// TimeSpine with new callbacks
TimeSpine(
    // existing params...
    onPhaseTap: { phase in
        phaseToEdit = phase  // Opens edit sheet
    },
    onAddPhaseTap: {
        showAddPhaseSheet = true
    }
)

// PhaseContextBar with tap handler
PhaseContextBar(
    // existing params...
    onTap: {
        if let phase = currentPhase {
            phaseToEdit = phase
        } else {
            showAddPhaseSheet = true
        }
    }
)

// Sheets
.sheet(item: $phaseToEdit) { phase in
    PhaseFormView(mode: .edit(phase), ...)
}
.sheet(isPresented: $showAddPhaseSheet) {
    PhaseFormView(mode: .add, ...)
}
```

### 4. Settings Simplification

Remove CHAPTERS section entirely:

```swift
// SettingsView.swift changes

// DELETE: chaptersSection
// DELETE: All phase-related navigation
// DELETE: showPhaseBuilder state

// The Settings view becomes simpler:
// - YOUR LIFE (birth date, life expectancy)
// - REMINDERS (notifications)
// - DATA (erase)
```

---

## Walkthrough Flow

The existing walkthrough flow is correct. No changes needed to step order or swipe direction.

**Current flow (keep as-is):**
1. gridIntro (Focus) - "Each dot is one week..."
2. currentWeekIntro (Focus) - "The glowing dot is this week"
3. swipeToChapters - "Swipe left to add color" ← CORRECT (swipe left = next view)
4. explainChapters (Chapters) - "Chapters are phases of your life"
5. addPhase - "Tap anywhere to add your first chapter" → UPDATE to spotlight "+" button
6. tapSpine - "Tap any color on the timeline..." → UPDATE messaging
7. swipeToQuality - "Swipe left once more..."
8. markWeek (Quality) - "Hold any filled week..."
9. complete - "Your life is finite—make it count"

**Walkthrough updates needed:**
- Step 5 (addPhase): Spotlight the "+" button instead of full dim
- Step 6 (tapSpine): Update to explain tap=edit, hold=info

---

## Interaction Summary

| Location | Gesture | Current Behavior | New Behavior |
|----------|---------|------------------|--------------|
| TimeSpine segment | Tap | Shows GhostPhase | **Opens edit sheet** |
| TimeSpine segment | Long-press | Shows GhostPhase | Shows GhostPhase (unchanged) |
| TimeSpine "+" | Tap | N/A | **Opens add sheet** |
| PhaseContextBar | Tap | None | **Opens edit sheet** |
| Settings CHAPTERS | Tap | Edit phase | **REMOVED** |

---

## Files to Modify

| File | Changes |
|------|---------|
| `TimeSpine.swift` | Add tap handler, add button, dual gesture |
| `PhaseContextBar.swift` | Make tappable, add pencil icon |
| `GridView.swift` | Wire up sheets, add state |
| `SettingsView.swift` | Remove CHAPTERS section |
| `WalkthroughService.swift` | Update addPhase/tapSpine messaging |
| `SpotlightMask.swift` | Add addPhaseButton spotlight |
| `WalkthroughComponents.swift` | Add AddPhaseButtonFrameKey |

---

## Animation & Haptics

| Interaction | Animation | Haptic |
|-------------|-----------|--------|
| Tap phase segment | Scale 0.96x | `.light` |
| Long-press phase segment | Scale 1.05x | `.medium` |
| Tap "+" button | Scale 0.95x | `.light` |
| Tap PhaseContextBar | Scale 0.98x | `.light` |
| Save phase | - | `.success` |
| Delete phase | - | `.warning` |

---

## Testing Checklist

### Phase Management
- [ ] Tap spine segment opens edit sheet with correct phase
- [ ] Long-press spine segment shows GhostPhase (existing behavior)
- [ ] "+" button visible at bottom of spine in Chapters view
- [ ] Tap "+" opens add sheet
- [ ] Tap PhaseContextBar opens edit for current phase
- [ ] Empty state in PhaseContextBar shows prompt
- [ ] Grid recolors after phase changes
- [ ] Settings no longer shows CHAPTERS section

### Walkthrough
- [ ] addPhase step spotlights "+" button
- [ ] tapSpine step explains dual interaction
- [ ] Completing add sheet advances walkthrough

---

## Summary

This refactor:

1. **Moves phase management to Chapters view** - edit where you see
2. **Preserves GhostPhase** - long-press for quick info
3. **Adds tap-to-edit** - direct editing on tap
4. **Adds "+" button** - visible add affordance
5. **Makes PhaseContextBar tappable** - edit current phase
6. **Removes Settings dependency** - no more buried functionality
7. **Updates walkthrough** - guides users to new flow

**Result:** Users can now manage their life chapters exactly where they see them, with 2 taps for edit and preserved long-press for quick info.
