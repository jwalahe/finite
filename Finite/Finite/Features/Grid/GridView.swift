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

    @State private var animationStartTime: Date?
    @State private var hasRevealCompleted: Bool = false

    // Week selection state
    @State private var selectedWeekForDetail: WeekIdentifier?

    // OPTIMIZATION: Cache ratedWeeks to avoid rebuilding on every frame
    @State private var ratedWeeksCache: [Int: Int] = [:]

    // OPTIMIZATION: Cache phase colors for week numbers
    @State private var phaseColorsCache: [Int: String] = [:]

    // OPTIMIZATION: Pre-computed grid colors array for instant mode switching
    // Index = weekNumber - 1, stores resolved Color for each week
    @State private var gridColorsCache: [Color] = []

    // View mode state (Chapters/Quality/Focus)
    @State private var currentViewMode: ViewMode = .focus

    // Week confirm bloom animation
    @State private var bloomWeekNumber: Int?
    @State private var bloomProgress: CGFloat = 0.0
    @State private var isBloomAnimating: Bool = false

    // Settings sheet
    @State private var showSettings: Bool = false

    // Phase prompt and builder
    @State private var showPhasePrompt: Bool = false
    @State private var showPhaseBuilder: Bool = false

    // Mode label flash
    @State private var showModeLabel: Bool = false

    // First-time swipe hint
    @State private var showSwipeHint: Bool = false

    // Breathing Aura - current phase color based on scroll position
    @State private var currentAuraColor: Color = .clear

    // Phase highlight state - dims non-phase weeks and summons GhostPhase
    @State private var highlightedPhase: LifePhase?
    @State private var phaseHighlightDismissTask: Task<Void, Never>?

    // Magnification loupe state (Quality view long-press)
    @StateObject private var loupeState = LoupeState()

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
    }

    // Rebuild phase colors cache from phases data
    // Only includes weeks up to current week (phases don't color the future)
    private func rebuildPhaseColorsCache() {
        var cache: [Int: String] = [:]
        let birthYear = user.birthYear
        let currentWeek = currentWeekNumber

        for phase in phases {
            let startWeek = phase.startWeek(birthYear: birthYear)
            // Cap end week at current week - phases only color lived weeks
            let endWeek = min(phase.endWeek(birthYear: birthYear), currentWeek)

            guard startWeek <= endWeek else { continue }

            for weekNum in startWeek...endWeek {
                cache[weekNum] = phase.colorHex
            }
        }

        phaseColorsCache = cache
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
                    }
                    .padding(.top, 12)
                    .padding(.bottom, footerZoneHeight)  // Prevent grid hiding behind footer
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
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(user: user)
        }
        .sheet(isPresented: $showPhaseBuilder) {
            PhaseFlowCoordinator(user: user, isPresented: $showPhaseBuilder)
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
            // Time Spine (Chapters view only) - CRAFT_SPEC: 12pt visual, 44pt tap target
            if currentViewMode == .chapters && hasRevealCompleted && !phases.isEmpty {
                TimeSpine(user: user, phases: phases, gridHeight: gridHeight) { phase, yPos in
                    handleSpineTap(phase: phase, yPosition: yPos)
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
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        // CRAFT_SPEC: Swipe left/right to change view modes
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height

                        // Only trigger if horizontal swipe is dominant
                        guard abs(horizontalAmount) > abs(verticalAmount) else { return }

                        if horizontalAmount < -50 {
                            // Swipe left → next mode
                            swipeToNextMode()
                        } else if horizontalAmount > 50 {
                            // Swipe right → previous mode
                            swipeToPreviousMode()
                        }
                    }
            )

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
                    let circle = Path(ellipseIn: rect)

                    context.fill(circle, with: .color(colors[index]))
                }
            }
            .frame(width: gridWidth, height: gridHeight)
            .drawingGroup()

            // Current week pulse ring (more visible)
            currentWeekPulseRing(cellSize: cellSize, spacing: spacing)

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
            if currentViewMode == .quality || highlightedPhase != nil {
                weekTapTarget(cellSize: cellSize, spacing: spacing)
            } else if currentViewMode == .chapters && highlightedPhase == nil {
                // Only current week tap in Chapters when no phase highlighted
                currentWeekTapTarget(cellSize: cellSize, spacing: spacing)
            }

            // Magnification loupe overlay (Quality view long-press)
            if loupeState.isActive && currentViewMode == .quality {
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
                    totalWeeks: totalWeeks
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

        return TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let phase = (sin(elapsed * .pi * 0.8) + 1) / 2
            let ringScale = 1.8 + (0.6 * phase)
            let ringOpacity = 0.6 - (0.4 * phase)

            Circle()
                .stroke(Color.weekCurrent.opacity(ringOpacity), lineWidth: 2)
                .frame(width: cellSize * ringScale, height: cellSize * ringScale)
                .position(x: x, y: y)
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
                HapticService.shared.light()
                selectedWeekForDetail = WeekIdentifier(value: currentWeekNumber)
            }
            .offset(x: x - (tapSize - cellSize) / 2, y: y - (tapSize - cellSize) / 2)
    }

    // MARK: - Week Tap Target (Full Grid)
    // For Quality mode: direct tap on any lived week, long-press for loupe
    // For Chapters mode with highlighted phase: tap to select week within phase

    private func weekTapTarget(cellSize: CGFloat, spacing: CGFloat) -> some View {
        GeometryReader { _ in
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    currentViewMode == .quality
                        ? qualityModeGesture(cellSize: cellSize, spacing: spacing)
                        : nil
                )
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            // This won't work for location - need to use the drag gesture for positioning
                        }
                )
                .onTapGesture { location in
                    if !loupeState.isActive {
                        handleWeekTap(at: location, cellSize: cellSize, spacing: spacing)
                    }
                }
        }
    }

    // Quality mode gesture: long-press activates loupe, drag moves it
    private func qualityModeGesture(cellSize: CGFloat, spacing: CGFloat) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                switch value {
                case .first(true):
                    // Long press recognized but drag hasn't started
                    break
                case .second(true, let drag):
                    if let dragValue = drag {
                        if !loupeState.isActive {
                            // Activate loupe
                            withAnimation(.snappy(duration: 0.15, extraBounce: 0.1)) {
                                loupeState.isActive = true
                                loupeState.position = dragValue.location
                            }
                            HapticService.shared.light()
                        }
                        // Update loupe position
                        loupeState.updatePosition(
                            dragValue.location,
                            cellSize: cellSize,
                            spacing: spacing,
                            weeksPerRow: weeksPerRow,
                            weeksLived: weeksLived
                        )
                    }
                default:
                    break
                }
            }
            .onEnded { value in
                if case .second(true, _) = value {
                    // End loupe and select week
                    if let selectedWeek = loupeState.endLongPress() {
                        selectedWeekForDetail = WeekIdentifier(value: selectedWeek)
                    }
                }
            }
    }

    private func handleWeekTap(at location: CGPoint, cellSize: CGFloat, spacing: CGFloat) {
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
        }
    }

    // MARK: - View Mode Footer Content
    // Each view has a "ghost" element at 8% opacity that summons on interaction
    // Philosophy: Information appears only when sought, then gracefully recedes

    @ViewBuilder
    private var viewModeFooterContent: some View {
        switch currentViewMode {
        case .focus:
            // Ghost number - tap to summon
            GhostNumber(weeksRemaining: user.weeksRemaining)

        case .chapters:
            // Ghost phase - summoned when spine is tapped
            GhostPhase(user: user, phases: phases, summonedPhase: $highlightedPhase)

        case .quality:
            // "Edit This Week" button
            markCurrentWeekButton
        }
    }

    // MARK: - Mark Current Week Button

    private var markCurrentWeekButton: some View {
        Button {
            HapticService.shared.light()
            selectedWeekForDetail = WeekIdentifier(value: currentWeekNumber)
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
        }
    }

    private func cycleViewMode() {
        HapticService.shared.light()
        currentViewMode = currentViewMode.next
        user.currentViewMode = currentViewMode
        rebuildGridColorsCache()
        flashModeLabel()
    }

    private func swipeToNextMode() {
        HapticService.shared.light()
        currentViewMode = currentViewMode.next
        user.currentViewMode = currentViewMode
        rebuildGridColorsCache()
        flashModeLabel()
        dismissSwipeHint() // Dismiss hint on first swipe
    }

    private func swipeToPreviousMode() {
        HapticService.shared.light()
        currentViewMode = currentViewMode.previous
        user.currentViewMode = currentViewMode
        rebuildGridColorsCache()
        flashModeLabel()
        dismissSwipeHint() // Dismiss hint on first swipe
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
