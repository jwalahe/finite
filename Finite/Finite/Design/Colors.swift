//
//  Colors.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import SwiftUI

extension Color {
    // MARK: - Spectrum Rating Colors

    static let ratingAwful = Color(red: 0.76, green: 0.22, blue: 0.22)      // Deep Red
    static let ratingHard = Color(red: 0.85, green: 0.45, blue: 0.25)       // Orange-Red
    static let ratingOkay = Color(red: 0.78, green: 0.68, blue: 0.35)       // Amber
    static let ratingGood = Color(red: 0.45, green: 0.70, blue: 0.45)       // Soft Green
    static let ratingGreat = Color(red: 0.22, green: 0.55, blue: 0.35)      // Deep Green

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

    // MARK: - UI Colors

    static let gridUnfilled = Color(.systemGray5)
    static let gridFilled = Color(.systemGray3)
    static let gridFilledBW = Color(.systemGray2)

    // MARK: - Semantic Colors

    static let finiteBackground = Color(.systemBackground)
    static let finiteText = Color(.label)
    static let finiteSecondaryText = Color(.secondaryLabel)
}
