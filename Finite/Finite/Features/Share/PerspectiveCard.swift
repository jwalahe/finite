//
//  PerspectiveCard.swift
//  Finite
//
//  SST §17.3: The primary shareable artifact
//  "Expresses identity, not just data"
//  Includes perspective quote + viral CTA
//

import SwiftUI

// MARK: - Card Style (Simplified per SST §17.2)

enum PerspectiveCardStyle: String, CaseIterable, Identifiable {
    case dark
    case light

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
}

// MARK: - Perspective Card View

struct PerspectiveCard: View {
    let weekNumber: Int
    let totalWeeks: Int
    let quote: String
    let style: PerspectiveCardStyle

    // SST §17.3: 1080 × 1920px (9:16 Stories)
    private let aspectRatio: CGFloat = 9 / 16

    private var percentageLived: Int {
        Int((Double(weekNumber) / Double(totalWeeks)) * 100)
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

    private var progressFillColor: Color {
        switch style {
        case .dark: return Color(hex: 0xF5F5F5)
        case .light: return Color(hex: 0x1A1A1A)
        }
    }

    private var progressTrackColor: Color {
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
                    VStack(spacing: geometry.size.height * 0.025) {
                        // Week number - SST: 72pt SF Pro Light
                        Text("Week \(formatNumber(weekNumber))")
                            .font(.system(size: geometry.size.width * 0.12, weight: .light))
                            .foregroundStyle(primaryTextColor)

                        // Total weeks - SST: 24pt, secondary
                        Text("of ~\(formatNumber(totalWeeks))")
                            .font(.system(size: geometry.size.width * 0.045, weight: .regular))
                            .foregroundStyle(secondaryTextColor)

                        // Spacer for visual breathing room
                        Spacer().frame(height: geometry.size.height * 0.02)

                        // Percentage - SST: 20pt
                        Text("\(percentageLived)%")
                            .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                            .foregroundStyle(primaryTextColor)

                        // Progress bar - SST: 4pt height, 60% width
                        progressBar(for: geometry.size)

                        // Spacer before quote
                        Spacer().frame(height: geometry.size.height * 0.04)

                        // Perspective quote - SST: 18pt, italic
                        Text("\"\(quote)\"")
                            .font(.system(size: geometry.size.width * 0.042, weight: .regular))
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(primaryTextColor.opacity(0.9))
                            .padding(.horizontal, geometry.size.width * 0.12)
                            .lineSpacing(4)
                    }

                    Spacer()

                    // Bottom section with CTA and branding
                    VStack(spacing: geometry.size.height * 0.015) {
                        // Viral CTA - SST: 15pt, 60% opacity
                        Text("What's your week number?")
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

    // MARK: - Progress Bar

    private func progressBar(for size: CGSize) -> some View {
        GeometryReader { barGeometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(progressTrackColor)

                // Fill
                RoundedRectangle(cornerRadius: 2)
                    .fill(progressFillColor)
                    .frame(width: barGeometry.size.width * CGFloat(percentageLived) / 100)
            }
        }
        .frame(width: size.width * 0.6, height: 4)
    }

    // MARK: - Helpers

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Perspective Card Exporter

struct PerspectiveCardExporter {
    /// Export perspective card as high-resolution image
    /// SST §17.3: 1080 × 1920px, 3x scale for high resolution
    @MainActor
    static func exportImage(
        weekNumber: Int,
        totalWeeks: Int,
        quote: String,
        style: PerspectiveCardStyle
    ) -> UIImage? {
        let card = PerspectiveCard(
            weekNumber: weekNumber,
            totalWeeks: totalWeeks,
            quote: quote,
            style: style
        )
        .frame(width: 1080, height: 1920)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 1.0  // Already at target resolution
        return renderer.uiImage
    }
}

// MARK: - Previews

#Preview("Dark") {
    PerspectiveCard(
        weekNumber: 1547,
        totalWeeks: 4160,
        quote: "I'm learning to pay attention to my time.",
        style: .dark
    )
    .frame(width: 270, height: 480)
}

#Preview("Light") {
    PerspectiveCard(
        weekNumber: 1547,
        totalWeeks: 4160,
        quote: "Every week is a decision.",
        style: .light
    )
    .frame(width: 270, height: 480)
}

#Preview("Long Quote - Dark") {
    PerspectiveCard(
        weekNumber: 1547,
        totalWeeks: 4160,
        quote: "I'm not running out of time. I'm running in time.",
        style: .dark
    )
    .frame(width: 270, height: 480)
}
