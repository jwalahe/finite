//
//  WidgetDataProvider.swift
//  Finite
//
//  Shared data provider for widget communication
//

import Foundation
import WidgetKit

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
        #if DEBUG
        if defaults == nil {
            print("⚠️ WidgetDataProvider: Failed to create UserDefaults with App Group: \(appGroupIdentifier)")
            print("⚠️ Make sure App Group is added in Xcode Signing & Capabilities for both app and widget targets")
        } else {
            print("✅ WidgetDataProvider: Successfully connected to App Group: \(appGroupIdentifier)")
        }
        #endif
    }

    /// Update widget data from User model
    func updateWidgetData(from user: User) {
        guard let defaults = defaults else {
            print("⚠️ WidgetDataProvider: Cannot update - UserDefaults is nil")
            return
        }

        defaults.set(user.weeksRemaining, forKey: WidgetDataKey.weeksRemaining.rawValue)
        defaults.set(user.weeksLived, forKey: WidgetDataKey.weeksLived.rawValue)
        defaults.set(user.totalWeeks, forKey: WidgetDataKey.totalWeeks.rawValue)
        defaults.set(user.birthDate, forKey: WidgetDataKey.birthDate.rawValue)
        defaults.set(user.lifeExpectancy, forKey: WidgetDataKey.lifeExpectancy.rawValue)
        defaults.set(Date(), forKey: WidgetDataKey.lastUpdated.rawValue)

        // Force synchronize to ensure data is written immediately
        defaults.synchronize()

        #if DEBUG
        print("✅ WidgetDataProvider: Updated widget data - weeksRemaining: \(user.weeksRemaining), weeksLived: \(user.weeksLived)")
        #endif

        // Request widget refresh
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Get weeks remaining for widget display
    var weeksRemaining: Int {
        // If we have stored data, use it
        if let stored = defaults?.integer(forKey: WidgetDataKey.weeksRemaining.rawValue), stored > 0 {
            return stored
        }

        // Otherwise calculate from stored birth date if available
        if let birthDate = defaults?.object(forKey: WidgetDataKey.birthDate.rawValue) as? Date,
           let lifeExpectancy = defaults?.integer(forKey: WidgetDataKey.lifeExpectancy.rawValue), lifeExpectancy > 0 {
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
            let currentWeek = (days / 7) + 1
            let totalWeeks = lifeExpectancy * 52
            return max(0, totalWeeks - currentWeek)
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
        defaults?.integer(forKey: WidgetDataKey.totalWeeks.rawValue) ?? 4160 // 80 years default
    }

    /// Check if widget has valid data
    var hasValidData: Bool {
        weeksRemaining > 0 || weeksLived > 0
    }
}
