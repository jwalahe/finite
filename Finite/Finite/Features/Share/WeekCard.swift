//
//  WeekCard.swift
//  Finite
//
//  Shareable identity artifact showing user's current week number
//  SST: "The shareable identity artifact" - creates viral loop
//  Philosophy: "What's your week number?" becomes social question
//

import SwiftUI

// MARK: - Week Card Styles

enum WeekCardStyle: String, CaseIterable, Identifiable {
    case dark
    case light
    case minimal
    case grid

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        case .minimal: return "Minimal"
        case .grid: return "Grid"
        }
    }
}

// MARK: - Week Card Format

enum WeekCardFormat: String, CaseIterable, Identifiable {
    case stories  // 1080 x 1920
    case square   // 1080 x 1080

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .stories: return "Stories"
        case .square: return "Square"
        }
    }

    var aspectRatio: CGFloat {
        switch self {
        case .stories: return 9 / 16
        case .square: return 1
        }
    }

    var size: CGSize {
        switch self {
        case .stories: return CGSize(width: 1080, height: 1920)
        case .square: return CGSize(width: 1080, height: 1080)
        }
    }
}

// MARK: - Week Card View

struct WeekCard: View {
    let weekNumber: Int
    let totalWeeks: Int
    let style: WeekCardStyle
    let format: WeekCardFormat

    // Optional: For grid style
    var weeksPerRow: Int = 52

    private var percentageLived: Int {
        Int((Double(weekNumber) / Double(totalWeeks)) * 100)
    }

    private var backgroundColor: Color {
        switch style {
        case .dark, .minimal, .grid:
            return Color(hex: 0x0A0A0A)
        case .light:
            return Color(hex: 0xFAFAFA)
        }
    }

    private var textColor: Color {
        switch style {
        case .dark, .minimal, .grid:
            return Color(hex: 0xF5F5F5)
        case .light:
            return Color(hex: 0x1A1A1A)
        }
    }

    private var secondaryColor: Color {
        switch style {
        case .dark, .minimal, .grid:
            return Color(hex: 0x8E8E93)
        case .light:
            return Color(hex: 0x6B6B6B)
        }
    }

    private var progressFillColor: Color {
        switch style {
        case .dark, .grid:
            return Color(hex: 0xF5F5F5)
        case .light:
            return Color(hex: 0x1A1A1A)
        case .minimal:
            return .clear
        }
    }

    private var progressTrackColor: Color {
        switch style {
        case .dark, .grid:
            return Color(hex: 0x3A3A3A)
        case .light:
            return Color(hex: 0xE0E0E0)
        case .minimal:
            return .clear
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Main content
                    VStack(spacing: contentSpacing(for: geometry.size)) {
                        // WEEK label
                        Text("W E E K")
                            .font(.system(size: labelFontSize(for: geometry.size), weight: .medium, design: .default))
                            .tracking(6)
                            .foregroundStyle(secondaryColor)

                        // Week number
                        Text(formatWeekNumber(weekNumber))
                            .font(.system(size: numberFontSize(for: geometry.size), weight: .ultraLight, design: .default))
                            .foregroundStyle(textColor)

                        // Progress bar (not shown in minimal style)
                        if style != .minimal {
                            progressBar(for: geometry.size)
                        }

                        // Grid preview (only for grid style)
                        if style == .grid {
                            gridPreview(for: geometry.size)
                                .padding(.top, geometry.size.height * 0.02)
                        }
                    }

                    Spacer()

                    // Logo
                    Text("~ finite ~")
                        .font(.system(size: logoFontSize(for: geometry.size), weight: .light))
                        .foregroundStyle(secondaryColor.opacity(0.5))
                        .padding(.bottom, geometry.size.height * 0.06)
                }
            }
        }
        .aspectRatio(format.aspectRatio, contentMode: .fit)
    }

    // MARK: - Progress Bar

    @ViewBuilder
    private func progressBar(for size: CGSize) -> some View {
        VStack(spacing: size.height * 0.01) {
            // Bar
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

            // Percentage
            Text("\(percentageLived)%")
                .font(.system(size: percentageFontSize(for: size), weight: .regular))
                .foregroundStyle(secondaryColor)
        }
    }

    // MARK: - Grid Preview (for grid style)

    @ViewBuilder
    private func gridPreview(for size: CGSize) -> some View {
        let cellSize: CGFloat = 3
        let spacing: CGFloat = 1
        let cols = 52
        let rows = 10  // Show ~10 years around current
        let gridWidth = CGFloat(cols) * (cellSize + spacing)

        Canvas { context, canvasSize in
            let startRow = max(0, (weekNumber / cols) - 5)

            for row in 0..<rows {
                for col in 0..<cols {
                    let weekNum = (startRow + row) * cols + col + 1
                    let x = CGFloat(col) * (cellSize + spacing) + (canvasSize.width - gridWidth) / 2
                    let y = CGFloat(row) * (cellSize + spacing)

                    let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)

                    let color: Color
                    if weekNum == weekNumber {
                        color = Color(hex: 0xFFFFFF)  // Current week
                    } else if weekNum < weekNumber {
                        color = Color(hex: 0x6B6B6B)  // Past
                    } else {
                        color = Color(hex: 0x3A3A3A)  // Future
                    }

                    context.fill(Path(ellipseIn: rect), with: .color(color))
                }
            }
        }
        .frame(width: size.width * 0.8, height: CGFloat(rows) * (cellSize + spacing))
    }

    // MARK: - Sizing Helpers

    private func labelFontSize(for size: CGSize) -> CGFloat {
        size.width * 0.04
    }

    private func numberFontSize(for size: CGSize) -> CGFloat {
        size.width * 0.18
    }

    private func percentageFontSize(for size: CGSize) -> CGFloat {
        size.width * 0.04
    }

    private func logoFontSize(for size: CGSize) -> CGFloat {
        size.width * 0.035
    }

    private func contentSpacing(for size: CGSize) -> CGFloat {
        size.height * 0.02
    }

    private func formatWeekNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Week Card Export Helper

struct WeekCardExporter {
    /// Export week card as high-resolution image
    @MainActor
    static func exportImage(
        weekNumber: Int,
        totalWeeks: Int,
        style: WeekCardStyle,
        format: WeekCardFormat
    ) -> UIImage? {
        let card = WeekCard(
            weekNumber: weekNumber,
            totalWeeks: totalWeeks,
            style: style,
            format: format
        )
        .frame(width: format.size.width, height: format.size.height)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 1.0  // Already at target resolution
        return renderer.uiImage
    }
}

// MARK: - Preview

#Preview("Dark - Stories") {
    WeekCard(
        weekNumber: 1547,
        totalWeeks: 4160,
        style: .dark,
        format: .stories
    )
    .frame(width: 270, height: 480)
}

#Preview("Light - Square") {
    WeekCard(
        weekNumber: 1547,
        totalWeeks: 4160,
        style: .light,
        format: .square
    )
    .frame(width: 300, height: 300)
}

#Preview("Minimal - Stories") {
    WeekCard(
        weekNumber: 1547,
        totalWeeks: 4160,
        style: .minimal,
        format: .stories
    )
    .frame(width: 270, height: 480)
}

#Preview("Grid - Stories") {
    WeekCard(
        weekNumber: 1547,
        totalWeeks: 4160,
        style: .grid,
        format: .stories
    )
    .frame(width: 270, height: 480)
}
