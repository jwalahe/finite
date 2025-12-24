//
//  GridView.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import SwiftUI
import SwiftData

// Wrapper to make Int work with .sheet(item:)
struct WeekIdentifier: Identifiable {
    let id = UUID()
    let value: Int
}

struct GridView: View {
    let user: User
    let shouldReveal: Bool

    @Environment(\.modelContext) private var modelContext
    @Query private var weeks: [Week]
    @Query private var phases: [LifePhase]
    // Query ALL milestones for grid rendering (including overdue and completed)
    @Query(sort: \Milestone.targetWeekNumber)
    private var allMilestones: [Milestone]

    // Filter to just non-completed for context bar display
    private var milestones: [Milestone] {
        allMilestones.filter { !$0.isCompleted }
    }

    @State private var animationStartTime: Date?
    @State private var hasRevealCompleted: Bool = false

    // Week selection state
    @State private var selectedWeekForDetail: WeekIdentifier?

    // OPTIMIZATION: Cache ratedWeeks to avoid rebuilding on every frame
    @State private var ratedWeeksCache: [Int: Int] = [:]

    // OPTIMIZATION: Cache phase colors for week numbers
    @State private var phaseColorsCache: [Int: String] = [:]

    // OPTIMIZATION: Cache sorted phases to avoid re-sorting on every gradient calculation
    @State private var sortedPhasesCache: [LifePhase] = []

    // SST 6.3: Cache for weeks with notes (micro-indicator dot)
    @State private var weeksWithNotesCache: Set<Int> = []

    // SST 6.3: Cache for high-quality streaks (3+ consecutive weeks of rating 4-5)
    @State private var highQualityStreakWeeks: Set<Int> = []

    // OPTIMIZATION: Pre-computed grid colors array for instant mode switching
    // Index = weekNumber - 1, stores resolved Color for each week
    @State private var gridColorsCache: [Color] = []

    // OPTIMIZATION: Cache milestone week numbers and colors for O(1) lookup during grid render
    @State private var milestoneWeeksCache: Set<Int> = []
    @State private var milestoneColorsCache: [Int: Color] = [:]
    @State private var milestoneStatusCache: [Int: MilestoneGridStatus] = [:]
    @State private var milestoneCountCache: [Int: Int] = [:]  // For same-week count badges

    // BUG-003.3: Cache milestone info for loupe depth display
    @State private var milestoneInfoCache: [Int: MilestoneDisplayInfo] = [:]

    // Status for grid rendering
    enum MilestoneGridStatus {
        case upcoming
        case overdue
        case completed
    }

    // View mode state (Chapters/Quality/Focus)
    @State private var currentViewMode: ViewMode = .focus

    // Week confirm bloom animation
    @State private var bloomWeekNumber: Int?
    @State private var bloomProgress: CGFloat = 0.0
    @State private var isBloomAnimating: Bool = false

    // Settings sheet
    @State private var showSettings: Bool = false

    // Share Week sheet (Week Card viral feature)
    @State private var showShareWeekSheet: Bool = false

    // Phase prompt and builder
    @State private var showPhasePrompt: Bool = false
    @State private var showPhaseBuilder: Bool = false

    // Phase editing (from TimeSpine tap or PhaseContextBar tap)
    @State private var phaseToEdit: LifePhase?

    // Milestone management (Horizons view)
    @State private var showMilestoneBuilder: Bool = false
    @State private var showMilestoneList: Bool = false  // PRD: Context bar tap → List sheet
    @State private var selectedMilestone: Milestone?
    @State private var milestoneToEdit: Milestone?
    @State private var milestoneBuilderPreselectedWeek: Int?

    // Mode label flash
    @State private var showModeLabel: Bool = false

    // Long press tracking for loupe activation (Quality mode)
    @State private var longPressStartTime: Date?
    @State private var longPressLocation: CGPoint?

    // First-time swipe hint
    @State private var showSwipeHint: Bool = false

    // Breathing Aura - current phase color based on scroll position
    @State private var currentAuraColor: Color = .clear

    // Phase highlight state - dims non-phase weeks and summons GhostPhase
    @State private var highlightedPhase: LifePhase?
    @State private var phaseHighlightDismissTask: Task<Void, Never>?

    // Magnification loupe state (Quality view long-press)
    @StateObject private var loupeState = LoupeState()

    // Walkthrough state
    @StateObject private var walkthrough = WalkthroughService.shared

    // View mode transition manager (SST 7.1 signature transitions)
    @StateObject private var transitionManager = ViewModeTransitionManager()

    // Share flow controller (SST §19 viral triggers)
    @StateObject private var shareFlow = ShareFlowController.shared

    @State private var gridFrameForWalkthrough: CGRect = .zero
    @State private var currentWeekFrameForWalkthrough: CGRect = .zero
    @State private var dotIndicatorFrameForWalkthrough: CGRect = .zero

    // BUG-003.4: Drift-to-Rest - scroll settles gently toward milestones
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollEndTime: Date?
    @State private var driftTask: Task<Void, Never>?
    @Namespace private var scrollNamespace

    private let weeksPerRow: Int = 52
    private let revealDuration: Double = 2.0
    // CRAFT_SPEC: Screen margins 24pt
    private let screenMargin: CGFloat = 24
    private let ageLabelWidth: CGFloat = 24

    init(user: User, shouldReveal: Bool = false) {
        self.user = user
        self.shouldReveal = shouldReveal
    }

    // Get week data by week number
    private func weekData(for weekNumber: Int) -> Week? {
        weeks.first { $0.weekNumber == weekNumber }
    }

    // Rebuild cache from weeks data
    private func rebuildRatedWeeksCache() {
        ratedWeeksCache = Dictionary(uniqueKeysWithValues: weeks.compactMap { week -> (Int, Int)? in
            guard let rating = week.rating else { return nil }
            return (week.weekNumber, rating)
        })

        // Also rebuild notes and streak caches
        rebuildWeeksWithNotesCache()
        rebuildHighQualityStreakCache()
    }

    // SST 6.3: Rebuild cache of weeks that have notes (phrase)
    private func rebuildWeeksWithNotesCache() {
        weeksWithNotesCache = Set(weeks.compactMap { week -> Int? in
            guard let phrase = week.phrase, !phrase.isEmpty else { return nil }
            return week.weekNumber
        })
    }

    // SST 6.3: Rebuild cache of weeks that are part of high-quality streaks
    // A streak is 3+ consecutive weeks with rating 4 or 5
    private func rebuildHighQualityStreakCache() {
        var streakWeeks: Set<Int> = []

        // Get all weeks with high ratings (4 or 5), sorted
        let highRatedWeeks = weeks
            .compactMap { week -> Int? in
                guard let rating = week.rating, rating >= 4 else { return nil }
                return week.weekNumber
            }
            .sorted()

        // Find consecutive streaks of 3+
        var currentStreak: [Int] = []

        for weekNum in highRatedWeeks {
            if currentStreak.isEmpty {
                currentStreak.append(weekNum)
            } else if weekNum == currentStreak.last! + 1 {
                // Consecutive - extend streak
                currentStreak.append(weekNum)
            } else {
                // Gap - check if previous streak qualifies
                if currentStreak.count >= 3 {
                    streakWeeks.formUnion(currentStreak)
                }
                currentStreak = [weekNum]
            }
        }

        // Check final streak
        if currentStreak.count >= 3 {
            streakWeeks.formUnion(currentStreak)
        }

        highQualityStreakWeeks = streakWeeks
    }

    // Rebuild phase colors cache from phases data
    // SST 6.2: Phase boundaries have 5-week gradient blend between colors
    // Only includes weeks up to current week (phases don't color the future)
    private func rebuildPhaseColorsCache() {
        var cache: [Int: String] = [:]
        let birthYear = user.birthYear
        let currentWeek = currentWeekNumber

        // Sort phases by start week for proper gradient calculation
        // Also cache the sorted result for use in phaseBlendedColor
        let sortedPhases = phases.sorted { $0.startWeek(birthYear: birthYear) < $1.startWeek(birthYear: birthYear) }
        sortedPhasesCache = sortedPhases

        for (index, phase) in sortedPhases.enumerated() {
            let startWeek = phase.startWeek(birthYear: birthYear)
            // Cap end week at current week - phases only color lived weeks
            let endWeek = min(phase.endWeek(birthYear: birthYear), currentWeek)

            guard startWeek <= endWeek else { continue }

            for weekNum in startWeek...endWeek {
                cache[weekNum] = phase.colorHex
            }

            // Check for next phase to create gradient blend at boundary
            if index + 1 < sortedPhases.count {
                let nextPhase = sortedPhases[index + 1]
                let nextStartWeek = nextPhase.startWeek(birthYear: birthYear)
                let boundaryWeek = endWeek

                // Only blend if phases are adjacent or overlapping
                if nextStartWeek <= boundaryWeek + 1 {
                    // Create 5-week gradient blend zone (2 weeks before boundary, 2 after)
                    let gradientHalfWidth = 2
                    for offset in -gradientHalfWidth...gradientHalfWidth {
                        let blendWeek = boundaryWeek + offset
                        if blendWeek > 0 && blendWeek <= currentWeek {
                            // Store gradient info - actual blending happens in rebuildGridColorsCache
                            // For now, mark the boundary zone
                            if offset < 0 {
                                // Still in current phase
                                cache[blendWeek] = phase.colorHex
                            } else if offset > 0 {
                                // In next phase
                                cache[blendWeek] = nextPhase.colorHex
                            }
                            // offset == 0 is exactly at boundary, keep current phase color
                        }
                    }
                }
            }
        }

        phaseColorsCache = cache
    }

    // Helper to get blended color at phase boundaries
    // Returns the interpolated color for gradient transitions
    // Uses sortedPhasesCache for performance (rebuilt in rebuildPhaseColorsCache)
    private func phaseBlendedColor(for weekNumber: Int) -> Color? {
        let birthYear = user.birthYear

        // Use cached sorted phases for performance
        let sortedPhases = sortedPhasesCache
        guard !sortedPhases.isEmpty else { return nil }

        // Find which phase boundary this week is near
        for (index, phase) in sortedPhases.enumerated() {
            let endWeek = phase.endWeek(birthYear: birthYear)

            // Check if we're in a gradient zone near this phase's end
            if index + 1 < sortedPhases.count {
                let nextPhase = sortedPhases[index + 1]
                let nextStartWeek = nextPhase.startWeek(birthYear: birthYear)

                // Only create gradient for adjacent/overlapping phases
                if nextStartWeek <= endWeek + 1 {
                    let boundaryWeek = min(endWeek, nextStartWeek - 1)
                    let gradientHalfWidth = 2

                    // Check if this week is in the gradient zone
                    if weekNumber >= boundaryWeek - gradientHalfWidth && weekNumber <= boundaryWeek + gradientHalfWidth {
                        let offset = weekNumber - boundaryWeek
                        // -2 to +2 maps to 0.0 to 1.0 blend factor
                        let blendFactor = CGFloat(offset + gradientHalfWidth) / CGFloat(gradientHalfWidth * 2)

                        let fromColor = Color.fromHex(phase.colorHex)
                        let toColor = Color.fromHex(nextPhase.colorHex)

                        return blendColors(from: fromColor, to: toColor, factor: blendFactor)
                    }
                }
            }
        }

        return nil
    }

    // Blend two colors using linear interpolation
    private func blendColors(from: Color, to: Color, factor: CGFloat) -> Color {
        let clampedFactor = max(0, min(1, factor))

        // Convert to UIColor for component access
        let fromUI = UIColor(from)
        let toUI = UIColor(to)

        var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0

        fromUI.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        toUI.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)

        let r = fromR + (toR - fromR) * clampedFactor
        let g = fromG + (toG - fromG) * clampedFactor
        let b = fromB + (toB - fromB) * clampedFactor
        let a = fromA + (toA - fromA) * clampedFactor

        return Color(red: r, green: g, blue: b, opacity: a)
    }

    // BUG-003.1: Gradient Foreshadowing
    // Returns a blended color for weeks approaching a milestone (8-week zone, 30% max blend)
    // Creates a sense of "something is coming" as you approach a milestone
    private func milestoneForeshadowColor(for weekNumber: Int) -> Color? {
        let foreshadowDistance = 8  // 8 weeks of approach zone
        let maxBlend: CGFloat = 0.30  // 30% max blend toward milestone color

        // Find the nearest upcoming milestone from this week
        let upcomingMilestones = allMilestones.filter {
            !$0.isCompleted && $0.targetWeekNumber > weekNumber
        }.sorted { $0.targetWeekNumber < $1.targetWeekNumber }

        guard let nearestMilestone = upcomingMilestones.first else { return nil }

        let distance = nearestMilestone.targetWeekNumber - weekNumber

        // Only foreshadow within the approach zone (and not on the milestone itself)
        guard distance > 0 && distance <= foreshadowDistance else { return nil }

        // Calculate blend factor: closer = stronger blend
        // distance 8 → factor 0.0 (no blend)
        // distance 1 → factor ~0.27 (30% * (7/8) since we cap at 30%)
        let normalizedDistance = CGFloat(foreshadowDistance - distance) / CGFloat(foreshadowDistance)
        let blendFactor = normalizedDistance * maxBlend

        // Get milestone color
        let milestoneColor = milestoneColorsCache[nearestMilestone.targetWeekNumber] ?? Color.textPrimary

        // Blend from gridUnfilled toward milestone color
        return blendColors(from: .gridUnfilled, to: milestoneColor, factor: blendFactor)
    }

    // Rebuild milestone weeks cache for O(1) lookup during grid render
    // PRD: Include overdue (red), completed (checkmark), and same-week count badges
    // BUG-003.3: Also builds milestoneInfoCache for loupe depth display
    private func rebuildMilestoneWeeksCache() {
        let currentWeek = user.currentWeekNumber
        let birthYear = user.birthYear

        var weeks: Set<Int> = []
        var colors: [Int: Color] = [:]
        var statuses: [Int: MilestoneGridStatus] = [:]
        var counts: [Int: Int] = [:]
        var infos: [Int: MilestoneDisplayInfo] = [:]

        for milestone in allMilestones {
            let week = milestone.targetWeekNumber
            weeks.insert(week)

            // Count milestones per week (for same-week badge)
            counts[week, default: 0] += 1

            // Determine status
            let status: MilestoneGridStatus
            if milestone.isCompleted {
                status = .completed
            } else if week < currentWeek {
                status = .overdue
            } else {
                status = .upcoming
            }

            // Only set status/color/info if not already set (prioritize first milestone on same week)
            if statuses[week] == nil {
                statuses[week] = status

                // Color: red for overdue, faded for completed, category color for upcoming
                switch status {
                case .overdue:
                    colors[week] = .red.opacity(0.8)
                case .completed:
                    colors[week] = Color.textSecondary.opacity(0.5)
                case .upcoming:
                    colors[week] = Color.fromHex(milestone.displayColorHex)
                }

                // BUG-003.3: Build info for loupe depth
                infos[week] = MilestoneDisplayInfo(
                    name: milestone.name,
                    categoryName: milestone.category?.displayName,
                    targetAge: milestone.targetAge(birthYear: birthYear),
                    createdAt: milestone.createdAt
                )
            }
        }

        milestoneWeeksCache = weeks
        milestoneColorsCache = colors
        milestoneStatusCache = statuses
        milestoneCountCache = counts
        milestoneInfoCache = infos
    }

    // MARK: - BUG-003.4: Drift-to-Rest

    // Handle scroll offset changes - implements gentle "magnetic" settling toward milestones
    // Like a marble settling into shallow divots - easy to scroll past, freedom preserved
    private func handleScrollOffsetChange(_ offset: CGFloat, scrollProxy: ScrollViewProxy, rowHeight: CGFloat) {
        // Only apply drift in Horizons mode
        guard currentViewMode == .horizons else {
            scrollOffset = offset
            return
        }

        // Cancel any pending drift
        driftTask?.cancel()

        // Record current offset
        scrollOffset = offset

        // Detect scroll end: when offset stabilizes (velocity near zero)
        // We use a debounce approach - if offset hasn't changed significantly after a delay, scroll ended
        driftTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)  // 200ms debounce

            guard !Task.isCancelled else { return }

            // Check if scroll has stabilized (offset hasn't changed much)
            let stillStable = abs(scrollOffset - offset) < 5
            guard stillStable else { return }

            // Find the nearest milestone within drift threshold
            if let nearestMilestone = findNearestMilestoneForDrift(currentOffset: offset, rowHeight: rowHeight) {
                // Gentle drift with spring animation - NOT a snap
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    scrollProxy.scrollTo("milestone-\(nearestMilestone)", anchor: .center)
                }
                HapticService.shared.selection()
            }
        }
    }

    // Find the nearest milestone if within drift threshold
    // Returns nil if no milestone is close enough (freedom preserved)
    private func findNearestMilestoneForDrift(currentOffset: CGFloat, rowHeight: CGFloat) -> Int? {
        // Only consider upcoming milestones (in the future)
        let upcomingMilestones = allMilestones.filter {
            !$0.isCompleted && $0.targetWeekNumber > user.currentWeekNumber
        }

        guard !upcomingMilestones.isEmpty else { return nil }

        // Calculate current visible row based on offset
        // Offset is negative (scrolled content goes up)
        let visibleRow = Int(abs(currentOffset) / rowHeight)
        let visibleWeekStart = visibleRow * weeksPerRow + 1

        // Drift threshold: within 2 rows (1 year) of a milestone
        let driftThresholdWeeks = weeksPerRow * 2  // ~104 weeks = 2 years

        // Find milestone closest to visible area
        var nearestMilestone: Milestone?
        var nearestDistance = Int.max

        for milestone in upcomingMilestones {
            let distance = abs(milestone.targetWeekNumber - visibleWeekStart)
            if distance < driftThresholdWeeks && distance < nearestDistance {
                nearestDistance = distance
                nearestMilestone = milestone
            }
        }

        return nearestMilestone?.targetWeekNumber
    }

    // OPTIMIZATION: Pre-compute all grid colors for the current view mode
    // This runs once when mode changes, then Canvas just reads from array
    private func rebuildGridColorsCache() {
        var colors: [Color] = []
        colors.reserveCapacity(totalWeeks)

        let lived = weeksLived
        let current = currentWeekNumber
        let mode = currentViewMode

        for weekNumber in 1...totalWeeks {
            let isLived = weekNumber <= lived
            let isCurrent = weekNumber == current

            let color: Color
            switch mode {
            case .quality:
                if let rating = ratedWeeksCache[weekNumber] {
                    color = Color.ratingColor(for: rating)
                } else if isCurrent {
                    color = .weekCurrent
                } else if isLived {
                    color = .gridFilled
                } else {
                    color = .gridUnfilled
                }
            case .chapters:
                if isCurrent {
                    color = .weekCurrent
                } else if let blendedColor = phaseBlendedColor(for: weekNumber) {
                    // SST 6.2: Use gradient-blended color at phase boundaries
                    color = blendedColor
                } else if let phaseHex = phaseColorsCache[weekNumber] {
                    color = Color.fromHex(phaseHex)
                } else if isLived {
                    color = .gridFilled
                } else {
                    color = .gridUnfilled
                }
            case .focus:
                if isCurrent {
                    color = .weekCurrent
                } else if isLived {
                    color = .gridFilled
                } else {
                    color = .gridUnfilled
                }
            case .horizons:
                // Horizons mode: past dimmed, future normal, milestones handled separately
                // BUG-003.1: Gradient foreshadowing - weeks approaching milestone blend toward its color
                if isCurrent {
                    color = .weekCurrent
                } else if isLived {
                    color = .gridFilled.opacity(0.3)  // Dimmed past
                } else if let foreshadowColor = milestoneForeshadowColor(for: weekNumber) {
                    // Future week approaching a milestone - blend toward milestone color
                    color = foreshadowColor
                } else {
                    color = .gridUnfilled
                }
            }
            colors.append(color)
        }

        gridColorsCache = colors
    }

    private var totalWeeks: Int { user.totalWeeks }
    private var weeksLived: Int { user.weeksLived }
    private var currentWeekNumber: Int { user.currentWeekNumber }

    // Check if current week is already marked
    private var isCurrentWeekMarked: Bool {
        ratedWeeksCache[currentWeekNumber] != nil
    }


    // Dynamic cell sizing based on available width
    private func calculateGridMetrics(for screenWidth: CGFloat) -> (cellSize: CGFloat, spacing: CGFloat, gridWidth: CGFloat) {
        let availableWidth = screenWidth - (screenMargin * 2) - (ageLabelWidth * 2)
        let cellSize = floor((availableWidth / 64.75) * 2) / 2
        let spacing = cellSize * 0.25
        let gridWidth = CGFloat(weeksPerRow) * (cellSize + spacing) - spacing
        return (cellSize, spacing, gridWidth)
    }

    var body: some View {
        GeometryReader { geometry in
            let metrics = calculateGridMetrics(for: geometry.size.width)
            let cellSize = metrics.cellSize
            let spacing = metrics.spacing
            let gridWidth = metrics.gridWidth
            let rowHeight = cellSize + spacing
            let gridHeight = CGFloat(user.lifeExpectancy) * rowHeight - spacing

            // Dynamic footer sizing based on screen height
            // Larger screens get more footer space, smaller screens get minimum
            let screenHeight = geometry.size.height
            let footerZoneHeight = max(screenHeight * 0.18, 140)  // 18% of screen or min 140pt
            let dotsBottomPadding: CGFloat = 32

            ZStack(alignment: .bottom) {
                // Scrollable content (header + grid)
                // BUG-003.4: Wrapped in ScrollViewReader for Drift-to-Rest
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            headerView
                                .padding(.bottom, 12)

                            // Grid with age labels
                            gridWithLabels(
                                cellSize: cellSize,
                                spacing: spacing,
                                gridWidth: gridWidth,
                                gridHeight: gridHeight
                            )

                            // BUG-003.4: Milestone anchor points for drift-to-rest
                            // Invisible anchors at each milestone row for scrollTo
                            ForEach(Array(milestoneWeeksCache), id: \.self) { week in
                                Color.clear
                                    .frame(height: 1)
                                    .id("milestone-\(week)")
                            }
                        }
                        .padding(.top, 12)
                        .padding(.bottom, footerZoneHeight)  // Prevent grid hiding behind footer
                        // Track scroll offset for drift-to-rest
                        .background(
                            GeometryReader { inner in
                                Color.clear.preference(
                                    key: ScrollOffsetKey.self,
                                    value: inner.frame(in: .named("scroll")).minY
                                )
                            }
                        )
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { offset in
                        handleScrollOffsetChange(offset, scrollProxy: scrollProxy, rowHeight: rowHeight)
                    }
                }

                // Fixed footer overlay at bottom of screen
                if hasRevealCompleted {
                    VStack(spacing: 0) {
                        Spacer()

                        // View mode specific content (centered in zone above dots)
                        VStack(spacing: 8) {
                            viewModeFooterContent

                            // First-time swipe hint (shown once)
                            if showSwipeHint {
                                Text("← Swipe to change view →")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color.bgSecondary.opacity(0.9))
                                    .cornerRadius(8)
                                    .transition(.opacity)
                            }

                            // Mode label (flashes on change)
                            if showModeLabel {
                                Text(currentViewMode.displayName)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.bgPrimary.opacity(0.8))
                                    .cornerRadius(6)
                                    .transition(.opacity)
                            }
                        }

                        Spacer()

                        // Dot indicator pinned to bottom
                        DotIndicator(currentMode: currentViewMode)
                            .padding(.bottom, dotsBottomPadding)
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: DotIndicatorFrameKey.self,
                                        value: geo.frame(in: .global)
                                    )
                                }
                            )
                            .onPreferenceChange(DotIndicatorFrameKey.self) { frame in
                                dotIndicatorFrameForWalkthrough = frame
                                walkthrough.dotIndicatorFrame = frame
                            }
                    }
                    .frame(height: footerZoneHeight)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
                }
            }

            // Breathing Aura (Chapters view only) - CRAFT_SPEC: Screen edge glow with phase color
            if currentViewMode == .chapters && hasRevealCompleted && !phases.isEmpty {
                BreathingAura(phaseColor: currentAuraColor)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            // Focus mode dim overlay (SST 7.1: 10% darker during Focus)
            if transitionManager.dimOverlay > 0 {
                Color.black.opacity(transitionManager.dimOverlay)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            // Walkthrough overlay (interactive guided tutorial)
            if walkthrough.isActive {
                WalkthroughOverlay(
                    walkthrough: walkthrough,
                    onPhasePrompt: {
                        showPhaseBuilder = true
                    }
                )
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .background(Color.bgPrimary)
        .onAppear {
            if shouldReveal {
                startRevealAnimation()
            } else {
                hasRevealCompleted = true
            }
            // Initial cache build
            rebuildRatedWeeksCache()
            rebuildPhaseColorsCache()
            rebuildMilestoneWeeksCache()
            // Sync view mode with user settings
            currentViewMode = user.currentViewMode
            // Build grid colors cache
            rebuildGridColorsCache()
            // Set initial aura color
            updateAuraColor()
        }
        .onChange(of: weeks.count) { _, _ in
            // Rebuild cache when weeks added/deleted
            rebuildRatedWeeksCache()
            rebuildGridColorsCache()
        }
        .onChange(of: weeks.map { "\($0.weekNumber)-\($0.rating ?? 0)" }) { _, _ in
            // Rebuild cache when any week's rating is updated
            rebuildRatedWeeksCache()
            rebuildGridColorsCache()
        }
        .onChange(of: phases.count) { _, _ in
            // Rebuild phase cache when phases added/deleted
            rebuildPhaseColorsCache()
            rebuildGridColorsCache()
            updateAuraColor()
        }
        .onChange(of: phases.map { "\($0.startYear)-\($0.endYear)-\($0.colorHex)" }) { _, _ in
            // Rebuild cache when any phase is edited (years or color changed)
            rebuildPhaseColorsCache()
            rebuildGridColorsCache()
            updateAuraColor()
        }
        .onChange(of: allMilestones.count) { _, _ in
            // Rebuild milestone cache when milestones added/deleted
            rebuildMilestoneWeeksCache()
        }
        .onChange(of: allMilestones.map { "\($0.targetWeekNumber)-\($0.isCompleted)-\($0.categoryRaw ?? "")" }) { _, _ in
            // Rebuild cache when any milestone is edited
            rebuildMilestoneWeeksCache()
        }
        .sheet(item: $selectedWeekForDetail) { weekId in
            let weekNumberToCheck = weekId.value

            WeekDetailSheet(
                user: user,
                weekNumber: weekId.value,
                existingWeek: weekData(for: weekId.value)
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .onDisappear {
                // Rebuild cache after sheet dismisses (week may have been updated)
                rebuildRatedWeeksCache()

                // Trigger bloom animation if week was newly rated or updated
                // Small delay to let cache rebuild complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if ratedWeeksCache[weekNumberToCheck] != nil {
                        triggerBloomAnimation(for: weekNumberToCheck)
                    }

                    // Advance walkthrough when sheet dismisses (only if on markWeek step)
                    // Must check step here because it could have changed during sheet display
                    if walkthrough.currentStep == .markWeek {
                        walkthrough.handleWeekMarked()
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(user: user)
        }
        .sheet(isPresented: $showShareWeekSheet) {
            ShareWeekSheet(user: user)
        }
        // SST §18: Viral share sheets triggered by emotional moments
        .sheet(item: $shareFlow.activeSheet) { sheetType in
            switch sheetType {
            case .firstWeek, .ghostReveal, .quickShare:
                PerspectiveShareSheet(user: user, triggerType: sheetType)
            case .achievement(let milestone):
                AchievementShareSheet(milestone: milestone, user: user)
            case .yearTransition:
                // TODO: YearTransitionShareSheet
                PerspectiveShareSheet(user: user, triggerType: sheetType)
            }
        }
        .sheet(isPresented: $showPhaseBuilder) {
            PhaseFlowCoordinator(user: user, isPresented: $showPhaseBuilder)
                .onDisappear {
                    // Check if walkthrough is waiting for phase action
                    if walkthrough.currentStep == .addPhase {
                        // Check if phase was added
                        if !phases.isEmpty {
                            walkthrough.handlePhaseAdded()
                        } else {
                            walkthrough.handlePhaseSkipped()
                        }
                    }
                }
        }
        .sheet(item: $phaseToEdit) { phase in
            PhaseEditView(user: user, phase: phase)
        }
        .sheet(isPresented: $showMilestoneBuilder) {
            MilestoneBuilderView(
                user: user,
                mode: milestoneToEdit.map { .edit($0) } ?? .add(preselectedWeek: milestoneBuilderPreselectedWeek),
                onSave: { _ in
                    milestoneBuilderPreselectedWeek = nil
                },
                onDelete: {
                    if let milestone = milestoneToEdit {
                        modelContext.delete(milestone)
                    }
                    milestoneBuilderPreselectedWeek = nil
                }
            )
        }
        .onChange(of: showMilestoneBuilder) { _, isShowing in
            if !isShowing {
                // Reset preselected week when sheet closes
                milestoneBuilderPreselectedWeek = nil
                milestoneToEdit = nil
            }
        }
        .sheet(item: $selectedMilestone) { milestone in
            MilestoneDetailSheet(
                milestone: milestone,
                user: user,
                onEdit: {
                    selectedMilestone = nil
                    milestoneToEdit = milestone
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showMilestoneBuilder = true
                    }
                },
                onComplete: {
                    milestone.complete(atWeek: user.currentWeekNumber)
                    HapticService.shared.success()
                    selectedMilestone = nil
                    // SST §18.3: Trigger share prompt after milestone completion
                    shareFlow.onMilestoneCompleted(milestone)
                }
            )
        }
        .sheet(isPresented: $showMilestoneList) {
            // PRD: Context bar → List sheet with .medium/.large detents
            MilestoneListView(user: user) { milestone in
                // Row tap → dismiss list, open detail (with delay built into MilestoneListView)
                selectedMilestone = milestone
            }
        }
        .overlay {
            if showPhasePrompt {
                PhasePromptOverlay(
                    user: user,
                    isPresented: $showPhasePrompt,
                    showPhaseBuilder: $showPhaseBuilder
                )
                .transition(.opacity)
            }
        }
    }

    // MARK: - Timeline Scrubber (Delegated to isolated view)

    // MARK: - Grid with Age Labels

    private func gridWithLabels(
        cellSize: CGFloat,
        spacing: CGFloat,
        gridWidth: CGFloat,
        gridHeight: CGFloat
    ) -> some View {
        let rowHeight = cellSize + spacing
        let currentAge = user.yearsLived
        let nearestDecade = ((currentAge + 5) / 10) * 10
        let distanceToDecade = abs(currentAge - nearestDecade)
        let showCurrentAge = distanceToDecade > 2

        return HStack(alignment: .top, spacing: 0) {
            // Time Spine (Chapters view only, when phases exist OR during addPhase walkthrough step)
            // Tap = show info, Double-tap = edit, "+" = Add
            let showSpineForWalkthrough = walkthrough.isActive && walkthrough.currentStep == .addPhase
            if currentViewMode == .chapters && hasRevealCompleted && (!phases.isEmpty || showSpineForWalkthrough) {
                TimeSpine(
                    user: user,
                    phases: phases,
                    gridHeight: gridHeight,
                    onPhaseEdit: { phase in
                        phaseToEdit = phase
                    },
                    onPhaseLongPress: { phase, yPos in
                        handleSpineTap(phase: phase, yPosition: yPos)
                    },
                    onAddPhase: {
                        showPhaseBuilder = true
                        // Advance walkthrough if on addPhase step
                        if walkthrough.currentStep == .addPhase {
                            // Will be handled by sheet onDisappear
                        }
                    }
                )
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: SpineFrameKey.self,
                            value: geo.frame(in: .global)
                        )
                    }
                )
                .onPreferenceChange(SpineFrameKey.self) { frame in
                    walkthrough.spineFrame = frame
                }
                .onPreferenceChange(AddPhaseButtonFrameKey.self) { frame in
                    walkthrough.addPhaseButtonFrame = frame
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            // Left age labels (hide when spine is showing to save space)
            if currentViewMode != .chapters || phases.isEmpty {
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(0..<user.lifeExpectancy, id: \.self) { year in
                        let isDecadeMark = year == 0 || year % 10 == 0
                        let isCurrentAge = year == currentAge && showCurrentAge
                        let showLabel = isDecadeMark || isCurrentAge

                        Text(showLabel ? "\(year)" : "")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(year == currentAge ? Color.textPrimary : Color.textTertiary)
                            .frame(width: ageLabelWidth, height: rowHeight, alignment: .trailing)
                    }
                }
                .padding(.trailing, 6)
            }

            // Grid
            ZStack(alignment: .topLeading) {
                if shouldReveal && !hasRevealCompleted {
                    animatedGridContent(cellSize: cellSize, spacing: spacing, gridWidth: gridWidth, gridHeight: gridHeight)
                } else {
                    staticGridWithCurrentWeek(
                        cellSize: cellSize,
                        spacing: spacing,
                        gridWidth: gridWidth,
                        gridHeight: gridHeight
                    )
                }

            }
            .frame(width: gridWidth, height: gridHeight)
            // SST 7.1: Desaturation during view mode transitions
            .saturation(1.0 - transitionManager.desaturation)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: GridFrameKey.self,
                        value: geo.frame(in: .global)
                    )
                }
            )
            .onPreferenceChange(GridFrameKey.self) { frame in
                gridFrameForWalkthrough = frame
                walkthrough.gridFrame = frame
            }
            .contentShape(Rectangle())
            .highPriorityGesture(swipeGesture)

            // Right age labels
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<user.lifeExpectancy, id: \.self) { year in
                    let isDecadeMark = year == 0 || year % 10 == 0
                    let isCurrentAge = year == currentAge && showCurrentAge
                    let showLabel = isDecadeMark || isCurrentAge

                    Text(showLabel ? "\(year)" : "")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(year == currentAge ? Color.textPrimary : Color.textTertiary)
                        .frame(width: ageLabelWidth, height: rowHeight, alignment: .leading)
                }
            }
            .padding(.leading, 6)
        }
        .padding(.horizontal, screenMargin)
        .animation(.easeOut(duration: 0.2), value: currentViewMode)
    }

    // MARK: - Static Grid with Current Week Indicator

    private func staticGridWithCurrentWeek(
        cellSize: CGFloat,
        spacing: CGFloat,
        gridWidth: CGFloat,
        gridHeight: CGFloat
    ) -> some View {
        // Capture cache locally to avoid closure capturing self
        let colors = gridColorsCache
        let total = totalWeeks
        let perRow = weeksPerRow
        let milestoneWeeks = milestoneWeeksCache
        let milestoneColors = milestoneColorsCache
        let milestoneStatuses = milestoneStatusCache
        let milestoneCounts = milestoneCountCache
        let viewMode = currentViewMode

        return ZStack(alignment: .topLeading) {
            // OPTIMIZATION: Canvas reads from pre-computed color array
            // No state dependencies inside closure = no recomputation on state change
            Canvas { context, _ in
                guard colors.count == total else { return }

                for weekNumber in 1...total {
                    let index = weekNumber - 1
                    let row = index / perRow
                    let col = index % perRow
                    let x = CGFloat(col) * (cellSize + spacing)
                    let y = CGFloat(row) * (cellSize + spacing)
                    let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)

                    // Draw milestone markers in Horizons view
                    // BUG-003.2: Milestone Parallax/Depth - slight scale + shadow for "landmark" effect
                    if viewMode == .horizons && milestoneWeeks.contains(weekNumber) {
                        let status = milestoneStatuses[weekNumber]
                        let markerColor = milestoneColors[weekNumber] ?? Color.textPrimary

                        // Depth effect: 15% larger for upcoming milestones, creates visual "lift"
                        let depthScale: CGFloat = (status == .upcoming) ? 1.15 : 1.0
                        let depthSize = cellSize * depthScale
                        let depthOffset = (depthSize - cellSize) / 2
                        let depthRect = CGRect(
                            x: x - depthOffset,
                            y: y - depthOffset,
                            width: depthSize,
                            height: depthSize
                        )

                        // Draw shadow for upcoming milestones (subtle depth cue)
                        if status == .upcoming {
                            let shadowOffset: CGFloat = 2
                            let shadowRect = depthRect.offsetBy(dx: shadowOffset, dy: shadowOffset)
                            let shadowHex = hexagonPath(in: shadowRect)
                            context.fill(shadowHex, with: .color(Color.black.opacity(0.15)))
                        }

                        switch status {
                        case .completed:
                            // PRD: Completed = checkmark, faded (no depth effect)
                            // Draw a simple checkmark shape
                            let checkPath = checkmarkPath(in: rect)
                            context.fill(checkPath, with: .color(markerColor))

                        case .overdue:
                            // PRD: Overdue = hexagon, red tint (no depth effect - in past)
                            let hexPath = hexagonPath(in: rect)
                            context.fill(hexPath, with: .color(markerColor))

                        case .upcoming, .none:
                            // PRD: Upcoming = hexagon with category color + depth effect
                            let hexPath = hexagonPath(in: depthRect)
                            context.fill(hexPath, with: .color(markerColor))
                        }

                        // PRD: Same-week count badge (if multiple milestones)
                        if let count = milestoneCounts[weekNumber], count > 1 {
                            let badgeSize: CGFloat = cellSize * 0.5
                            let badgeX = x + cellSize - badgeSize / 2
                            let badgeY = y - badgeSize / 2
                            let badgeRect = CGRect(x: badgeX, y: badgeY, width: badgeSize, height: badgeSize)
                            let badgeCircle = Path(ellipseIn: badgeRect)
                            context.fill(badgeCircle, with: .color(.red))
                        }
                    } else {
                        let circle = Path(ellipseIn: rect)
                        context.fill(circle, with: .color(colors[index]))
                    }
                }
            }
            .frame(width: gridWidth, height: gridHeight)
            .drawingGroup()

            // Current week pulse ring (more visible)
            currentWeekPulseRing(cellSize: cellSize, spacing: spacing)

            // Milestone pulse rings (Horizons view only - subtle pulse on upcoming milestones)
            if currentViewMode == .horizons {
                milestonePulseRings(cellSize: cellSize, spacing: spacing)
            }

            // Bloom animation overlay (when a week is confirmed)
            if let bloomWeek = bloomWeekNumber {
                bloomRingOverlay(weekNumber: bloomWeek, cellSize: cellSize, spacing: spacing)
            }

            // Phase highlight dim overlay (when spine segment is tapped)
            if let phase = highlightedPhase {
                phaseHighlightDimOverlay(
                    phase: phase,
                    cellSize: cellSize,
                    spacing: spacing,
                    gridWidth: gridWidth,
                    gridHeight: gridHeight
                )
            }

            // Tap gesture for current week quick access (Quality mode)
            // Also tap to select week within highlighted phase (Chapters mode)
            // Also tap on milestone markers in Horizons view
            if currentViewMode == .quality || highlightedPhase != nil {
                weekTapTarget(cellSize: cellSize, spacing: spacing)
            } else if currentViewMode == .chapters && highlightedPhase == nil {
                // Only current week tap in Chapters when no phase highlighted
                currentWeekTapTarget(cellSize: cellSize, spacing: spacing)
            } else if currentViewMode == .horizons {
                // Horizons: tap on milestones to view details
                milestoneTapTarget(cellSize: cellSize, spacing: spacing)
            }

            // Magnification loupe overlay (Quality and Horizons view long-press)
            if loupeState.isActive && (currentViewMode == .quality || currentViewMode == .horizons) {
                // Dim the grid behind the loupe for clarity
                Color.bgPrimary.opacity(0.6)
                    .frame(width: gridWidth, height: gridHeight)
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .zIndex(199)

                MagnificationLoupe(
                    position: loupeState.position,
                    highlightedWeek: loupeState.highlightedWeek,
                    cellSize: cellSize,
                    spacing: spacing,
                    gridColors: gridColorsCache,
                    weeksPerRow: weeksPerRow,
                    totalWeeks: totalWeeks,
                    milestoneWeeks: currentViewMode == .horizons ? milestoneWeeksCache : [],
                    milestoneColors: currentViewMode == .horizons ? milestoneColorsCache : [:],
                    milestoneInfo: currentViewMode == .horizons ? milestoneInfoCache : [:],
                    userBirthYear: user.birthYear
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(200)
            }
        }
        .frame(width: gridWidth, height: gridHeight)
    }

    // MARK: - Phase Highlight Dim Overlay
    // Dims weeks outside the highlighted phase to 30% opacity

    private func phaseHighlightDimOverlay(
        phase: LifePhase,
        cellSize: CGFloat,
        spacing: CGFloat,
        gridWidth: CGFloat,
        gridHeight: CGFloat
    ) -> some View {
        let birthYear = user.birthYear
        let startWeek = phase.startWeek(birthYear: birthYear)
        let endWeek = min(phase.endWeek(birthYear: birthYear), currentWeekNumber)

        return Canvas { context, _ in
            // Draw semi-transparent overlay on weeks OUTSIDE the phase
            for weekNumber in 1...totalWeeks {
                let isInPhase = weekNumber >= startWeek && weekNumber <= endWeek

                if !isInPhase {
                    let row = (weekNumber - 1) / weeksPerRow
                    let col = (weekNumber - 1) % weeksPerRow
                    let x = CGFloat(col) * (cellSize + spacing)
                    let y = CGFloat(row) * (cellSize + spacing)
                    let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                    let circle = Path(ellipseIn: rect)

                    // Dim with background color at 70% opacity (makes dots appear at 30%)
                    context.fill(circle, with: .color(Color.bgPrimary.opacity(0.7)))
                }
            }
        }
        .frame(width: gridWidth, height: gridHeight)
        .allowsHitTesting(false)
        .transition(.opacity)
    }

    // MARK: - Bloom Ring Overlay (Week Confirm Animation)

    private func bloomRingOverlay(weekNumber: Int, cellSize: CGFloat, spacing: CGFloat) -> some View {
        let row = (weekNumber - 1) / weeksPerRow
        let col = (weekNumber - 1) % weeksPerRow
        let x = CGFloat(col) * (cellSize + spacing) + cellSize / 2
        let y = CGFloat(row) * (cellSize + spacing) + cellSize / 2

        // Get the rating color for this week
        let rating = ratedWeeksCache[weekNumber] ?? 3
        let color = Color.ratingColor(for: rating)

        // Bloom expands from cell size to larger radius
        let maxRadius: CGFloat = 80
        let currentRadius = cellSize / 2 + (maxRadius * bloomProgress)
        let opacity = 0.8 * (1.0 - bloomProgress) // Fades out as it expands

        return ZStack {
            // Outer expanding ring
            Circle()
                .stroke(color.opacity(opacity * 0.5), lineWidth: 3)
                .frame(width: currentRadius * 2, height: currentRadius * 2)
                .position(x: x, y: y)

            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            color.opacity(opacity * 0.6),
                            color.opacity(0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: currentRadius
                    )
                )
                .frame(width: currentRadius * 2, height: currentRadius * 2)
                .position(x: x, y: y)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Current Week Pulse Ring (More Visible)
    // OPTIMIZATION: Pauses during scrub to reduce concurrent animations

    private func currentWeekPulseRing(cellSize: CGFloat, spacing: CGFloat) -> some View {
        let row = (currentWeekNumber - 1) / weeksPerRow
        let col = (currentWeekNumber - 1) % weeksPerRow
        let x = CGFloat(col) * (cellSize + spacing) + cellSize / 2
        let y = CGFloat(row) * (cellSize + spacing) + cellSize / 2

        return ZStack {
            // Animated pulse ring
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let phase = (sin(elapsed * .pi * 0.8) + 1) / 2
                let ringScale = 1.8 + (0.6 * phase)
                let ringOpacity = 0.6 - (0.4 * phase)

                Circle()
                    .stroke(Color.weekCurrent.opacity(ringOpacity), lineWidth: 2)
                    .frame(width: cellSize * ringScale, height: cellSize * ringScale)
                    .position(x: x, y: y)
            }

            // Frame tracker for walkthrough (static, outside TimelineView)
            Circle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
                .position(x: x, y: y)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                // Calculate frame based on position within parent
                                let parentFrame = geo.frame(in: .global)
                                let weekFrame = CGRect(
                                    x: parentFrame.minX + x - cellSize / 2,
                                    y: parentFrame.minY + y - cellSize / 2,
                                    width: cellSize,
                                    height: cellSize
                                )
                                currentWeekFrameForWalkthrough = weekFrame
                                walkthrough.currentWeekFrame = weekFrame
                            }
                            .onChange(of: geo.frame(in: .global)) { _, newFrame in
                                let weekFrame = CGRect(
                                    x: newFrame.minX + x - cellSize / 2,
                                    y: newFrame.minY + y - cellSize / 2,
                                    width: cellSize,
                                    height: cellSize
                                )
                                currentWeekFrameForWalkthrough = weekFrame
                                walkthrough.currentWeekFrame = weekFrame
                            }
                    }
                )
        }
        .allowsHitTesting(false)
    }

    // MARK: - Milestone Pulse Rings (Horizons View)
    // Subtle pulsing rings around upcoming milestones to provide visual feedback

    private func milestonePulseRings(cellSize: CGFloat, spacing: CGFloat) -> some View {
        // Only show pulse on first 5 upcoming milestones to avoid visual clutter
        let upcomingMilestones = allMilestones
            .filter { !$0.isCompleted && $0.targetWeekNumber > currentWeekNumber }
            .prefix(5)

        return ZStack {
            ForEach(Array(upcomingMilestones), id: \.id) { milestone in
                let weekNumber = milestone.targetWeekNumber
                let row = (weekNumber - 1) / weeksPerRow
                let col = (weekNumber - 1) % weeksPerRow
                let x = CGFloat(col) * (cellSize + spacing) + cellSize / 2
                let y = CGFloat(row) * (cellSize + spacing) + cellSize / 2
                let color = Color.fromHex(milestone.displayColorHex)

                // Subtle pulse ring
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    let elapsed = timeline.date.timeIntervalSinceReferenceDate
                    // Stagger the animation for each milestone
                    let offset = Double(weekNumber) * 0.3
                    let phase = (sin((elapsed + offset) * .pi * 0.5) + 1) / 2
                    let ringScale = 1.5 + (0.5 * phase)
                    let ringOpacity = 0.4 - (0.3 * phase)

                    Circle()
                        .stroke(color.opacity(ringOpacity), lineWidth: 1.5)
                        .frame(width: cellSize * ringScale, height: cellSize * ringScale)
                        .position(x: x, y: y)
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Current Week Tap Target

    private func currentWeekTapTarget(cellSize: CGFloat, spacing: CGFloat) -> some View {
        let row = (currentWeekNumber - 1) / weeksPerRow
        let col = (currentWeekNumber - 1) % weeksPerRow
        let x = CGFloat(col) * (cellSize + spacing)
        let y = CGFloat(row) * (cellSize + spacing)
        let tapSize: CGFloat = 44 // Minimum iOS tap target

        return Color.clear
            .frame(width: tapSize, height: tapSize)
            .contentShape(Rectangle())
            .onTapGesture {
                // Block during walkthrough
                guard !walkthrough.isActive else { return }

                HapticService.shared.light()

                // Open week detail
                selectedWeekForDetail = WeekIdentifier(value: currentWeekNumber)
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                // Block during walkthrough
                guard !walkthrough.isActive else { return }

                // Long-press current week → Share Perspective Card
                // SST §18.6: "Preserved but de-prioritized. For power users."
                shareFlow.onLongPressCurrentWeek()
            }
            .offset(x: x - (tapSize - cellSize) / 2, y: y - (tapSize - cellSize) / 2)
    }

    // MARK: - Milestone Tap Target (Horizons View)
    // Tap on milestones to view/edit, tap on future empty weeks to add
    // Long-press activates loupe for navigating milestones on grid

    private func milestoneTapTarget(cellSize: CGFloat, spacing: CGFloat) -> some View {
        GeometryReader { _ in
            Color.clear
                .contentShape(Rectangle())
                // Use simultaneousGesture to allow swipe gestures to work alongside loupe
                .simultaneousGesture(horizonsModeGesture(cellSize: cellSize, spacing: spacing))
                .onTapGesture { location in
                    handleMilestoneTap(at: location, cellSize: cellSize, spacing: spacing)
                }
        }
    }

    // Horizons mode gesture: long-press activates loupe for finding milestones
    // Blocked during walkthrough (Horizons is last step, no interaction needed)
    private func horizonsModeGesture(cellSize: CGFloat, spacing: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                // Block during walkthrough
                guard !walkthrough.isActive else { return }

                let holdDuration: TimeInterval = 0.3

                if longPressStartTime == nil {
                    longPressStartTime = Date()
                    longPressLocation = value.startLocation
                }

                // Check if held long enough to activate loupe
                if let startTime = longPressStartTime,
                   Date().timeIntervalSince(startTime) >= holdDuration {
                    if !loupeState.isActive {
                        // Activate loupe
                        withAnimation(.snappy(duration: 0.15, extraBounce: 0.1)) {
                            loupeState.isActive = true
                            loupeState.position = longPressLocation ?? value.startLocation
                        }
                        HapticService.shared.light()
                    }
                    // Update loupe position - show milestone info if on a milestone week
                    updateMilestoneLoupe(
                        at: value.location,
                        cellSize: cellSize,
                        spacing: spacing
                    )
                }
            }
            .onEnded { value in
                // Block during walkthrough
                guard !walkthrough.isActive else {
                    longPressStartTime = nil
                    longPressLocation = nil
                    return
                }

                let wasActive = loupeState.isActive
                longPressStartTime = nil
                longPressLocation = nil

                if wasActive {
                    // End loupe and handle action
                    let col = Int(value.location.x / (cellSize + spacing))
                    let row = Int(value.location.y / (cellSize + spacing))
                    let weekNumber = row * weeksPerRow + col + 1

                    withAnimation(.snappy(duration: 0.15)) {
                        loupeState.isActive = false
                    }

                    // If on a milestone, open detail; if future empty week, open builder
                    if let milestone = allMilestones.first(where: { $0.targetWeekNumber == weekNumber }) {
                        HapticService.shared.medium()
                        selectedMilestone = milestone
                    } else if weekNumber > currentWeekNumber && weekNumber <= totalWeeks {
                        HapticService.shared.medium()
                        milestoneBuilderPreselectedWeek = weekNumber
                        showMilestoneBuilder = true
                    }
                }
            }
    }

    // Update loupe for Horizons view - shows week number and milestone info
    private func updateMilestoneLoupe(at location: CGPoint, cellSize: CGFloat, spacing: CGFloat) {
        let col = Int(location.x / (cellSize + spacing))
        let row = Int(location.y / (cellSize + spacing))
        let weekNumber = row * weeksPerRow + col + 1

        // Clamp to valid range
        let clampedWeek = max(1, min(weekNumber, totalWeeks))

        loupeState.position = location
        loupeState.currentWeekNumber = clampedWeek

        // Add haptic tick when crossing milestone weeks
        if milestoneWeeksCache.contains(clampedWeek) && loupeState.currentWeekNumber != clampedWeek {
            HapticService.shared.selection()
        }
    }

    private func handleMilestoneTap(at location: CGPoint, cellSize: CGFloat, spacing: CGFloat) {
        // Block during walkthrough
        guard !walkthrough.isActive else { return }

        // Calculate which week was tapped
        let col = Int(location.x / (cellSize + spacing))
        let row = Int(location.y / (cellSize + spacing))
        let weekNumber = row * weeksPerRow + col + 1

        // Check if this week has a milestone (include all milestones, not just upcoming)
        if let milestone = allMilestones.first(where: { $0.targetWeekNumber == weekNumber }) {
            // Open milestone detail
            HapticService.shared.light()
            selectedMilestone = milestone
        } else if weekNumber > currentWeekNumber {
            // Future week without milestone - open builder with this week pre-selected
            HapticService.shared.light()
            milestoneBuilderPreselectedWeek = weekNumber
            showMilestoneBuilder = true
        }
    }

    // MARK: - Week Tap Target (Full Grid)
    // For Quality mode: direct tap on any lived week, long-press for loupe
    // For Chapters mode with highlighted phase: tap to select week within phase

    // Computed property to determine if loupe gesture should be active
    // This helps SwiftUI properly observe changes
    // Loupe works in Quality and Horizons views
    private var shouldEnableLoupeGesture: Bool {
        let isLoupeView = currentViewMode == .quality || currentViewMode == .horizons
        return isLoupeView && walkthrough.allowsLongPress
    }

    private func weekTapTarget(cellSize: CGFloat, spacing: CGFloat) -> some View {
        GeometryReader { _ in
            Color.clear
                .contentShape(Rectangle())
                // Only attach loupe gesture when appropriate
                // Using id() forces view recreation when shouldEnableLoupeGesture changes
                // Use simultaneousGesture to allow swipe gestures to work alongside loupe
                .simultaneousGesture(
                    shouldEnableLoupeGesture
                        ? qualityModeGesture(cellSize: cellSize, spacing: spacing)
                        : nil
                )
                .id(shouldEnableLoupeGesture)  // Force view recreation
                .onTapGesture { location in
                    if !loupeState.isActive {
                        handleWeekTap(at: location, cellSize: cellSize, spacing: spacing)
                    }
                }
        }
    }

    // Swipe gesture for changing view modes
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                // Block swipes during walkthrough unless allowed
                guard walkthrough.allowsSwipe else { return }

                // CRAFT_SPEC: Swipe left/right to change view modes
                let horizontalAmount = value.translation.width
                let verticalAmount = value.translation.height

                // Only trigger if horizontal swipe is dominant
                guard abs(horizontalAmount) > abs(verticalAmount) else { return }

                if horizontalAmount < -50 {
                    // Swipe left → next mode
                    swipeToNextMode()
                } else if horizontalAmount > 50 {
                    // Swipe right → previous mode (blocked during walkthrough)
                    if !walkthrough.isActive {
                        swipeToPreviousMode()
                    }
                }
            }
    }

    // Quality mode gesture: long-press activates loupe at press location, drag moves it
    // Uses DragGesture with minimumDistance:0 to get location immediately,
    // then activates loupe after 0.3s hold time
    // Note: This gesture is only attached when shouldEnableLoupeGesture is true
    private func qualityModeGesture(cellSize: CGFloat, spacing: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let holdDuration: TimeInterval = 0.3

                if longPressStartTime == nil {
                    // First touch - record start time and location
                    longPressStartTime = Date()
                    longPressLocation = value.startLocation
                }

                // Check if we've held long enough to activate loupe
                if let startTime = longPressStartTime,
                   Date().timeIntervalSince(startTime) >= holdDuration {
                    if !loupeState.isActive {
                        // Activate loupe at the original press location
                        withAnimation(.snappy(duration: 0.15, extraBounce: 0.1)) {
                            loupeState.isActive = true
                            loupeState.position = longPressLocation ?? value.startLocation
                        }
                        HapticService.shared.light()
                        // Immediately update to show correct week
                        loupeState.updatePosition(
                            longPressLocation ?? value.startLocation,
                            cellSize: cellSize,
                            spacing: spacing,
                            weeksPerRow: weeksPerRow,
                            weeksLived: weeksLived,
                            totalWeeks: totalWeeks,
                            allowFutureWeeks: currentViewMode == .horizons
                        )
                    }
                    // Update loupe position as user drags
                    loupeState.updatePosition(
                        value.location,
                        cellSize: cellSize,
                        spacing: spacing,
                        weeksPerRow: weeksPerRow,
                        weeksLived: weeksLived,
                        totalWeeks: totalWeeks,
                        allowFutureWeeks: currentViewMode == .horizons
                    )
                }
            }
            .onEnded { _ in
                // Reset long press tracking
                let wasActive = loupeState.isActive
                longPressStartTime = nil
                longPressLocation = nil

                if wasActive {
                    // End loupe and select week
                    if let selectedWeek = loupeState.endLongPress() {
                        selectedWeekForDetail = WeekIdentifier(value: selectedWeek)
                        // Note: Walkthrough advances in sheet's onDisappear after week is actually rated
                    }
                }
            }
    }

    private func handleWeekTap(at location: CGPoint, cellSize: CGFloat, spacing: CGFloat) {
        // Block taps during walkthrough unless on markWeek step
        guard walkthrough.allowsGridTap else { return }

        // Calculate which week was tapped
        let col = Int(location.x / (cellSize + spacing))
        let row = Int(location.y / (cellSize + spacing))
        let weekNumber = row * weeksPerRow + col + 1

        // Validate week is within lived weeks
        guard weekNumber >= 1 && weekNumber <= weeksLived else {
            // Tapped on future week - dismiss phase highlight if active
            if highlightedPhase != nil {
                dismissPhaseHighlight()
            }
            return
        }

        // In Chapters mode with highlighted phase, only allow taps within the phase
        if currentViewMode == .chapters, let phase = highlightedPhase {
            let birthYear = user.birthYear
            let startWeek = phase.startWeek(birthYear: birthYear)
            let endWeek = min(phase.endWeek(birthYear: birthYear), currentWeekNumber)

            if weekNumber >= startWeek && weekNumber <= endWeek {
                // Tap within highlighted phase - open week detail
                HapticService.shared.medium()
                dismissPhaseHighlight()
                selectedWeekForDetail = WeekIdentifier(value: weekNumber)
            } else {
                // Tap outside phase - dismiss highlight
                dismissPhaseHighlight()
            }
        } else if currentViewMode == .quality {
            // Quality mode: direct tap opens week detail
            HapticService.shared.light()
            selectedWeekForDetail = WeekIdentifier(value: weekNumber)
            // Note: Walkthrough advances in sheet's onDisappear after week is actually rated
        }
    }

    // MARK: - View Mode Footer Content
    // Each view has contextual content in the footer

    @ViewBuilder
    private var viewModeFooterContent: some View {
        switch currentViewMode {
        case .focus:
            // Ghost number - tap to summon
            GhostNumber(weeksRemaining: user.weeksRemaining)

        case .chapters:
            // Phase context bar - shows current/highlighted phase, tappable to edit
            PhaseContextBar(
                user: user,
                phases: phases,
                highlightedPhase: highlightedPhase
            ) {
                // Block during walkthrough unless on addPhase step
                guard walkthrough.allowsAddButton else { return }

                // Tap action: edit current phase or add new
                if let phase = highlightedPhase ?? currentPhaseForUser {
                    phaseToEdit = phase
                } else {
                    showPhaseBuilder = true
                }
            }
            .padding(.horizontal, 16)

        case .quality:
            // "Edit This Week" button
            markCurrentWeekButton

        case .horizons:
            // Milestone context bar - shows next milestone or add prompt
            // PRD: Tap main area → List sheet, tap [+] → Builder
            // During walkthrough, block all interactions (Horizons is last step)
            // BUG-003.5: Includes field guide (ahead/behind counts)
            MilestoneContextBar(
                milestone: nextMilestone,
                totalCount: upcomingMilestoneCount,
                currentWeek: user.currentWeekNumber,
                user: user,
                onTap: walkthrough.isActive ? nil : {
                    // PRD: Context bar tap → List sheet (not Detail)
                    HapticService.shared.light()
                    showMilestoneList = true
                },
                onAddTap: walkthrough.isActive ? nil : {
                    HapticService.shared.light()
                    milestoneToEdit = nil
                    showMilestoneBuilder = true
                },
                milestonesAhead: milestonesAheadOfScroll,
                milestonesBehind: milestonesBehindScroll
            )
            .padding(.horizontal, 24)
        }
    }

    // Next upcoming milestone
    private var nextMilestone: Milestone? {
        milestones.first { $0.targetWeekNumber > user.currentWeekNumber }
    }

    // Count of upcoming milestones (for context bar "X horizons" display)
    private var upcomingMilestoneCount: Int {
        milestones.filter { $0.targetWeekNumber >= user.currentWeekNumber }.count
    }

    // BUG-003.5: Field Guide - milestones ahead/behind based on scroll position
    // "Ahead" = below current scroll position (further in future)
    // "Behind" = above current scroll position (already scrolled past)
    private var milestonesAheadOfScroll: Int {
        // Calculate visible week from scroll offset
        // Using approximate row height calculation
        let rowHeight = (UIScreen.main.bounds.width - 48 - 48) / CGFloat(weeksPerRow) + 1.5
        let visibleRow = max(0, Int(abs(scrollOffset) / rowHeight))
        let visibleWeek = visibleRow * weeksPerRow + 1

        return milestones.filter { $0.targetWeekNumber > visibleWeek + weeksPerRow * 5 }.count
    }

    private var milestonesBehindScroll: Int {
        let rowHeight = (UIScreen.main.bounds.width - 48 - 48) / CGFloat(weeksPerRow) + 1.5
        let visibleRow = max(0, Int(abs(scrollOffset) / rowHeight))
        let visibleWeek = visibleRow * weeksPerRow + 1

        // Behind = milestones we've scrolled past (above visible area)
        // But only count upcoming ones (not completed)
        return milestones.filter {
            $0.targetWeekNumber > user.currentWeekNumber &&
            $0.targetWeekNumber < visibleWeek
        }.count
    }

    // Current phase for the user's current week
    private var currentPhaseForUser: LifePhase? {
        let birthYear = user.birthYear
        let currentWeek = user.currentWeekNumber

        return phases.first { phase in
            let start = phase.startWeek(birthYear: birthYear)
            let end = phase.endWeek(birthYear: birthYear)
            return currentWeek >= start && currentWeek <= end
        }
    }

    // MARK: - Mark Current Week Button

    private var markCurrentWeekButton: some View {
        Button {
            // Block during walkthrough unless on markWeek step
            guard walkthrough.allowsGridTap else { return }

            HapticService.shared.light()
            selectedWeekForDetail = WeekIdentifier(value: currentWeekNumber)
            // Note: Walkthrough advances in sheet's onDisappear after week is actually rated
        } label: {
            HStack(spacing: 8) {
                if isCurrentWeekMarked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.ratingColor(for: ratedWeeksCache[currentWeekNumber] ?? 3))
                    Text("Edit This Week")
                } else {
                    Image(systemName: "plus.circle.fill")
                    Text("Mark This Week")
                }
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.bgSecondary)
            .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Reveal Animation

    private func startRevealAnimation() {
        animationStartTime = Date()

        let totalTicks = 20
        for tick in 1...totalTicks {
            let delay = revealDuration * Double(tick) / Double(totalTicks)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                AudioService.shared.playPencilTick()
            }
        }

        let yearsToReveal = max(1, user.yearsLived)
        for year in 1...yearsToReveal {
            let delay = revealDuration * Double(year) / Double(yearsToReveal)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                HapticService.shared.light()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + revealDuration + 0.1) {
            hasRevealCompleted = true
            HapticService.shared.heavy()
            AudioService.shared.playTap()

            // Start walkthrough if needed (replaces old phase prompt and swipe hint)
            if walkthrough.shouldShow {
                // Ensure we start in Focus view for walkthrough
                currentViewMode = .focus
                user.currentViewMode = .focus
                rebuildGridColorsCache()
                walkthrough.startIfNeeded()
            } else {
                // CRAFT_SPEC: Phase prompt 1s after Reveal completes
                // Only show if user hasn't seen it and has no phases
                if !user.hasSeenPhasePrompt && phases.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.smooth(duration: 0.3)) {
                            showPhasePrompt = true
                        }
                    }
                }

                // CRAFT_SPEC: First-time swipe hint appears once, fades after 3s
                showSwipeHintIfNeeded()
            }
        }
    }

    // MARK: - Swipe Hint

    private func showSwipeHintIfNeeded() {
        // Only show once per user
        guard !user.hasSeenSwipeHint else { return }

        // Small delay after reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showSwipeHint = true
            }

            // Auto-dismiss after 3s
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                dismissSwipeHint()
            }
        }
    }

    private func dismissSwipeHint() {
        guard showSwipeHint else { return }

        withAnimation(.easeOut(duration: 0.3)) {
            showSwipeHint = false
        }
        user.hasSeenSwipeHint = true
    }

    // MARK: - Header

    // Header subtitle - shows view mode subheader to help identify the current view
    @ViewBuilder
    private var headerSubtitle: some View {
        Text(currentViewMode.subheader)
            .font(.caption)
            .foregroundStyle(Color.textSecondary)
    }

    // Get current phase name based on current week
    private var currentPhaseName: String? {
        let birthYear = user.birthYear
        let current = currentWeekNumber

        return phases.first(where: { phase in
            let start = phase.startWeek(birthYear: birthYear)
            let end = phase.endWeek(birthYear: birthYear)
            return current >= start && current <= end
        })?.name
    }

    private var headerView: some View {
        HStack {
            // Settings button
            if hasRevealCompleted {
                Button {
                    HapticService.shared.light()
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.textTertiary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
                .transition(.opacity)
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
            }

            Spacer()

            VStack(spacing: 8) {
                Text("Finite")
                    .font(.system(size: 24, weight: .light))
                    .tracking(2)
                    .foregroundStyle(Color.textPrimary)

                if hasRevealCompleted {
                    headerSubtitle
                        .transition(.opacity)
                }
            }
            .animation(.easeIn(duration: 0.5), value: hasRevealCompleted)
            .animation(.easeOut(duration: 0.2), value: currentViewMode)

            Spacer()

            // View mode toggle button
            if hasRevealCompleted {
                Button {
                    cycleViewMode()
                } label: {
                    Image(systemName: viewModeIcon)
                        .font(.system(size: 20))
                        .foregroundStyle(currentViewMode == .focus ? Color.textTertiary : Color.textPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
                .transition(.opacity)
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - View Mode

    private var viewModeIcon: String {
        switch currentViewMode {
        case .chapters: return "book.pages"
        case .quality: return "paintpalette.fill"
        case .focus: return "circle.grid.3x3"
        case .horizons: return "hexagon.fill"
        }
    }

    private func cycleViewMode() {
        let previousMode = currentViewMode
        currentViewMode = currentViewMode.next

        // Execute signature transition (SST 7.1)
        executeViewModeTransition(from: previousMode, to: currentViewMode)

        user.currentViewMode = currentViewMode
        rebuildGridColorsCache()
        flashModeLabel()
    }

    private func swipeToNextMode() {
        let previousMode = currentViewMode

        // During walkthrough, override normal navigation to follow tutorial order
        if walkthrough.isActive {
            switch walkthrough.currentStep {
            case .swipeToChapters:
                currentViewMode = .chapters
            case .swipeToQuality:
                currentViewMode = .quality
            case .swipeToHorizons:
                currentViewMode = .horizons
            default:
                currentViewMode = currentViewMode.next
            }
        } else {
            currentViewMode = currentViewMode.next
        }

        // Execute signature transition (SST 7.1)
        executeViewModeTransition(from: previousMode, to: currentViewMode)

        user.currentViewMode = currentViewMode
        rebuildGridColorsCache()
        flashModeLabel()
        dismissSwipeHint() // Dismiss hint on first swipe

        // Notify walkthrough of view mode change
        walkthrough.handleViewModeChanged(to: currentViewMode)
    }

    private func swipeToPreviousMode() {
        let previousMode = currentViewMode
        currentViewMode = currentViewMode.previous

        // Execute signature transition (SST 7.1)
        executeViewModeTransition(from: previousMode, to: currentViewMode)

        user.currentViewMode = currentViewMode
        rebuildGridColorsCache()
        flashModeLabel()
        dismissSwipeHint() // Dismiss hint on first swipe

        // Notify walkthrough of view mode change
        walkthrough.handleViewModeChanged(to: currentViewMode)
    }

    /// Execute signature view mode transition with choreographed animations
    private func executeViewModeTransition(from: ViewMode, to: ViewMode) {
        transitionManager.transition(
            from: from,
            to: to,
            currentWeek: currentWeekNumber
        ) {
            // Transition complete - any cleanup can go here
        }
    }

    // CRAFT_SPEC: Mode label flash - fade in 0.1s, hold 0.5s, fade out 0.2s (total 0.8s)
    private func flashModeLabel() {
        withAnimation(.easeOut(duration: 0.1)) {
            showModeLabel = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.2)) {
                showModeLabel = false
            }
        }
    }

    // MARK: - Spine Tap Handling
    // Spine tap triggers: (1) grid dim overlay, (2) GhostPhase summon at footer
    // GhostPhase handles its own fade timing, so we just need to manage the grid dim

    private func handleSpineTap(phase: LifePhase, yPosition: CGFloat) {
        // Cancel any existing dismiss task
        phaseHighlightDismissTask?.cancel()

        // Set highlighted phase - this triggers:
        // 1. Grid dim overlay (via phaseHighlightDimOverlay)
        // 2. GhostPhase summon (bound to highlightedPhase)
        withAnimation(.easeOut(duration: 0.2)) {
            highlightedPhase = phase
        }

        // Rebuild grid with dimmed colors
        rebuildGridColorsCache()

        // Grid dim dismisses after 3s or when GhostPhase sets highlightedPhase to nil
        phaseHighlightDismissTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)

            guard !Task.isCancelled else { return }

            await MainActor.run {
                dismissPhaseHighlight()
            }
        }
    }

    private func dismissPhaseHighlight() {
        guard highlightedPhase != nil else { return }

        withAnimation(.easeOut(duration: 0.2)) {
            highlightedPhase = nil
        }
        rebuildGridColorsCache()
    }

    // MARK: - Breathing Aura Color
    // Updates based on the phase containing the current week

    private func updateAuraColor() {
        let birthYear = user.birthYear
        let current = currentWeekNumber

        // Find phase containing current week
        if let phase = phases.first(where: { phase in
            let start = phase.startWeek(birthYear: birthYear)
            let end = phase.endWeek(birthYear: birthYear)
            return current >= start && current <= end
        }) {
            currentAuraColor = Color.fromHex(phase.colorHex)
        } else {
            // No phase at current week - use subtle default
            currentAuraColor = Color.gridFilled.opacity(0.5)
        }
    }

    // MARK: - Week Confirm Bloom Animation
    // CRAFT_SPEC: Week cell mark - 0.25s duration, 0.15 bounce, .snappy

    private func triggerBloomAnimation(for weekNumber: Int) {
        guard !isBloomAnimating else { return }

        bloomWeekNumber = weekNumber
        bloomProgress = 0.0
        isBloomAnimating = true

        // CRAFT_SPEC: Color bloom on confirm - snappy with bounce
        withAnimation(.snappy(duration: 0.25, extraBounce: 0.15)) {
            bloomProgress = 1.0
        }

        // Clean up after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            bloomWeekNumber = nil
            bloomProgress = 0.0
            isBloomAnimating = false
        }
    }

    // MARK: - Animated Grid

    private func animatedGridContent(cellSize: CGFloat, spacing: CGFloat, gridWidth: CGFloat, gridHeight: CGFloat) -> some View {
        TimelineView(.animation) { timeline in
            let elapsed = animationStartTime.map { timeline.date.timeIntervalSince($0) } ?? 0
            let progress = min(1.0, elapsed / revealDuration)
            let easedProgress = 1 - pow(1 - progress, 2)
            let revealedCount = Int(Double(weeksLived) * easedProgress)

            Canvas { context, _ in
                for weekNumber in 1...totalWeeks {
                    let row = (weekNumber - 1) / weeksPerRow
                    let col = (weekNumber - 1) % weeksPerRow
                    let x = CGFloat(col) * (cellSize + spacing)
                    let y = CGFloat(row) * (cellSize + spacing)
                    let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                    let circle = Path(ellipseIn: rect)

                    let isLived = weekNumber <= weeksLived
                    let isRevealed = weekNumber <= revealedCount

                    let color: Color = (isLived && isRevealed) ? .gridFilled : .gridUnfilled
                    context.fill(circle, with: .color(color))
                }
            }
            .frame(width: gridWidth, height: gridHeight)
        }
    }

    // MARK: - Footer (Removed)
    // Generic lived/remaining footer removed - each view mode has its own footer:
    // - Chapters: PhaseContextBar
    // - Quality: "Edit This Week" button (header shows countdown)
    // - Focus: Ghost number

    // MARK: - Hexagon Path Helper

    /// Creates a hexagon path that fits within the given rect
    private func hexagonPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for i in 0..<6 {
            // Start from top vertex (rotate by -90 degrees / -π/2)
            let angle = CGFloat(i) * .pi / 3 - .pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }

    // MARK: - Checkmark Path Helper

    /// Creates a checkmark path that fits within the given rect (for completed milestones)
    private func checkmarkPath(in rect: CGRect) -> Path {
        var path = Path()
        let inset = rect.width * 0.15
        let insetRect = rect.insetBy(dx: inset, dy: inset)

        // Simple checkmark: starts at left-middle, goes down to bottom-middle, then up to top-right
        let startPoint = CGPoint(x: insetRect.minX, y: insetRect.midY)
        let middlePoint = CGPoint(x: insetRect.minX + insetRect.width * 0.35, y: insetRect.maxY - inset)
        let endPoint = CGPoint(x: insetRect.maxX, y: insetRect.minY + inset)

        // Draw thick checkmark by creating a path with width
        let lineWidth = rect.width * 0.2

        path.move(to: startPoint)
        path.addLine(to: middlePoint)
        path.addLine(to: endPoint)

        // Create stroked version with round caps
        return path.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview("Grid - No Reveal") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Week.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    return GridView(user: user, shouldReveal: false)
        .modelContainer(container)
}

#Preview("Grid - With Reveal") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Week.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date())!)
    container.mainContext.insert(user)

    return GridView(user: user, shouldReveal: true)
        .modelContainer(container)
}
