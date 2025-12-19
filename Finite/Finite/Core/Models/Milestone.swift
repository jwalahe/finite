//
//  Milestone.swift
//  Finite
//
//  Life milestones for the Horizons feature
//  Allows users to pin goals to future weeks
//

import Foundation
import SwiftData

@Model
final class Milestone {
    var id: UUID
    var name: String
    var targetWeekNumber: Int  // Must be > user.currentWeekNumber
    var categoryRaw: String?   // WeekCategory raw value
    var notes: String?
    var iconName: String?      // SF Symbol name, optional

    // State
    var isCompleted: Bool
    var completedAt: Date?
    var completedWeekNumber: Int?  // Actual week completed (may differ from target)

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    init(name: String, targetWeekNumber: Int, category: WeekCategory? = nil) {
        self.id = UUID()
        self.name = name
        self.targetWeekNumber = targetWeekNumber
        self.categoryRaw = category?.rawValue
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Category Access

    var category: WeekCategory? {
        get {
            guard let raw = categoryRaw else { return nil }
            return WeekCategory(rawValue: raw)
        }
        set {
            categoryRaw = newValue?.rawValue
        }
    }

    // MARK: - Computed Properties

    /// Weeks remaining until target
    func weeksRemaining(from currentWeek: Int) -> Int {
        return max(0, targetWeekNumber - currentWeek)
    }

    /// Target age based on user's birth year
    func targetAge(birthYear: Int) -> Int {
        return targetWeekNumber / 52
    }

    /// Human-readable time until milestone
    func timeUntilDescription(from currentWeek: Int) -> String {
        let weeks = weeksRemaining(from: currentWeek)
        if weeks == 0 { return "This week" }
        if weeks == 1 { return "1 week" }
        if weeks < 52 { return "\(weeks) weeks" }

        let years = weeks / 52
        let remainingWeeks = weeks % 52
        if remainingWeeks == 0 {
            return years == 1 ? "1 year" : "\(years) years"
        }
        return "\(years)y \(remainingWeeks)w"
    }

    /// Status for display
    enum Status {
        case upcoming
        case thisWeek
        case overdue
        case completed
    }

    func status(currentWeek: Int) -> Status {
        if isCompleted { return .completed }
        if targetWeekNumber < currentWeek { return .overdue }
        if targetWeekNumber == currentWeek { return .thisWeek }
        return .upcoming
    }

    /// Mark milestone as complete
    func complete(atWeek currentWeek: Int) {
        isCompleted = true
        completedAt = Date()
        completedWeekNumber = currentWeek
        updatedAt = Date()
    }

    /// Color for display (from category or default)
    var displayColorHex: String {
        category?.colorHex ?? "#78716C"  // Default warm gray
    }
}
