//
//  PhaseColorService.swift
//  Finite
//
//  Manages auto-assignment of colors to life phases
//

import SwiftUI

final class PhaseColorService {
    static let shared = PhaseColorService()

    private init() {}

    /// Get the next available color hex for a new phase
    /// - Parameter existingPhases: List of existing phases to check used colors
    /// - Returns: Hex string for the next available color
    func nextAvailableColorHex(existingPhases: [LifePhase]) -> String {
        let usedColors = Set(existingPhases.map { $0.colorHex })
        let palette = Color.phaseColorPalette

        // Find first unused color
        for (hex, _) in palette {
            if !usedColors.contains(hex) {
                return hex
            }
        }

        // If all colors used, cycle back to the first
        return palette.first?.hex ?? "#78716C"
    }

    /// Get Color from a phase's hex string
    func color(for phase: LifePhase) -> Color {
        Color.fromHex(phase.colorHex)
    }

    /// Get Color for a hex string
    func color(fromHex hex: String) -> Color {
        Color.fromHex(hex)
    }

    /// All available phase colors with their hex values
    var availableColors: [(hex: String, color: Color)] {
        Color.phaseColorPalette
    }
}
