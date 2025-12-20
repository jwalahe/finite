# Finite - Bug Tracker

> Living document for tracking bugs found during testing

---

## Active Bugs

*(None currently)*

---

## Resolved Bugs

### BUG-001: Gestures stop working after walkthrough completes
**Status:** Resolved ✓
**Severity:** Critical
**Found:** 2025-12-20
**Resolved:** 2025-12-20
**Component:** GridView / WalkthroughService

**Fix:**
1. Added `.complete` case to all gesture permission functions in `WalkthroughStep` enum
2. Fixed `shouldEnableLoupeGesture` to include Horizons view
3. Changed loupe gestures from `.gesture()` to `.simultaneousGesture()` to prevent blocking swipes
4. Changed swipe gesture from `.gesture()` to `.highPriorityGesture()` to ensure it takes precedence

**Root Cause:** The loupe activation gesture (`DragGesture(minimumDistance: 0)`) was consuming all touch events, preventing the swipe gesture from firing in Quality and Horizons views.

---

### BUG-002: Loupe doesn't show color for future weeks in Horizons view
**Status:** Resolved ✓
**Severity:** Medium
**Found:** 2025-12-20
**Resolved:** 2025-12-20
**Component:** MagnificationLoupe / GridView

**Fix:**
1. Added `milestoneWeeks` and `milestoneColors` parameters to `MagnificationLoupe`
2. Loupe now renders hexagons for milestone weeks instead of circles
3. Added `allowFutureWeeks` parameter to `LoupeState.updatePosition()`
4. In Horizons mode, loupe can now highlight future weeks up to `totalWeeks`

---

### BUG-003: Difficult to track/navigate Horizons on grid
**Status:** Fully Resolved ✓ (5 of 5 features implemented)
**Severity:** Medium (UX)
**Found:** 2025-12-20
**Resolved:** 2025-12-20
**Component:** Horizons View

**Design Direction:** Grid as Terrain (Exploration-First)

**Implemented Features:**

1. ✅ **Gradient Foreshadowing** - `milestoneForeshadowColor()` in GridView
   - 8-week approach zone with 30% max blend toward milestone color
   - Creates sense of "something is coming" as you scroll toward milestones

2. ✅ **Milestone Parallax/Depth** - Canvas rendering in GridView + MagnificationLoupe
   - Upcoming milestones are 15% larger with subtle drop shadow
   - Creates visual "lift" effect - milestones catch your eye like landmarks

3. ✅ **Loupe Depth** - `MilestoneDisplayInfo` + `milestoneInfoBadge()` in MagnificationLoupe
   - Shows milestone name, category, target age, and "when set"
   - Only appears when EXACTLY on a milestone week (no hints for nearby)
   - Rewards curiosity, doesn't guide

**Additional Implemented Features:**

4. ✅ **Drift-to-Rest** - `handleScrollOffsetChange()` + `findNearestMilestoneForDrift()` in GridView
   - Debounced scroll detection (200ms) with gentle spring animation
   - Only active in Horizons mode, uses `ScrollViewReader` for programmatic scrolling
   - "Like a marble settling into shallow divots" - easy to scroll past

5. ✅ **Context Bar as Field Guide** - `MilestoneContextBar` updated
   - Shows "↑ X" (behind) and "↓ Y" (ahead) based on scroll position
   - Updates dynamically as user scrolls through the grid
   - "Tells you about where you ARE, not where to go"

**Rejected Patterns:**
- ❌ Snap-to-milestone (constraint, not freedom)
- ❌ Beacon pulses (attention-seeking)
- ❌ Edge indicators (signage)
- ❌ Double-tap jump (skips the journey)
- ❌ "X weeks away" in loupe (GPS wayfinding)

---

## Notes

- Bugs are numbered sequentially (BUG-XXX)
- Severity levels: Critical, High, Medium, Low
- Status: Open, In Progress, Resolved, Won't Fix, Needs Design
