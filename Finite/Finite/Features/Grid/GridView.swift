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

    // Scrubber state - isolated to prevent cascade
    @State private var isScrubbing: Bool = false

    // View mode state (Chapters/Quality/Focus)
    @State private var currentViewMode: ViewMode = .quality

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

            VStack(spacing: 0) {
                // Scrollable content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerView
                            .padding(.bottom, 24)

                        // Grid with age labels
                        gridWithLabels(
                            cellSize: cellSize,
                            spacing: spacing,
                            gridWidth: gridWidth,
                            gridHeight: gridHeight
                        )

                        // "Mark This Week" button
                        if hasRevealCompleted && !isScrubbing {
                            markCurrentWeekButton
                                .padding(.top, 24)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }

                        footerView
                            .padding(.top, 32)
                            .padding(.bottom, 24)
                    }
                    .padding(.top, 24)
                }

                // Mode label flash + Dot indicator
                if hasRevealCompleted {
                    VStack(spacing: 8) {
                        // Mode label (flashes on change)
                        if showModeLabel {
                            Text(currentViewMode.displayName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.bgPrimary.opacity(0.8))
                                .cornerRadius(6)
                                .transition(.opacity)
                        }

                        DotIndicator(currentMode: currentViewMode)
                    }
                    .padding(.top, 12)
                    .transition(.opacity)
                }

                // Timeline Scrubber - Fixed at bottom, outside ScrollView
                // OPTIMIZATION: Isolated view to prevent state changes from invalidating grid
                if hasRevealCompleted {
                    TimelineScrubber(
                        weeksLived: weeksLived,
                        totalWeeks: totalWeeks,
                        currentWeekNumber: currentWeekNumber,
                        lifeExpectancy: user.lifeExpectancy,
                        ratedWeeks: ratedWeeksCache,
                        screenWidth: geometry.size.width,
                        onWeekSelected: { weekNum in
                            selectedWeekForDetail = WeekIdentifier(value: weekNum)
                        },
                        onScrubbingChanged: { scrubbing in
                            isScrubbing = scrubbing
                        }
                    )
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 16)
                }
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
        }
        .onChange(of: weeks.count) { _, _ in
            // Rebuild cache when weeks change (new week marked)
            rebuildRatedWeeksCache()
            rebuildGridColorsCache()
        }
        .onChange(of: phases.count) { _, _ in
            // Rebuild phase cache when phases change
            rebuildPhaseColorsCache()
            rebuildGridColorsCache()
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
            // Left age labels
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

            // Tap gesture for current week quick access
            currentWeekTapTarget(cellSize: cellSize, spacing: spacing)
        }
        .frame(width: gridWidth, height: gridHeight)
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

        return Group {
            if isScrubbing {
                // Static ring during scrub - no TimelineView overhead
                Circle()
                    .stroke(Color.weekCurrent.opacity(0.4), lineWidth: 2)
                    .frame(width: cellSize * 2.0, height: cellSize * 2.0)
                    .position(x: x, y: y)
            } else {
                // Animated pulse when not scrubbing
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
                HapticService.shared.light()
                selectedWeekForDetail = WeekIdentifier(value: currentWeekNumber)
            }
            .offset(x: x - (tapSize - cellSize) / 2, y: y - (tapSize - cellSize) / 2)
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
        }
    }

    // MARK: - Header

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
                    Text("\(user.weeksRemaining.formatted()) weeks remaining")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                        .transition(.opacity)
                }
            }
            .animation(.easeIn(duration: 0.5), value: hasRevealCompleted)

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
    }

    private func swipeToPreviousMode() {
        HapticService.shared.light()
        currentViewMode = currentViewMode.previous
        user.currentViewMode = currentViewMode
        rebuildGridColorsCache()
        flashModeLabel()
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

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 32) {
            VStack(spacing: 4) {
                Text("\(user.weeksLived.formatted())")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                Text("lived")
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary)
            }

            VStack(spacing: 4) {
                Text("\(user.weeksRemaining.formatted())")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                Text("remaining")
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .opacity(hasRevealCompleted ? 1 : 0)
        .animation(.easeIn(duration: 0.5).delay(0.3), value: hasRevealCompleted)
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

// MARK: - Isolated Timeline Scrubber
// This is a separate struct to isolate its state from GridView
// Scrubber position/highlight changes won't trigger GridView body recomputation

struct TimelineScrubber: View {
    let weeksLived: Int
    let totalWeeks: Int
    let currentWeekNumber: Int
    let lifeExpectancy: Int
    let ratedWeeks: [Int: Int]
    let screenWidth: CGFloat
    let onWeekSelected: (Int) -> Void
    let onScrubbingChanged: (Bool) -> Void

    // All scrubber state is LOCAL to this view
    @State private var scrubberPosition: CGFloat = 0.0
    @State private var isScrubbing: Bool = false
    @State private var highlightedWeekNumber: Int?
    @State private var isInitialized: Bool = false

    private let weeksPerRow: Int = 52
    private let scrubberPadding: CGFloat = 24
    private let thumbSize: CGFloat = 28
    private let trackHeight: CGFloat = 6

    private var scrubberWidth: CGFloat {
        screenWidth - (scrubberPadding * 2)
    }

    private var livedPosition: CGFloat {
        CGFloat(weeksLived) / CGFloat(totalWeeks)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Week info card (shows when scrubbing)
            if isScrubbing, let weekNum = highlightedWeekNumber {
                scrubberInfoCard(weekNumber: weekNum)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // Scrubber track
            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.bgTertiary)
                        .frame(height: trackHeight)

                    // Filled portion (lived weeks)
                    Capsule()
                        .fill(Color.gridFilled)
                        .frame(width: scrubberWidth * livedPosition, height: trackHeight)

                    // Thumb
                    Circle()
                        .fill(Color.bgPrimary)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        .overlay(
                            Circle()
                                .fill(isScrubbing ? Color.weekCurrent : Color.gridFilled)
                                .frame(width: thumbSize - 8, height: thumbSize - 8)
                        )
                        .offset(x: (scrubberWidth - thumbSize) * scrubberPosition)
                }
                .frame(width: scrubberWidth, height: thumbSize)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isScrubbing {
                                isScrubbing = true
                                onScrubbingChanged(true)
                                HapticService.shared.medium()
                            }

                            // Calculate position (0 to livedPosition only)
                            let newPosition = max(0, min(livedPosition, value.location.x / scrubberWidth))
                            scrubberPosition = newPosition

                            // Calculate highlighted week
                            let weekNum = max(1, min(weeksLived, Int(ceil(newPosition / livedPosition * CGFloat(weeksLived)))))
                            if weekNum != highlightedWeekNumber {
                                highlightedWeekNumber = weekNum
                                HapticService.shared.selection()
                            }
                        }
                        .onEnded { _ in
                            if let weekNum = highlightedWeekNumber {
                                HapticService.shared.medium()
                                onWeekSelected(weekNum)
                            }
                            isScrubbing = false
                            onScrubbingChanged(false)
                            highlightedWeekNumber = nil
                            // Reset to current position
                            scrubberPosition = livedPosition
                        }
                )

                // Minimal endpoint labels only
                HStack {
                    Text("0")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textTertiary)
                    Spacer()
                    Text("\(lifeExpectancy)")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textTertiary)
                }
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, scrubberPadding)
        }
        .padding(.top, 8)
        .background(Color.bgPrimary)
        .onAppear {
            if !isInitialized {
                scrubberPosition = livedPosition
                isInitialized = true
            }
        }
        .animation(.easeOut(duration: 0.12), value: isScrubbing)
    }

    // MARK: - Info Card

    private func scrubberInfoCard(weekNumber: Int) -> some View {
        let year = (weekNumber - 1) / weeksPerRow
        let weekOfYear = (weekNumber - 1) % weeksPerRow + 1
        let rating = ratedWeeks[weekNumber]
        let isCurrentWeek = weekNumber == currentWeekNumber

        return HStack(spacing: 12) {
            // Week indicator
            ZStack {
                if let rating = rating {
                    Circle()
                        .fill(Color.ratingColor(for: rating))
                        .frame(width: 36, height: 36)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .stroke(isCurrentWeek ? Color.weekCurrent : Color.textTertiary, lineWidth: 2)
                        .frame(width: 36, height: 36)
                    if isCurrentWeek {
                        Circle()
                            .fill(Color.weekCurrent)
                            .frame(width: 12, height: 12)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Week \(weekNumber.formatted())")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)

                    if isCurrentWeek {
                        Text("NOW")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.weekCurrent)
                            .clipShape(Capsule())
                    }
                }

                Text("Age \(year) • Week \(weekOfYear)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgSecondary)
        )
        .padding(.horizontal, 24)
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
