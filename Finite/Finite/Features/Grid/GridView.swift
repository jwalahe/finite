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

// Pre-computed data for exploring a week (avoids calculations during drag)
struct ExploringWeekData: Equatable {
    let weekNumber: Int
    let year: Int
    let weekOfYear: Int
    let dateRange: String
    let rating: Int?
    let isCurrentWeek: Bool
}

struct GridView: View {
    let user: User
    let shouldReveal: Bool

    @Environment(\.modelContext) private var modelContext
    @Query private var weeks: [Week]

    @State private var animationStartTime: Date?
    @State private var hasRevealCompleted: Bool = false
    @State private var showPulse: Bool = false

    // Week selection state
    @State private var selectedWeekForDetail: WeekIdentifier?

    // Touch-the-time gesture state
    @State private var isExploring: Bool = false
    @State private var exploringWeekNumber: Int?
    @State private var exploringYear: Int?

    // Pre-computed week data for performance (avoids repeated lookups during drag)
    @State private var exploringWeekData: ExploringWeekData?

    private let weeksPerRow: Int = 52
    private let revealDuration: Double = 2.0
    private let screenMargin: CGFloat = 16
    private let ageLabelWidth: CGFloat = 28

    init(user: User, shouldReveal: Bool = false) {
        self.user = user
        self.shouldReveal = shouldReveal
    }

    // Get week data by week number
    private func weekData(for weekNumber: Int) -> Week? {
        weeks.first { $0.weekNumber == weekNumber }
    }

    private var totalWeeks: Int { user.totalWeeks }
    private var weeksLived: Int { user.weeksLived }
    private var currentWeekNumber: Int { user.currentWeekNumber }

    // Check if current week is already marked
    private var isCurrentWeekMarked: Bool {
        weekData(for: currentWeekNumber)?.rating != nil
    }

    // Dynamic cell sizing based on available width
    private func calculateGridMetrics(for screenWidth: CGFloat) -> (cellSize: CGFloat, spacing: CGFloat, gridWidth: CGFloat) {
        // Available width = screen - margins - age labels on both sides (for centering)
        let availableWidth = screenWidth - (screenMargin * 2) - (ageLabelWidth * 2)
        // 52 cells + 51 gaps, with spacing = cellSize * 0.25
        // Total = 52c + 51 * 0.25c = 64.75c
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

            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerView
                            .padding(.bottom, 24)

                        // Grid with age labels - centered
                        gridWithLabels(
                            cellSize: cellSize,
                            spacing: spacing,
                            gridWidth: gridWidth,
                            gridHeight: gridHeight
                        )

                        // "Mark This Week" button
                        if hasRevealCompleted && !isExploring {
                            markCurrentWeekButton
                                .padding(.top, 24)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }

                        footerView
                            .padding(.top, 32)
                            .padding(.bottom, 48)
                    }
                    .padding(.top, 24)
                }

                // Floating week indicator - uses pre-computed data for performance
                if isExploring, let data = exploringWeekData {
                    weekIndicatorCard(data: data)
                }
            }
        }
        .background(Color.bgPrimary)
        .onAppear {
            if shouldReveal {
                startRevealAnimation()
            } else {
                hasRevealCompleted = true
                showPulse = true
            }
        }
        .sheet(item: $selectedWeekForDetail) { weekNumber in
            WeekDetailSheet(
                user: user,
                weekNumber: weekNumber.value,
                existingWeek: weekData(for: weekNumber.value)
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .animation(.easeOut(duration: 0.2), value: isExploring)
    }

    // MARK: - Grid with Age Labels

    private func gridWithLabels(
        cellSize: CGFloat,
        spacing: CGFloat,
        gridWidth: CGFloat,
        gridHeight: CGFloat
    ) -> some View {
        let rowHeight = cellSize + spacing

        // Determine which ages to show labels for
        // Show: 0, decade marks (10, 20, 30...), and current age
        // But skip current age if it's within 2 years of a decade mark (to avoid visual crowding)
        let currentAge = user.yearsLived
        let nearestDecade = ((currentAge + 5) / 10) * 10  // Round to nearest decade
        let distanceToDecade = abs(currentAge - nearestDecade)
        let showCurrentAge = distanceToDecade > 2  // Only show if more than 2 years from decade

        return HStack(alignment: .top, spacing: 0) {
            // Left age labels
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(0..<user.lifeExpectancy, id: \.self) { year in
                    let age = year
                    let isDecadeMark = age == 0 || age % 10 == 0
                    let isCurrentAge = year == currentAge && showCurrentAge
                    let showLabel = isDecadeMark || isCurrentAge

                    Text(showLabel ? "\(age)" : "")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(year == currentAge ? Color.textPrimary : Color.textTertiary)
                        .frame(width: ageLabelWidth, height: rowHeight, alignment: .trailing)
                }
            }
            .padding(.trailing, 6)

            // Grid
            ZStack(alignment: .topLeading) {
                // Main grid content
                if shouldReveal && !hasRevealCompleted {
                    animatedGridContent(cellSize: cellSize, spacing: spacing)
                } else {
                    interactiveGridContent(
                        cellSize: cellSize,
                        spacing: spacing,
                        gridWidth: gridWidth,
                        gridHeight: gridHeight
                    )
                }

                // Year highlight when exploring
                if isExploring, let year = exploringYear {
                    yearHighlight(year: year, cellSize: cellSize, spacing: spacing, gridWidth: gridWidth)
                }
            }
            .frame(width: gridWidth, height: gridHeight)

            // Right age labels (for symmetry/centering)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<user.lifeExpectancy, id: \.self) { year in
                    let age = year
                    let isDecadeMark = age == 0 || age % 10 == 0
                    let isCurrentAge = year == currentAge && showCurrentAge
                    let showLabel = isDecadeMark || isCurrentAge

                    Text(showLabel ? "\(age)" : "")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(year == currentAge ? Color.textPrimary : Color.textTertiary)
                        .frame(width: ageLabelWidth, height: rowHeight, alignment: .leading)
                }
            }
            .padding(.leading, 6)
        }
        .padding(.horizontal, screenMargin)
    }

    // MARK: - Year Highlight

    private func yearHighlight(year: Int, cellSize: CGFloat, spacing: CGFloat, gridWidth: CGFloat) -> some View {
        let rowHeight = cellSize + spacing
        let y = CGFloat(year) * rowHeight

        return RoundedRectangle(cornerRadius: 4)
            .fill(Color.weekCurrent.opacity(0.1))
            .frame(width: gridWidth + 8, height: rowHeight + 4)
            .offset(x: -4, y: y - 2)
            .allowsHitTesting(false)
    }

    // MARK: - Interactive Grid Content
    //
    // PERFORMANCE: The grid Canvas is static and only redraws when `weeks` data changes.
    // Exploration dimming is handled via an overlay layer, NOT inside the Canvas.
    // This prevents 4160 circles from being redrawn every gesture frame.

    private func interactiveGridContent(
        cellSize: CGFloat,
        spacing: CGFloat,
        gridWidth: CGFloat,
        gridHeight: CGFloat
    ) -> some View {
        let ratedWeeks = Dictionary(uniqueKeysWithValues: weeks.compactMap { week -> (Int, Int)? in
            guard let rating = week.rating else { return nil }
            return (week.weekNumber, rating)
        })

        return ZStack(alignment: .topLeading) {
            // Static grid canvas - only redraws when weeks data changes
            staticGridCanvas(
                cellSize: cellSize,
                spacing: spacing,
                gridWidth: gridWidth,
                gridHeight: gridHeight,
                ratedWeeks: ratedWeeks
            )

            // Exploration dimming overlay - lightweight, only draws dim rectangles
            if isExploring, let highlightYear = exploringYear {
                explorationDimmingOverlay(
                    highlightYear: highlightYear,
                    cellSize: cellSize,
                    spacing: spacing,
                    gridWidth: gridWidth,
                    gridHeight: gridHeight
                )
            }

            // Current week pulse (tappable)
            if showPulse && !isExploring {
                currentWeekPulse(cellSize: cellSize, spacing: spacing)
            }

            // Gesture layer
            gestureLayer(cellSize: cellSize, spacing: spacing, gridWidth: gridWidth, gridHeight: gridHeight)
        }
        .frame(width: gridWidth, height: gridHeight)
    }

    // MARK: - Static Grid Canvas (Performance Optimized)

    private func staticGridCanvas(
        cellSize: CGFloat,
        spacing: CGFloat,
        gridWidth: CGFloat,
        gridHeight: CGFloat,
        ratedWeeks: [Int: Int]
    ) -> some View {
        Canvas { context, _ in
            for weekNumber in 1...totalWeeks {
                let row = (weekNumber - 1) / weeksPerRow
                let col = (weekNumber - 1) % weeksPerRow
                let x = CGFloat(col) * (cellSize + spacing)
                let y = CGFloat(row) * (cellSize + spacing)
                let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                let circle = Path(ellipseIn: rect)

                let isLived = weekNumber <= weeksLived
                let isCurrent = weekNumber == currentWeekNumber

                // Skip current week - it has its own pulsing view
                if isCurrent && showPulse {
                    continue
                }

                let color: Color
                if let rating = ratedWeeks[weekNumber] {
                    color = Color.ratingColor(for: rating)
                } else if isLived {
                    color = .gridFilled
                } else {
                    color = .gridUnfilled
                }

                context.fill(circle, with: .color(color))
            }
        }
        .frame(width: gridWidth, height: gridHeight)
        .drawingGroup() // Rasterize for better performance
    }

    // MARK: - Exploration Dimming Overlay (Lightweight)
    //
    // Uses a simple opacity mask approach instead of drawing 80 rectangles.
    // Only redraws when highlightYear changes (once per year crossing, not 60fps).

    private func explorationDimmingOverlay(
        highlightYear: Int,
        cellSize: CGFloat,
        spacing: CGFloat,
        gridWidth: CGFloat,
        gridHeight: CGFloat
    ) -> some View {
        let rowHeight = cellSize + spacing
        let highlightY = CGFloat(highlightYear) * rowHeight

        return ZStack(alignment: .topLeading) {
            // Top dim region (above highlighted year)
            if highlightYear > 0 {
                Color.bgPrimary.opacity(0.7)
                    .frame(width: gridWidth, height: highlightY)
            }

            // Bottom dim region (below highlighted year)
            let bottomY = highlightY + rowHeight
            let bottomHeight = gridHeight - bottomY
            if bottomHeight > 0 {
                Color.bgPrimary.opacity(0.7)
                    .frame(width: gridWidth, height: bottomHeight)
                    .offset(y: bottomY)
            }
        }
        .frame(width: gridWidth, height: gridHeight, alignment: .topLeading)
        .allowsHitTesting(false)
    }

    // MARK: - Current Week Pulse (Tappable)

    private func currentWeekPulse(cellSize: CGFloat, spacing: CGFloat) -> some View {
        let row = (currentWeekNumber - 1) / weeksPerRow
        let col = (currentWeekNumber - 1) % weeksPerRow
        let x = CGFloat(col) * (cellSize + spacing)
        let y = CGFloat(row) * (cellSize + spacing)

        return Button {
            HapticService.shared.light()
            selectedWeekForDetail = WeekIdentifier(value: currentWeekNumber)
        } label: {
            PulsingDot(cellSize: cellSize)
        }
        .buttonStyle(.plain)
        .offset(x: x, y: y)
    }

    // MARK: - Gesture Layer
    //
    // NOTE: We use simultaneousGesture with a DragGesture that has minimumDistance: 0
    // instead of LongPressGesture.sequenced(before: DragGesture) because:
    // 1. ScrollView intercepts and delays touch delivery for gesture disambiguation
    // 2. LongPressGesture requires finger to stay still, which ScrollView interferes with
    // 3. By tracking touch duration ourselves, we bypass ScrollView's gesture priority

    private func gestureLayer(
        cellSize: CGFloat,
        spacing: CGFloat,
        gridWidth: CGFloat,
        gridHeight: CGFloat
    ) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        // Calculate how long we've been holding
                        let holdDuration = Date().timeIntervalSince(value.time)

                        // Only activate after 0.15 second hold
                        if holdDuration >= 0.15 || isExploring {
                            handleExploreGesture(
                                at: value.location,
                                cellSize: cellSize,
                                spacing: spacing
                            )
                        }
                    }
                    .onEnded { _ in
                        if isExploring {
                            handleExploreEnd()
                        }
                    }
            )
            .frame(width: gridWidth, height: gridHeight)
    }

    // MARK: - Explore Gesture Handling

    private func handleExploreGesture(at location: CGPoint, cellSize: CGFloat, spacing: CGFloat) {
        let cellWithSpacing = cellSize + spacing
        let col = Int(location.x / cellWithSpacing)
        let row = Int(location.y / cellWithSpacing)

        // Clamp to valid range
        let clampedRow = max(0, min(row, user.lifeExpectancy - 1))
        let clampedCol = max(0, min(col, weeksPerRow - 1))

        let weekNumber = clampedRow * weeksPerRow + clampedCol + 1
        let isValid = weekNumber >= 1 && weekNumber <= weeksLived
        let newWeekNumber = isValid ? weekNumber : nil

        // Start exploring if not already
        if !isExploring {
            isExploring = true
            HapticService.shared.medium()
        }

        // Only update state if year changed (reduces redraws)
        let yearChanged = exploringYear != clampedRow

        if yearChanged {
            exploringYear = clampedRow
            // Haptic only on year boundary crossing - much less frequent
            HapticService.shared.selection()
        }

        // Only recompute week data when the week actually changes
        // This is the KEY optimization - we only do expensive work when needed
        if exploringWeekNumber != newWeekNumber {
            exploringWeekNumber = newWeekNumber

            if let week = newWeekNumber {
                // Pre-compute ALL data needed for the indicator card
                // This runs once per week change, not 60fps
                exploringWeekData = ExploringWeekData(
                    weekNumber: week,
                    year: (week - 1) / weeksPerRow,
                    weekOfYear: (week - 1) % weeksPerRow + 1,
                    dateRange: weekDateRange(for: week),
                    rating: weekData(for: week)?.rating,
                    isCurrentWeek: week == currentWeekNumber
                )
            } else {
                exploringWeekData = nil
            }
        }
    }

    private func handleExploreEnd() {
        if let weekNumber = exploringWeekNumber {
            HapticService.shared.medium()
            selectedWeekForDetail = WeekIdentifier(value: weekNumber)
        }
        cancelExplore()
    }

    private func cancelExplore() {
        isExploring = false
        exploringWeekNumber = nil
        exploringYear = nil
        exploringWeekData = nil
    }

    // MARK: - Week Indicator Card (Performance Optimized)
    //
    // This card uses PRE-COMPUTED data from ExploringWeekData.
    // All expensive operations (date formatting, week lookups) happen once
    // when the week changes, NOT on every frame during drag.

    private func weekIndicatorCard(data: ExploringWeekData) -> some View {
        VStack(spacing: 6) {
            // Week number
            HStack(spacing: 8) {
                if let rating = data.rating {
                    Circle()
                        .fill(Color.ratingColor(for: rating))
                        .frame(width: 12, height: 12)
                }

                Text("Week \(data.weekNumber.formatted())")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
            }

            // Context
            Text("Age \(data.year) • Week \(data.weekOfYear) of year")
                .font(.system(size: 13))
                .foregroundStyle(Color.textSecondary)

            // Date range (pre-computed)
            Text(data.dateRange)
                .font(.system(size: 12))
                .foregroundStyle(Color.textTertiary)

            // Status
            if data.rating != nil {
                Text("Tap to edit")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, 2)
            } else if data.isCurrentWeek {
                Text("This week")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.weekCurrent)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgPrimary)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.border, lineWidth: 1)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 100)
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    // MARK: - Week Date Range Helper

    private func weekDateRange(for weekNumber: Int) -> String {
        let calendar = Calendar.current
        let startOfLife = calendar.startOfDay(for: user.birthDate)

        guard let weekStart = calendar.date(byAdding: .day, value: (weekNumber - 1) * 7, to: startOfLife),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startStr = formatter.string(from: weekStart)
        let endStr = formatter.string(from: weekEnd)

        let startYear = calendar.component(.year, from: weekStart)
        return "\(startStr) – \(endStr), \(startYear)"
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
                        .foregroundStyle(Color.ratingColor(for: weekData(for: currentWeekNumber)?.rating ?? 3))
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
            showPulse = true
        }
    }

    // MARK: - Header

    private var headerView: some View {
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
    }

    // MARK: - Animated Grid

    private func animatedGridContent(cellSize: CGFloat, spacing: CGFloat) -> some View {
        let gridWidth = CGFloat(weeksPerRow) * (cellSize + spacing) - spacing
        let gridHeight = CGFloat(user.lifeExpectancy) * (cellSize + spacing) - spacing

        return TimelineView(.animation) { timeline in
            let elapsed = animationStartTime.map { timeline.date.timeIntervalSince($0) } ?? 0
            let progress = min(1.0, elapsed / revealDuration)
            let easedProgress = 1 - pow(1 - progress, 2)
            let revealedCount = Int(Double(weeksLived) * easedProgress)

            Canvas { context, size in
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

// MARK: - Pulsing Dot View

struct PulsingDot: View {
    let cellSize: CGFloat
    private let pulseDuration: Double = 2.0

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let phase = (sin(elapsed * .pi / pulseDuration) + 1) / 2
            let scale = 1.0 + (0.25 * phase)

            Circle()
                .fill(Color.weekCurrent)
                .frame(width: cellSize, height: cellSize)
                .scaleEffect(scale)
        }
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
