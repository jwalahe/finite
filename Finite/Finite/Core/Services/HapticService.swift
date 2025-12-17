//
//  HapticService.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import UIKit

/// CRAFT_SPEC: Haptic Palette
/// - Button tap: .light impact on press start
/// - Toggle: .medium impact on state change
/// - Spectrum slider notch: selection feedback
/// - Category select: .light impact
/// - Week mark confirm: .medium impact
/// - Year boundary (reveal): .medium impact
/// - Reveal complete: .heavy impact
/// - View mode toggle: .medium impact
/// - Error: notification .error
final class HapticService {
    static let shared = HapticService()

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    /// Light tap - for button taps, category select
    func light() {
        lightGenerator.impactOccurred()
    }

    /// Medium impact - for toggles, week confirm, year boundaries
    func medium() {
        mediumGenerator.impactOccurred()
    }

    /// Heavy thud - for final reveal moment
    func heavy() {
        heavyGenerator.impactOccurred()
    }

    /// Selection tick - for slider notches
    func selection() {
        selectionGenerator.selectionChanged()
    }

    /// Error notification - for validation errors
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }

    /// Success notification - for significant completions
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }
}
