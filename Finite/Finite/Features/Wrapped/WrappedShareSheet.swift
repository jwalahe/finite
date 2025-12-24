//
//  WrappedShareSheet.swift
//  Finite
//
//  SST §23.4: Life Wrapped Share Card
//  The final summary card that users can share to social media.
//

import SwiftUI

struct WrappedShareSheet: View {
    let user: User
    let year: Int
    let stats: WrappedStats

    @Environment(\.dismiss) private var dismiss
    @State private var selectedStyle: CardStyle = .dark
    @State private var showShareSheet = false
    @State private var renderedImage: UIImage?

    enum CardStyle: String, CaseIterable {
        case dark = "Dark"
        case light = "Light"

        var backgroundColor: Color {
            switch self {
            case .dark: return Color(red: 0.04, green: 0.04, blue: 0.04)
            case .light: return Color(red: 0.98, green: 0.98, blue: 0.98)
            }
        }

        var textColor: Color {
            switch self {
            case .dark: return .white
            case .light: return Color(red: 0.1, green: 0.1, blue: 0.1)
            }
        }

        var secondaryColor: Color {
            textColor.opacity(0.6)
        }

        var tertiaryColor: Color {
            textColor.opacity(0.3)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Card preview
                    WrappedCard(stats: stats, style: selectedStyle)
                        .frame(width: 280, height: 497)  // 9:16 aspect ratio scaled down
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)

                    // Style selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("STYLE")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)

                        HStack(spacing: 12) {
                            ForEach(CardStyle.allCases, id: \.self) { style in
                                Button {
                                    selectedStyle = style
                                    HapticService.shared.selection()
                                } label: {
                                    HStack(spacing: 8) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(style.backgroundColor)
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(Color.textTertiary, lineWidth: 1)
                                            )

                                        Text(style.rawValue)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedStyle == style ? Color.bgSecondary : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Share button
                    Button {
                        shareCard()
                    } label: {
                        Text("Share My Year")
                            .font(.headline)
                            .foregroundStyle(Color.bgPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .padding(.vertical, 24)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Share \(String(year))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ShareSheet(activityItems: [image])
            }
        }
    }

    private func shareCard() {
        // Render the card at full resolution
        let card = WrappedCard(stats: stats, style: selectedStyle)
            .frame(width: 1080, height: 1920)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 1.0

        if let image = renderer.uiImage {
            renderedImage = image
            showShareSheet = true
            HapticService.shared.success()
        }
    }
}

// MARK: - Wrapped Card

struct WrappedCard: View {
    let stats: WrappedStats
    let style: WrappedShareSheet.CardStyle

    var body: some View {
        GeometryReader { geometry in
            let isFullSize = geometry.size.width > 500

            ZStack {
                style.backgroundColor

                VStack(spacing: isFullSize ? 48 : 24) {
                    Spacer()

                    // Year title
                    Text("M Y   \(String(stats.year))")
                        .font(.system(size: isFullSize ? 56 : 28, weight: .ultraLight))
                        .tracking(isFullSize ? 12 : 6)
                        .foregroundStyle(style.textColor)

                    // Stats
                    VStack(spacing: isFullSize ? 12 : 6) {
                        Text("52 weeks lived")
                        Text("\(stats.weeksRated) weeks rated")
                        if stats.weeksRated > 0 {
                            Text("Average: \(String(format: "%.1f", stats.averageRating)) ★")
                        }
                    }
                    .font(.system(size: isFullSize ? 24 : 12, weight: .light))
                    .foregroundStyle(style.secondaryColor)

                    // Divider
                    Rectangle()
                        .fill(style.tertiaryColor)
                        .frame(width: isFullSize ? 200 : 100, height: 1)

                    // Milestones
                    VStack(spacing: isFullSize ? 8 : 4) {
                        Text("\(stats.milestonesReached) horizons reached")
                        Text("\(stats.milestonesSet) horizons set")
                    }
                    .font(.system(size: isFullSize ? 24 : 12, weight: .light))
                    .foregroundStyle(style.secondaryColor)

                    // Week range
                    Text("Week \(stats.weekStart) → \(stats.weekEnd)")
                        .font(.system(size: isFullSize ? 20 : 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(style.tertiaryColor)
                        .padding(.top, isFullSize ? 16 : 8)

                    // Remaining
                    VStack(spacing: isFullSize ? 8 : 4) {
                        Text("\(stats.weeksRemaining.formatted()) weeks remaining")
                            .font(.system(size: isFullSize ? 20 : 10, weight: .light))
                            .foregroundStyle(style.tertiaryColor)
                    }

                    Spacer()

                    // CTA
                    Text("What's your week number?")
                        .font(.system(size: isFullSize ? 24 : 12, weight: .light))
                        .foregroundStyle(style.secondaryColor)
                        .padding(.bottom, isFullSize ? 24 : 12)

                    // Branding
                    Text("finite")
                        .font(.system(size: isFullSize ? 28 : 14, weight: .ultraLight))
                        .tracking(isFullSize ? 8 : 4)
                        .foregroundStyle(style.tertiaryColor)
                        .padding(.bottom, isFullSize ? 80 : 40)
                }
            }
        }
    }
}

#Preview {
    WrappedShareSheet(
        user: User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!),
        year: 2025,
        stats: WrappedStats(
            year: 2025,
            weeksRated: 47,
            averageRating: 3.8,
            milestonesReached: 2,
            milestonesSet: 3,
            weekStart: 1538,
            weekEnd: 1590,
            weeksRemaining: 2570
        )
    )
}
