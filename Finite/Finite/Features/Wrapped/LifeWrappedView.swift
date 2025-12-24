//
//  LifeWrappedView.swift
//  Finite
//
//  SST §23: Life Wrapped - Finite's "Spotify Wrapped"
//  Annual summary that generates a beautiful, shareable summary of the user's year in weeks.
//
//  The Sequence (7 screens):
//  1. Opening: "YOUR 2025" - 52 weeks. One life.
//  2. The Grid: Shows this year's row highlighted on full life grid
//  3. Quality Summary: Weeks rated, average rating, overall assessment
//  4. Best Week: Highlight of the year with user's notes
//  5. Milestones: Horizons set, horizons reached
//  6. The Number: "X weeks remain in your life. Make them count."
//  7. Share Card: Final summary → "Share My Year"
//

import SwiftUI
import SwiftData

struct LifeWrappedView: View {
    let user: User
    let year: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var weeks: [Week]
    @Query private var milestones: [Milestone]

    @State private var currentScreen: Int = 0
    @State private var showShareSheet = false
    @State private var screenOpacity: Double = 1.0

    // Computed stats for the year
    private var yearStartWeek: Int {
        // Week number at start of the calendar year
        let calendar = Calendar.current
        let birthYear = calendar.component(.year, from: user.birthDate)
        let yearsLived = year - birthYear
        return yearsLived * 52 + 1
    }

    private var yearEndWeek: Int {
        min(yearStartWeek + 51, user.currentWeekNumber)
    }

    private var weeksInYear: [Week] {
        weeks.filter { $0.weekNumber >= yearStartWeek && $0.weekNumber <= yearEndWeek }
    }

    private var ratedWeeksCount: Int {
        weeksInYear.filter { $0.rating != nil }.count
    }

    private var averageRating: Double {
        let ratings = weeksInYear.compactMap { $0.rating }
        guard !ratings.isEmpty else { return 0 }
        return Double(ratings.reduce(0, +)) / Double(ratings.count)
    }

    private var bestWeek: Week? {
        weeksInYear.filter { $0.rating == 5 }.first
    }

    private var milestonesSetThisYear: [Milestone] {
        let calendar = Calendar.current
        return milestones.filter { milestone in
            return calendar.component(.year, from: milestone.createdAt) == year
        }
    }

    private var milestonesCompletedThisYear: [Milestone] {
        let calendar = Calendar.current
        return milestones.filter { milestone in
            guard milestone.isCompleted, let completedAt = milestone.completedAt else { return false }
            return calendar.component(.year, from: completedAt) == year
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentScreen) {
                // Screen 1: Opening
                openingScreen.tag(0)

                // Screen 2: Year Grid
                yearGridScreen.tag(1)

                // Screen 3: Quality Summary
                qualitySummaryScreen.tag(2)

                // Screen 4: Best Week
                bestWeekScreen.tag(3)

                // Screen 5: Milestones
                milestonesScreen.tag(4)

                // Screen 6: The Number
                theNumberScreen.tag(5)

                // Screen 7: Share
                shareScreen.tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .opacity(screenOpacity)

            // Progress dots
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<7) { index in
                        Circle()
                            .fill(index == currentScreen ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 48)
            }

            // Close button
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
        .sheet(isPresented: $showShareSheet) {
            WrappedShareSheet(user: user, year: year, stats: wrappedStats)
        }
    }

    // MARK: - Screen 1: Opening

    private var openingScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("YOUR \(String(year))")
                .font(.system(size: 48, weight: .ultraLight))
                .tracking(8)
                .foregroundStyle(.white)

            Text("52 weeks. One life.")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(.white.opacity(0.6))

            Spacer()

            Text("Swipe to see your year")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
                .padding(.bottom, 80)
        }
    }

    // MARK: - Screen 2: Year Grid

    private var yearGridScreen: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Your year, week by week")
                .font(.system(size: 20, weight: .light))
                .foregroundStyle(.white.opacity(0.8))

            // Mini grid showing just this year's row highlighted
            yearRowVisualization

            Text("Week \(yearStartWeek) → \(yearEndWeek)")
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var yearRowVisualization: some View {
        let cellSize: CGFloat = 5
        let spacing: CGFloat = 2

        return HStack(spacing: spacing) {
            ForEach(0..<52, id: \.self) { weekOffset in
                let weekNumber = yearStartWeek + weekOffset
                let week = weeksInYear.first { $0.weekNumber == weekNumber }
                let rating = week?.rating

                Circle()
                    .fill(weekColor(rating: rating, weekNumber: weekNumber))
                    .frame(width: cellSize, height: cellSize)
            }
        }
    }

    private func weekColor(rating: Int?, weekNumber: Int) -> Color {
        if weekNumber > user.currentWeekNumber {
            return .white.opacity(0.1)
        }
        if let rating = rating {
            return Color.ratingColor(for: rating)
        }
        return .white.opacity(0.3)
    }

    // MARK: - Screen 3: Quality Summary

    private var qualitySummaryScreen: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("Quality")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .tracking(4)

            VStack(spacing: 16) {
                Text("\(ratedWeeksCount)")
                    .font(.system(size: 72, weight: .ultraLight))
                    .foregroundStyle(.white)

                Text("weeks rated")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(.white.opacity(0.6))
            }

            if ratedWeeksCount > 0 {
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: Double(star) <= averageRating ? "star.fill" : "star")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.ratingColor(for: Int(averageRating.rounded())))
                        }
                    }

                    Text("Average: \(String(format: "%.1f", averageRating))")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()
        }
    }

    // MARK: - Screen 4: Best Week

    private var bestWeekScreen: some View {
        VStack(spacing: 32) {
            Spacer()

            if let best = bestWeek {
                Text("Your best week")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(4)

                VStack(spacing: 16) {
                    Text("Week \(best.weekNumber)")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundStyle(.white)

                    if let phrase = best.phrase, !phrase.isEmpty {
                        Text("\"\(phrase)\"")
                            .font(.system(size: 17, weight: .light))
                            .italic()
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.ratingColor(for: 5))
                        }
                    }
                }
            } else {
                Text("No 5-star weeks yet")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(.white.opacity(0.6))

                Text("Every week is a chance")
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()
        }
    }

    // MARK: - Screen 5: Milestones

    private var milestonesScreen: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("Horizons")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .tracking(4)

            HStack(spacing: 48) {
                VStack(spacing: 8) {
                    Text("\(milestonesCompletedThisYear.count)")
                        .font(.system(size: 56, weight: .ultraLight))
                        .foregroundStyle(.white)
                    Text("reached")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(.white.opacity(0.6))
                }

                VStack(spacing: 8) {
                    Text("\(milestonesSetThisYear.count)")
                        .font(.system(size: 56, weight: .ultraLight))
                        .foregroundStyle(.white)
                    Text("set")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            if let firstCompleted = milestonesCompletedThisYear.first {
                VStack(spacing: 8) {
                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.fromHex(firstCompleted.displayColorHex))

                    Text(firstCompleted.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.top, 24)
            }

            Spacer()
        }
    }

    // MARK: - Screen 6: The Number

    private var theNumberScreen: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("\(user.weeksRemaining.formatted())")
                .font(.system(size: 96, weight: .ultraLight))
                .foregroundStyle(.white)

            Text("weeks remain in your life")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(.white.opacity(0.6))

            Text("Make them count.")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 24)

            Spacer()
        }
    }

    // MARK: - Screen 7: Share

    private var shareScreen: some View {
        VStack(spacing: 32) {
            Spacer()

            // Mini summary card preview
            wrappedCardPreview

            Button {
                showShareSheet = true
            } label: {
                Text("Share My Year")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 48)

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var wrappedCardPreview: some View {
        VStack(spacing: 16) {
            Text("M Y   \(String(year))")
                .font(.system(size: 24, weight: .ultraLight))
                .tracking(4)
                .foregroundStyle(.white)

            VStack(spacing: 4) {
                Text("52 weeks lived")
                Text("\(ratedWeeksCount) weeks rated")
                if ratedWeeksCount > 0 {
                    Text("Average: \(String(format: "%.1f", averageRating)) ★")
                }
            }
            .font(.system(size: 13, weight: .light))
            .foregroundStyle(.white.opacity(0.7))

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.horizontal, 24)

            VStack(spacing: 4) {
                Text("\(milestonesCompletedThisYear.count) horizons reached")
                Text("\(milestonesSetThisYear.count) horizons set")
            }
            .font(.system(size: 13, weight: .light))
            .foregroundStyle(.white.opacity(0.7))

            Text("Week \(yearStartWeek) → \(yearEndWeek)")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 8)

            Text("~ finite ~")
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(32)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Stats for Share

    private var wrappedStats: WrappedStats {
        WrappedStats(
            year: year,
            weeksRated: ratedWeeksCount,
            averageRating: averageRating,
            milestonesReached: milestonesCompletedThisYear.count,
            milestonesSet: milestonesSetThisYear.count,
            weekStart: yearStartWeek,
            weekEnd: yearEndWeek,
            weeksRemaining: user.weeksRemaining
        )
    }
}

// MARK: - Wrapped Stats

struct WrappedStats {
    let year: Int
    let weeksRated: Int
    let averageRating: Double
    let milestonesReached: Int
    let milestonesSet: Int
    let weekStart: Int
    let weekEnd: Int
    let weeksRemaining: Int
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Week.self, Milestone.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    return LifeWrappedView(user: user, year: 2025)
        .modelContainer(container)
}
