//
//  FirstLaunchSequence.swift
//  Finite
//
//  SST §7.2: The Scale Revelation
//  A cinematic first launch that builds emotional weight before showing the grid.
//
//  Sequence:
//  1. FADE IN: Black screen (500ms)
//  2. TITLE: "finite" fades in center, holds, fades out
//  3. ZOOM: Single dot appears - "This is one week"
//  4. EXPAND: 52 dots form a row - "This is one year"
//  5. FULL GRID: Entire life zooms out with lived/future weeks
//  6. TRANSITION: Grid settles into normal view
//

import SwiftUI

struct FirstLaunchSequence: View {
    let user: User
    let onComplete: () -> Void

    // Animation phases
    @State private var phase: SequencePhase = .blackScreen
    @State private var titleOpacity: Double = 0
    @State private var dotScale: CGFloat = 0
    @State private var rowScale: CGFloat = 0
    @State private var gridScale: CGFloat = 0
    @State private var gridOpacity: Double = 0
    @State private var labelOpacity: Double = 0
    @State private var currentLabel: String = ""
    @State private var isComplete = false

    enum SequencePhase {
        case blackScreen
        case titleIn
        case titleHold
        case titleOut
        case singleDot
        case rowExpand
        case fullGrid
        case settle
    }

    // Computed values
    private var weeksLived: Int { user.weeksLived }
    private var totalWeeks: Int { user.totalWeeks }
    private var weeksRemaining: Int { user.weeksRemaining }

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            // Content layers
            switch phase {
            case .blackScreen:
                EmptyView()

            case .titleIn, .titleHold, .titleOut:
                titleView

            case .singleDot:
                singleDotView

            case .rowExpand:
                rowExpandView

            case .fullGrid, .settle:
                fullGridView
            }
        }
        .onAppear {
            startSequence()
        }
    }

    // MARK: - Title View

    private var titleView: some View {
        Text("finite")
            .font(.system(size: 48, weight: .ultraLight, design: .default))
            .tracking(8)
            .foregroundStyle(.white)
            .opacity(titleOpacity)
    }

    // MARK: - Single Dot View

    private var singleDotView: some View {
        VStack(spacing: 24) {
            Circle()
                .fill(Color.white)
                .frame(width: 12, height: 12)
                .scaleEffect(dotScale)

            Text(currentLabel)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(.white.opacity(0.8))
                .opacity(labelOpacity)
        }
    }

    // MARK: - Row Expand View

    private var rowExpandView: some View {
        VStack(spacing: 24) {
            // 52 dots representing one year
            HStack(spacing: 4) {
                ForEach(0..<52, id: \.self) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                }
            }
            .scaleEffect(rowScale)

            Text(currentLabel)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(.white.opacity(0.8))
                .opacity(labelOpacity)
        }
    }

    // MARK: - Full Grid View

    private var fullGridView: some View {
        VStack(spacing: 32) {
            // Miniature grid showing life
            miniatureGridView
                .scaleEffect(gridScale)
                .opacity(gridOpacity)

            // Stats label
            VStack(spacing: 8) {
                Text("\(weeksLived.formatted()) weeks lived.")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(.white)

                Text("\(weeksRemaining.formatted()) weeks possible.")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .opacity(labelOpacity)
        }
    }

    // MARK: - Miniature Grid

    private var miniatureGridView: some View {
        let cellSize: CGFloat = 4
        let spacing: CGFloat = 1.5
        let weeksPerRow = 52
        let yearsToShow = min(user.lifeExpectancy, 80)
        let gridWidth = CGFloat(weeksPerRow) * (cellSize + spacing) - spacing
        let gridHeight = CGFloat(yearsToShow) * (cellSize + spacing) - spacing

        return Canvas { context, _ in
            for year in 0..<yearsToShow {
                for week in 0..<weeksPerRow {
                    let weekNumber = year * weeksPerRow + week + 1
                    let x = CGFloat(week) * (cellSize + spacing)
                    let y = CGFloat(year) * (cellSize + spacing)
                    let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                    let circle = Path(ellipseIn: rect)

                    let isLived = weekNumber <= weeksLived
                    let isCurrent = weekNumber == weeksLived

                    let color: Color
                    if isCurrent {
                        color = Color.weekCurrent
                    } else if isLived {
                        color = .white
                    } else {
                        color = .white.opacity(0.15)
                    }

                    context.fill(circle, with: .color(color))
                }
            }
        }
        .frame(width: gridWidth, height: gridHeight)
    }

    // MARK: - Sequence Control

    private func startSequence() {
        // Phase 1: Black screen (500ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startTitlePhase()
        }
    }

    private func startTitlePhase() {
        phase = .titleIn

        // Title fades in (400ms)
        withAnimation(.easeIn(duration: 0.4)) {
            titleOpacity = 1.0
        }

        // Hold for 800ms, then fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            phase = .titleOut
            withAnimation(.easeOut(duration: 0.3)) {
                titleOpacity = 0
            }

            // Transition to single dot
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                startSingleDotPhase()
            }
        }
    }

    private func startSingleDotPhase() {
        phase = .singleDot
        currentLabel = "This is one week."

        // Dot appears with spring
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            dotScale = 1.0
        }

        // Label fades in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.3)) {
                labelOpacity = 1.0
            }
        }

        // Hold for 1.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.2)) {
                labelOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startRowPhase()
            }
        }
    }

    private func startRowPhase() {
        phase = .rowExpand
        currentLabel = "This is one year."

        // Row expands
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            rowScale = 1.0
        }

        // Label fades in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.3)) {
                labelOpacity = 1.0
            }
        }

        // Haptic tick for "year"
        HapticService.shared.medium()

        // Hold for 1.2s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                labelOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startFullGridPhase()
            }
        }
    }

    private func startFullGridPhase() {
        phase = .fullGrid

        // Grid zooms out with dramatic reveal
        withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
            gridScale = 1.0
            gridOpacity = 1.0
        }

        // Heavy haptic for "your whole life"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            HapticService.shared.heavy()
        }

        // Label fades in after grid settles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.4)) {
                labelOpacity = 1.0
            }
        }

        // Hold for 2s, then complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            completeSequence()
        }
    }

    private func completeSequence() {
        guard !isComplete else { return }
        isComplete = true

        // Fade everything out
        withAnimation(.easeOut(duration: 0.5)) {
            gridOpacity = 0
            labelOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            onComplete()
        }
    }
}

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    return FirstLaunchSequence(user: user) {
        print("Sequence complete")
    }
}
