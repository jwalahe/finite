//
//  YearTransitionCard.swift
//  Finite
//
//  SST §17.5: The Year Transition Card
//  Marks entering a new year of life (birthday week)
//  "Entering year X of my life"
//

import SwiftUI

// MARK: - Year Transition Card View

struct YearTransitionCard: View {
    let age: Int
    let weekNumber: Int
    let quote: String?
    let style: PerspectiveCardStyle

    // SST §17.5: 1080 × 1920px (9:16 Stories)
    private let aspectRatio: CGFloat = 9 / 16

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
                        // "Entering year X" - SST: 24pt
                        VStack(spacing: 4) {
                            Text("Entering year \(age)")
                                .font(.system(size: geometry.size.width * 0.06, weight: .regular))
                                .foregroundStyle(primaryTextColor)

                            Text("of my life")
                                .font(.system(size: geometry.size.width * 0.045, weight: .regular))
                                .foregroundStyle(secondaryTextColor)
                        }

                        Spacer().frame(height: geometry.size.height * 0.04)

                        // Week number - SST: 48pt
                        Text("Week \(formatNumber(weekNumber))")
                            .font(.system(size: geometry.size.width * 0.11, weight: .light))
                            .foregroundStyle(primaryTextColor)

                        // Divider
                        Rectangle()
                            .fill(dividerColor.opacity(0.6))
                            .frame(width: geometry.size.width * 0.5, height: 1)
                            .padding(.vertical, geometry.size.height * 0.025)

                        // Optional quote - SST: 18pt, italic
                        if let quote = quote, !quote.isEmpty {
                            Text("\"\(quote)\"")
                                .font(.system(size: geometry.size.width * 0.042, weight: .regular))
                                .italic()
                                .multilineTextAlignment(.center)
                                .foregroundStyle(primaryTextColor.opacity(0.9))
                                .padding(.horizontal, geometry.size.width * 0.12)
                                .lineSpacing(4)
                        }
                    }

                    Spacer()

                    // Bottom branding
                    Text("finite")
                        .font(.system(size: geometry.size.width * 0.035, weight: .light))
                        .foregroundStyle(secondaryTextColor.opacity(0.4))

                    // SST: Safe zone 200px bottom
                    Spacer()
                        .frame(height: geometry.size.height * 0.12)
                }
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }

    // MARK: - Helpers

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Year Transition Card Exporter

struct YearTransitionCardExporter {
    /// Export year transition card as high-resolution image
    /// SST §17.5: 1080 × 1920px
    @MainActor
    static func exportImage(
        age: Int,
        weekNumber: Int,
        quote: String?,
        style: PerspectiveCardStyle
    ) -> UIImage? {
        let card = YearTransitionCard(
            age: age,
            weekNumber: weekNumber,
            quote: quote,
            style: style
        )
        .frame(width: 1080, height: 1920)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 1.0
        return renderer.uiImage
    }
}

// MARK: - Default Birthday Quotes

enum BirthdayQuotes {
    static func defaults(for age: Int) -> [String] {
        let decade = (age / 10) * 10
        let decadeName: String
        switch decade {
        case 20: decadeName = "twenties"
        case 30: decadeName = "thirties"
        case 40: decadeName = "forties"
        case 50: decadeName = "fifties"
        case 60: decadeName = "sixties"
        case 70: decadeName = "seventies"
        case 80: decadeName = "eighties"
        case 90: decadeName = "nineties"
        default: decadeName = "\(decade)s"
        }

        return [
            "The \(decadeName). Let's see what I can make of them.",
            "Another year of intentional living.",
            "Time doesn't stop. Neither do I.",
            "Every year is a gift. I choose how to spend it.",
            "New year, same finite weeks. Make them count."
        ]
    }

    static func random(for age: Int) -> String {
        defaults(for: age).randomElement() ?? defaults(for: age)[0]
    }
}

// MARK: - Previews

#Preview("Dark - Age 30") {
    YearTransitionCard(
        age: 30,
        weekNumber: 1561,
        quote: "The thirties. Let's see what I can make of them.",
        style: .dark
    )
    .frame(width: 270, height: 480)
}

#Preview("Light - Age 40") {
    YearTransitionCard(
        age: 40,
        weekNumber: 2081,
        quote: "Another year of intentional living.",
        style: .light
    )
    .frame(width: 270, height: 480)
}

#Preview("No Quote") {
    YearTransitionCard(
        age: 35,
        weekNumber: 1821,
        quote: nil,
        style: .dark
    )
    .frame(width: 270, height: 480)
}
