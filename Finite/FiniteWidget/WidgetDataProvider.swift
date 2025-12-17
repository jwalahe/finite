//
//  WidgetDataProvider.swift
//  FiniteWidget
//
//  Shared data provider for widget - reads from App Group UserDefaults
//

import Foundation

/// App Group identifier for sharing data between app and widget
/// IMPORTANT: This must match exactly what's configured in Xcode Signing & Capabilities
let appGroupIdentifier = "group.com.jwalakompalli.finite"

/// Keys for UserDefaults storage
enum WidgetDataKey: String {
    case weeksRemaining = "weeksRemaining"
    case weeksLived = "weeksLived"
    case totalWeeks = "totalWeeks"
    case lastUpdated = "lastUpdated"
    case birthDate = "birthDate"
    case lifeExpectancy = "lifeExpectancy"
}

/// Provides data to the widget via shared UserDefaults
final class WidgetDataProvider {
    static let shared = WidgetDataProvider()

    private let defaults: UserDefaults?

    private init() {
        defaults = UserDefaults(suiteName: appGroupIdentifier)
    }

    /// Get weeks remaining for widget display
    var weeksRemaining: Int {
        guard let defaults = defaults else { return 0 }

        // If we have stored data, use it
        let stored = defaults.integer(forKey: WidgetDataKey.weeksRemaining.rawValue)
        if stored > 0 {
            return stored
        }

        // Otherwise calculate from stored birth date if available
        if let birthDate = defaults.object(forKey: WidgetDataKey.birthDate.rawValue) as? Date {
            let lifeExpectancy = defaults.integer(forKey: WidgetDataKey.lifeExpectancy.rawValue)
            if lifeExpectancy > 0 {
                let calendar = Calendar.current
                let days = calendar.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
                let currentWeek = (days / 7) + 1
                let totalWeeks = lifeExpectancy * 52
                return max(0, totalWeeks - currentWeek)
            }
        }

        // Default fallback
        return 0
    }

    /// Get weeks lived for widget display
    var weeksLived: Int {
        defaults?.integer(forKey: WidgetDataKey.weeksLived.rawValue) ?? 0
    }

    /// Get total weeks for widget display
    var totalWeeks: Int {
        let stored = defaults?.integer(forKey: WidgetDataKey.totalWeeks.rawValue) ?? 0
        return stored > 0 ? stored : 0
    }

    /// Check if widget has valid data
    var hasValidData: Bool {
        guard defaults != nil else { return false }
        return weeksRemaining > 0 || weeksLived > 0
    }
}
