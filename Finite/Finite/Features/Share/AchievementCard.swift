//
//  AchievementCard.swift
//  Finite
//
//  SST §17.4: The Achievement Card
//  Celebrates milestone completion with context
//  "What are you working toward?" CTA
//

import SwiftUI

// MARK: - Achievement Card View

struct AchievementCard: View {
    let milestone: Milestone
    let completedWeekNumber: Int
    let userBirthYear: Int
    let style: PerspectiveCardStyle

    // SST §17.4: 1080 × 1920px (9:16 Stories)
    private let aspectRatio: CGFloat = 9 / 16

    private var completedAge: Int {
        completedWeekNumber / 52
    }

    private var weeksToAchieve: Int {
        // How long from setting to completing
        guard let createdWeek = estimateCreatedWeek() else { return 0 }
        return completedWeekNumber - createdWeek
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        switch style {
        case .dark: return Color(hex: 0x0A0A0A)
        case .light: return Color(hex: 0xFAFAFA)
        }
    }

    private var primaryTextColor: Color {
        switch style {
        case .dark: return Color(hex: 0xF5F5F5)
        case .light: return Color(hex: 0x1A1A1A)
        }
    }

    private var secondaryTextColor: Color {
        switch style {
        case .dark: return Color(hex: 0x8E8E93)
        case .light: return Color(hex: 0x6B6B6B)
        }
    }

    private var accentColor: Color {
        // Use milestone category color or default green for achievement
        if let category = milestone.category {
            return Color.fromHex(category.colorHex)
        }
        return Color(hex: 0x16A34A) // Success green
    }

    private var dividerColor: Color {
        switch style {
        case .dark: return Color(hex: 0x3A3A3A)
        case .light: return Color(hex: 0xE0E0E0)
        }
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    // SST: Safe zone 120px top
                    Spacer()
                        .frame(height: geometry.size.height * 0.08)

                    Spacer()

                    // Main content
                    VStack(spacing: geometry.size.height * 0.02) {
                        // Hexagon icon - SST: 48pt
                        Image(systemName: milestone.iconName ?? "hexagon.fill")
                            .font(.system(size: geometry.size.width * 0.12))
                            .foregroundStyle(accentColor)

                        Spacer().frame(height: geometry.size.height * 0.015)

                        // Milestone name - SST: 28pt, semibold
                        Text(milestone.name)
                            .font(.system(size: geometry.size.width * 0.065, weight: .semibold))
                            .foregroundStyle(primaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, geometry.size.width * 0.1)

                        // Divider - SST: 1pt line, 40% opacity
                        Rectangle()
                            .fill(dividerColor.opacity(0.6))
                            .frame(width: geometry.size.width * 0.5, height: 1)
                            .padding(.vertical, geometry.size.height * 0.02)

                        // Journey text - SST: 17pt, secondary
                        VStack(spacing: 4) {
                            Text(journeyText)
                                .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                                .foregroundStyle(secondaryTextColor)

                            Text("Achieved")
                                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                                .foregroundStyle(accentColor)
                        }

                        Spacer().frame(height: geometry.size.height * 0.04)

                        // Week number - SST: 48pt
                        Text("Week \(formatNumber(completedWeekNumber))")
                            .font(.system(size: geometry.size.width * 0.11, weight: .light))
                            .foregroundStyle(primaryTextColor)

                        // Age - SST: 20pt, secondary
                        Text("Age \(completedAge)")
                            .font(.system(size: geometry.size.width * 0.048, weight: .regular))
                            .foregroundStyle(secondaryTextColor)
                    }

                    Spacer()

                    // Bottom section with CTA and branding
                    VStack(spacing: geometry.size.height * 0.015) {
                        // Viral CTA - SST: 15pt, 60% opacity
                        Text("What are you working toward?")
                            .font(.system(size: geometry.size.width * 0.038, weight: .regular))
                            .foregroundStyle(secondaryTextColor.opacity(0.8))

                        // App branding - SST: 14pt, 20% opacity
                        Text("finite")
                            .font(.system(size: geometry.size.width * 0.035, weight: .light))
                            .foregroundStyle(secondaryTextColor.opacity(0.4))
                    }

                    // SST: Safe zone 200px bottom
                    Spacer()
                        .frame(height: geometry.size.height * 0.12)
                }
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }

    // MARK: - Helpers

    private var journeyText: String {
        if weeksToAchieve <= 0 {
            return "Set and achieved"
        } else if weeksToAchieve == 1 {
            return "Set 1 week ago"
        } else if weeksToAchieve < 52 {
            return "Set \(weeksToAchieve) weeks ago"
        } else {
            let years = weeksToAchieve / 52
            let remainingWeeks = weeksToAchieve % 52
            if remainingWeeks == 0 {
                return years == 1 ? "Set 1 year ago" : "Set \(years) years ago"
            }
            return "Set \(years)y \(remainingWeeks)w ago"
        }
    }

    private func estimateCreatedWeek() -> Int? {
        // Estimate the week when milestone was created based on createdAt date
        // This is approximate since we don't store the exact week number at creation
        let calendar = Calendar.current
        let weeksAgo = calendar.dateComponents([.weekOfYear], from: milestone.createdAt, to: Date()).weekOfYear ?? 0
        return completedWeekNumber - weeksAgo
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Achievement Card Exporter

struct AchievementCardExporter {
    /// Export achievement card as high-resolution image
    /// SST §17.4: 1080 × 1920px
    @MainActor
    static func exportImage(
        milestone: Milestone,
        completedWeekNumber: Int,
        userBirthYear: Int,
        style: PerspectiveCardStyle
    ) -> UIImage? {
        let card = AchievementCard(
            milestone: milestone,
            completedWeekNumber: completedWeekNumber,
            userBirthYear: userBirthYear,
            style: style
        )
        .frame(width: 1080, height: 1920)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 1.0
        return renderer.uiImage
    }
}

// MARK: - Previews

#Preview("Dark") {
    let milestone = Milestone(name: "Run a marathon", targetWeekNumber: 1625, category: .health)

    return AchievementCard(
        milestone: milestone,
        completedWeekNumber: 1590,
        userBirthYear: 1994,
        style: .dark
    )
    .frame(width: 270, height: 480)
}

#Preview("Light") {
    let milestone = Milestone(name: "Launch my startup", targetWeekNumber: 1650, category: .work)

    return AchievementCard(
        milestone: milestone,
        completedWeekNumber: 1612,
        userBirthYear: 1994,
        style: .light
    )
    .frame(width: 270, height: 480)
}

#Preview("Long Name - Dark") {
    let milestone = Milestone(name: "Complete my PhD dissertation and defend successfully", targetWeekNumber: 1700, category: .growth)

    return AchievementCard(
        milestone: milestone,
        completedWeekNumber: 1695,
        userBirthYear: 1994,
        style: .dark
    )
    .frame(width: 270, height: 480)
}
