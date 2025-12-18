//
//  PhaseColor.swift
//  Finite
//
//  16-color curated palette for life phases
//  Organized in 4 rows: Neutrals, Cool tones, Warm tones, Nature tones
//

import SwiftUI

enum PhaseColor: String, CaseIterable, Codable {
    // Row 1: Neutrals
    case warmGray = "#78716C"
    case stone = "#A8A29E"
    case slate = "#64748B"
    case zinc = "#71717A"

    // Row 2: Cool tones
    case indigo = "#6366F1"
    case violet = "#8B5CF6"
    case purple = "#A855F7"
    case fuchsia = "#D946EF"

    // Row 3: Warm tones
    case rose = "#F43F5E"
    case pink = "#EC4899"
    case orange = "#F97316"
    case amber = "#F59E0B"

    // Row 4: Nature tones
    case emerald = "#10B981"
    case teal = "#14B8A6"
    case cyan = "#06B6D4"
    case sky = "#0EA5E9"

    var color: Color {
        Color.fromHex(self.rawValue)
    }

    var name: String {
        switch self {
        case .warmGray: return "Warm Gray"
        case .stone: return "Stone"
        case .slate: return "Slate"
        case .zinc: return "Zinc"
        case .indigo: return "Indigo"
        case .violet: return "Violet"
        case .purple: return "Purple"
        case .fuchsia: return "Fuchsia"
        case .rose: return "Rose"
        case .pink: return "Pink"
        case .orange: return "Orange"
        case .amber: return "Amber"
        case .emerald: return "Emerald"
        case .teal: return "Teal"
        case .cyan: return "Cyan"
        case .sky: return "Sky"
        }
    }

    /// Get PhaseColor from hex string, returns nil if not found
    static func from(hex: String) -> PhaseColor? {
        // Normalize hex (add # if missing)
        let normalizedHex = hex.hasPrefix("#") ? hex : "#\(hex)"
        return PhaseColor.allCases.first { $0.rawValue.uppercased() == normalizedHex.uppercased() }
    }

    /// Default color for new phases
    static var `default`: PhaseColor { .indigo }
}
