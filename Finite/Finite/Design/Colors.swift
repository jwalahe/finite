//
//  Colors.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import SwiftUI

extension Color {
    // MARK: - Spectrum Rating Colors (from CRAFT_SPEC)

    static let ratingAwful = Color(hex: 0xDC2626)  // Deep red
    static let ratingHard = Color(hex: 0xEA580C)   // Orange
    static let ratingOkay = Color(hex: 0xD97706)   // Amber
    static let ratingGood = Color(hex: 0x65A30D)   // Soft green
    static let ratingGreat = Color(hex: 0x16A34A)  // Deep green

    static func ratingColor(for rating: Int) -> Color {
        switch rating {
        case 1: return .ratingAwful
        case 2: return .ratingHard
        case 3: return .ratingOkay
        case 4: return .ratingGood
        case 5: return .ratingGreat
        default: return .ratingOkay
        }
    }

    // MARK: - Background Colors (from CRAFT_SPEC)

    static let bgPrimary = Color(light: Color(hex: 0xFAFAFA), dark: Color(hex: 0x0A0A0A))
    static let bgSecondary = Color(light: Color(hex: 0xF5F5F5), dark: Color(hex: 0x1C1C1E))
    static let bgTertiary = Color(light: Color(hex: 0xEFEFEF), dark: Color(hex: 0x2C2C2E))

    // MARK: - Text Colors (from CRAFT_SPEC)

    static let textPrimary = Color(light: Color(hex: 0x1A1A1A), dark: Color(hex: 0xF5F5F5))
    static let textSecondary = Color(light: Color(hex: 0x6B6B6B), dark: Color(hex: 0x8E8E93))
    static let textTertiary = Color(light: Color(hex: 0x9A9A9A), dark: Color(hex: 0x636366))

    // MARK: - Grid Colors (B&W Mode - from CRAFT_SPEC)

    static let weekEmpty = Color(light: Color(hex: 0xE0E0E0), dark: Color(hex: 0x3A3A3A))
    static let weekFilled = Color(light: Color(hex: 0x2A2A2A), dark: Color(hex: 0xE5E5E5))
    static let weekCurrent = Color(light: Color(hex: 0x1A1A1A), dark: Color(hex: 0xFFFFFF))

    // MARK: - Border Color

    static let border = Color(light: Color(hex: 0xE5E5E5), dark: Color(hex: 0x38383A))

    // MARK: - Phase Colors (Chapters Mode - from CRAFT_SPEC)

    static let phaseChildhood = Color(hex: 0x78716C)    // Warm gray
    static let phaseSchool = Color(hex: 0x6366F1)       // Slate blue
    static let phaseCollege = Color(hex: 0x4F46E5)      // Indigo
    static let phaseEarlyCareer = Color(hex: 0x0D9488)  // Teal
    static let phaseCareer = Color(hex: 0x059669)       // Emerald
    static let phaseCustom1 = Color(hex: 0x9333EA)      // Purple
    static let phaseCustom2 = Color(hex: 0xE11D48)      // Rose
    static let phaseCustom3 = Color(hex: 0x0284C7)      // Sky

    /// Ordered list of phase colors for auto-assignment
    static let phaseColorPalette: [(hex: String, color: Color)] = [
        ("#78716C", phaseChildhood),
        ("#6366F1", phaseSchool),
        ("#4F46E5", phaseCollege),
        ("#0D9488", phaseEarlyCareer),
        ("#059669", phaseCareer),
        ("#9333EA", phaseCustom1),
        ("#E11D48", phaseCustom2),
        ("#0284C7", phaseCustom3)
    ]

    /// Get Color from hex string
    static func fromHex(_ hex: String) -> Color {
        let cleanHex = hex.replacingOccurrences(of: "#", with: "")
        guard let intValue = UInt(cleanHex, radix: 16) else {
            return .gray
        }
        return Color(hex: intValue)
    }

    // MARK: - Legacy (for compatibility)

    static let gridUnfilled = weekEmpty
    static let gridFilled = weekFilled
    static let finiteBackground = bgPrimary
    static let finiteText = textPrimary
    static let finiteSecondaryText = textSecondary
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
