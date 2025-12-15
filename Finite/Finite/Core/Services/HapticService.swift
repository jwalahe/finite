//
//  HapticService.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import UIKit

final class HapticService {
    static let shared = HapticService()

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        selectionGenerator.prepare()
    }

    /// Light tap - for subtle feedback
    func light() {
        lightGenerator.impactOccurred()
    }

    /// Medium impact - for year boundaries during reveal
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
}
