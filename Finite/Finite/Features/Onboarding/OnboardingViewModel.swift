//
//  OnboardingViewModel.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import Foundation
import SwiftData

@Observable
final class OnboardingViewModel {
    var birthDate: Date
    var isDateSelected: Bool = false

    private let calendar = Calendar.current

    init() {
        // Default to 30 years ago
        let thirtyYearsAgo = calendar.date(byAdding: .year, value: -30, to: Date()) ?? Date()
        self.birthDate = thirtyYearsAgo
    }

    var minimumDate: Date {
        // 120 years ago
        calendar.date(byAdding: .year, value: -120, to: Date()) ?? Date()
    }

    var maximumDate: Date {
        // Today (can't be born in the future)
        Date()
    }

    var previewWeeksLived: Int {
        let components = calendar.dateComponents([.day], from: birthDate, to: Date())
        let days = components.day ?? 0
        return (days / 7) + 1
    }

    var previewWeeksRemaining: Int {
        let totalWeeks = 80 * 52 // Default life expectancy
        return max(0, totalWeeks - previewWeeksLived)
    }

    func createUser(in context: ModelContext) -> User {
        let user = User(birthDate: birthDate)
        context.insert(user)
        return user
    }
}
