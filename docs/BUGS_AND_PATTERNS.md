# Finite: Bug Patterns & Fixes Reference

> **Purpose:** Document bugs encountered and fixes applied so we don't repeat them.
> **Rule:** Review this before implementing ANY new feature.

---

## Bug Pattern #1: Gesture Blocking

### Problem
Using `.gesture()` instead of `.simultaneousGesture()` causes gesture conflicts. The first gesture consumes all touch events, blocking swipes, taps, and other interactions.

### Symptom
- Swipe between view modes stops working
- Taps don't register
- App feels "frozen" in certain views

### Root Cause
```swift
// ❌ BAD: Blocks other gestures
.gesture(
    DragGesture(minimumDistance: 0)
        .onChanged { ... }
)
```

### Fix
```swift
// ✅ GOOD: Allows other gestures to work
.simultaneousGesture(
    DragGesture(minimumDistance: 0)
        .onChanged { ... }
)

// ✅ GOOD: For swipe gestures that should take priority
.highPriorityGesture(swipeGesture)
```

### Files Previously Affected
- `GridView.swift` - Loupe gestures in Quality/Horizons views
- `MagnificationLoupe.swift`

---

## Bug Pattern #2: DragGesture(minimumDistance: 0) Touch Consumption

### Problem
`DragGesture(minimumDistance: 0)` activates immediately on touch, consuming ALL touch events including taps meant for other elements.

### Symptom
- Taps on weeks don't work
- Long-press doesn't trigger
- Only drag works, nothing else

### Root Cause
```swift
// ❌ BAD: Consumes all touches immediately
DragGesture(minimumDistance: 0)
```

### Fix
```swift
// ✅ GOOD: Use simultaneousGesture
.simultaneousGesture(
    DragGesture(minimumDistance: 0)
        .onChanged { ... }
)

// ✅ GOOD: Or add minimum distance for intentional drags
DragGesture(minimumDistance: 5)
```

---

## Bug Pattern #3: Missing Enum Cases

### Problem
Adding a new case to an enum but forgetting to handle it in all switch statements causes compile errors or runtime crashes.

### Symptom
- Compile error: "Switch must be exhaustive"
- Runtime crash on unhandled case

### Prevention
```swift
// ✅ GOOD: Always add default or handle all cases
switch viewMode {
case .chapters: ...
case .quality: ...
case .focus: ...
case .horizons: ...
// If adding new case, search for ALL switch statements on this enum
}
```

### Checklist When Adding Enum Case
1. Search codebase for `switch.*enumName`
2. Search for `case .existingCase` to find pattern matches
3. Update ALL locations

---

## Bug Pattern #4: Duplicate Type Definitions

### Problem
Defining the same struct/enum in multiple files causes "invalid redeclaration" compile errors.

### Symptom
- Compile error: "invalid redeclaration of 'TypeName'"

### Example
```swift
// ❌ BAD: ScaleButtonStyle defined in both GridView.swift and ShareWeekSheet.swift
struct ScaleButtonStyle: ButtonStyle { ... }
```

### Fix
- Define shared types in ONE location (usually Design/Components/)
- Import/use from that single source

### Files Previously Affected
- `ScaleButtonStyle` was in both `GridView.swift` and `ShareWeekSheet.swift`

---

## Bug Pattern #5: Not Passing Required Data to Child Views

### Problem
Child views need data from parent but parent forgets to pass it, causing nil values or missing functionality.

### Prevention
```swift
// ✅ GOOD: Always check what child view needs
struct ChildView: View {
    let user: User           // Required
    let weekNumber: Int      // Required
    var optional: String?    // Optional - has default
}

// Parent must provide required params
ChildView(user: user, weekNumber: currentWeek)
```

---

## Bug Pattern #6: Sheet Item Binding Type Mismatch

### Problem
Using `.sheet(item:)` requires the item to conform to `Identifiable`. If the type doesn't match or isn't Identifiable, sheets won't present.

### Fix
```swift
// ✅ GOOD: Ensure enum conforms to Identifiable
enum ShareSheetType: Identifiable {
    case firstWeek
    case achievement(Milestone)

    var id: String {
        switch self {
        case .firstWeek: return "firstWeek"
        case .achievement(let m): return "achievement-\(m.id)"
        }
    }
}

// ✅ GOOD: Use with sheet
.sheet(item: $shareFlow.activeSheet) { sheetType in
    // sheetType is the unwrapped value
}
```

---

## Bug Pattern #7: @Query Not Updating in Real-Time

### Problem
`@Query` results may not immediately reflect just-inserted data within the same view lifecycle.

### Symptom
- Check `allWeeks.isEmpty` returns true even after insert
- Count is stale

### Fix
```swift
// ✅ GOOD: Capture state BEFORE the operation
let wasFirstRating = isFirstRating  // Capture before insert

modelContext.insert(newWeek)        // Insert changes the query result

// Use captured value, not live query
if wasFirstRating {
    ShareFlowController.shared.onFirstWeekRated()
}
```

---

## Bug Pattern #8: Async Task Not Checking Cancellation

### Problem
Async tasks with delays may execute after user has navigated away or cancelled the action.

### Fix
```swift
// ✅ GOOD: Always check Task.isCancelled
Task {
    try? await Task.sleep(nanoseconds: 1_500_000_000)

    guard !Task.isCancelled else { return }  // Check before proceeding

    await MainActor.run {
        // Safe to update UI
    }
}
```

---

## Bug Pattern #9: Animation Blocking User Interaction

### Problem
Long animations or transitions can block user taps if not properly configured.

### Fix
```swift
// ✅ GOOD: Use allowsHitTesting for overlay animations
.allowsHitTesting(false)

// ✅ GOOD: Keep animations short (< 400ms per SST)
withAnimation(.easeOut(duration: 0.25)) { ... }
```

---

## Bug Pattern #10: UserDefaults Flag Not Persisting

### Problem
UserDefaults changes may not persist if app crashes or isn't properly synchronized.

### Prevention
```swift
// ✅ GOOD: Use computed properties with direct access
var hasShownPrompt: Bool {
    get { UserDefaults.standard.bool(forKey: key) }
    set { UserDefaults.standard.set(newValue, forKey: key) }
}

// UserDefaults.standard.synchronize() is deprecated and not needed
// System handles persistence automatically
```

---

## Pre-Implementation Checklist

Before implementing ANY new feature, verify:

- [ ] No `.gesture()` without `.simultaneousGesture()` consideration
- [ ] No `DragGesture(minimumDistance: 0)` blocking touches
- [ ] All enum cases handled in switches
- [ ] No duplicate type definitions
- [ ] All required data passed to child views
- [ ] Sheet items conform to Identifiable
- [ ] @Query state captured before mutations
- [ ] Async tasks check for cancellation
- [ ] Animations don't block interaction
- [ ] UserDefaults flags properly implemented

---

## App Philosophy Reminders

### From SST §2.3 - What 29+ Users DON'T Want
- No streaks that feel manipulative
- No badges/achievements that feel patronizing
- No confetti or performative positivity
- No social features that feel like social media

### From SST §3.2 - Friction Philosophy
- Lowest friction for primary actions
- Deliberate friction for irreversible actions
- Zero friction for exploration

### From SST §12.2 - Animation Specifications
- Primary actions: 250ms max
- View transitions: 300ms
- Never exceed: 400ms

### From SST §12.3 - Haptic Vocabulary
- View switch → `.medium`
- Week selected → `.light`
- Save/Complete → `.success`
- Delete → `.medium`
- Ghost summon → `.heavy`

---

*Last Updated: December 2025*
