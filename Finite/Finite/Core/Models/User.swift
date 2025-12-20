//
//  User.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import Foundation
import SwiftData

@Model
final class User {
    var birthDate: Date
    var createdAt: Date

    // Settings
    var dailyNotificationEnabled: Bool
    var dailyNotificationTime: Date
    var lifeExpectancy: Int
    var currentViewModeRaw: String
    var milestoneAlertsEnabled: Bool
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var streaksEnabled: Bool = false

    // State tracking
    var hasSeenReveal: Bool
    var hasSeenPhasePrompt: Bool
    var hasSeenSwipeHint: Bool

    init(birthDate: Date) {
        self.birthDate = birthDate
        self.createdAt = Date()
        self.dailyNotificationEnabled = true
        self.dailyNotificationTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
        self.lifeExpectancy = 80
        self.currentViewModeRaw = ViewMode.chapters.rawValue
        self.milestoneAlertsEnabled = true
        self.soundEnabled = true
        self.hapticsEnabled = true
        self.streaksEnabled = false  // OFF by default for 29+ market
        self.hasSeenReveal = false
        self.hasSeenPhasePrompt = false
        self.hasSeenSwipeHint = false
    }

    // MARK: - View Mode

    var currentViewMode: ViewMode {
        get {
            ViewMode(rawValue: currentViewModeRaw) ?? .chapters
        }
        set {
            currentViewModeRaw = newValue.rawValue
        }
    }

    // MARK: - Computed Properties

    var currentWeekNumber: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: birthDate, to: Date())
        let days = components.day ?? 0
        return (days / 7) + 1
    }

    var totalWeeks: Int {
        return lifeExpectancy * 52
    }

    var weeksRemaining: Int {
        return max(0, totalWeeks - currentWeekNumber)
    }

    var weeksLived: Int {
        return currentWeekNumber
    }

    var yearsLived: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: birthDate, to: Date())
        return components.year ?? 0
    }

    var birthYear: Int {
        Calendar.current.component(.year, from: birthDate)
    }

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
}
