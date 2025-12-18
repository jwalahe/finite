//
//  LifePhase.swift
//  Finite
//
//  Life chapters for the cold start solution
//  Allows users to define periods like "College", "First Job", etc.
//

import Foundation
import SwiftData

@Model
final class LifePhase {
    var id: UUID
    var name: String
    var startYear: Int
    var endYear: Int
    var defaultRating: Int?
    var colorHex: String
    var createdAt: Date
    var sortOrder: Int

    init(name: String, startYear: Int, endYear: Int, colorHex: String = "#78716C") {
        self.id = UUID()
        self.name = name
        self.startYear = startYear
        self.endYear = endYear
        self.colorHex = colorHex
        self.createdAt = Date()
        self.sortOrder = 0
    }

    // MARK: - Week Calculations

    /// Calculate start week number given user's birth year
    /// Week 1 is the first week of the birth year
    func startWeek(birthYear: Int) -> Int {
        let yearsFromBirth = startYear - birthYear
        // Year 0 (birth year) starts at week 1
        // Each subsequent year adds 52 weeks
        return max(1, yearsFromBirth * 52 + 1)
    }

    /// Calculate end week number given user's birth year
    /// Returns the last week of the endYear (52 weeks per year)
    func endWeek(birthYear: Int) -> Int {
        let yearsFromBirth = endYear - birthYear
        // Last week of a year is (yearOffset + 1) * 52
        return (yearsFromBirth + 1) * 52
    }

    /// Check if a week number falls within this phase
    func containsWeek(_ weekNumber: Int, birthYear: Int) -> Bool {
        let start = startWeek(birthYear: birthYear)
        let end = endWeek(birthYear: birthYear)
        return weekNumber >= start && weekNumber <= end
    }

    /// Duration in years
    var durationYears: Int {
        return endYear - startYear + 1
    }

    /// Duration in weeks
    var durationWeeks: Int {
        return durationYears * 52
    }
}
