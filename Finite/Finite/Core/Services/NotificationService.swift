//
//  NotificationService.swift
//  Finite
//
//  Handles daily and milestone notifications
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let dailyNotificationIdentifier = "finite.daily.reminder"

    private init() {}

    // MARK: - Permission

    /// Request notification permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("⚠️ NotificationService: Failed to request permission - \(error)")
            return false
        }
    }

    /// Check if notifications are authorized
    func checkPermission() async -> Bool {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    // MARK: - Daily Notification

    /// Schedule daily notification at specified time
    /// Behavioral design: Rotate through nudges to prevent habituation
    func scheduleDailyNotification(weeksRemaining: Int, at time: Date) {
        // Cancel existing daily notification
        cancelDailyNotification()

        // Create content with memento mori nudge
        let content = UNMutableNotificationContent()

        // Rotating nudges based on day of week - prevents habituation
        let nudges = [
            "\(weeksRemaining.formatted()) weeks. Make this one count.",
            "\(weeksRemaining.formatted()) weeks remain. What matters today?",
            "\(weeksRemaining.formatted()) weeks left. Live deliberately.",
            "\(weeksRemaining.formatted()) weeks. Time is finite.",
            "\(weeksRemaining.formatted()) weeks remaining. Mark your week.",
            "\(weeksRemaining.formatted()) weeks. Don't sleepwalk through today.",
            "\(weeksRemaining.formatted()) weeks left. What will you do with them?"
        ]

        // Use day of week to rotate (0-6)
        let dayOfWeek = Calendar.current.component(.weekday, from: Date()) - 1
        content.body = nudges[dayOfWeek % nudges.count]
        content.sound = .default

        // Extract hour and minute from the time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        // Create daily trigger
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create request
        let request = UNNotificationRequest(
            identifier: dailyNotificationIdentifier,
            content: content,
            trigger: trigger
        )

        // Schedule
        notificationCenter.add(request) { error in
            if let error = error {
                print("⚠️ NotificationService: Failed to schedule daily notification - \(error)")
            } else {
                #if DEBUG
                print("✅ NotificationService: Scheduled daily notification for \(components.hour ?? 0):\(components.minute ?? 0) - \(weeksRemaining) weeks")
                #endif
            }
        }
    }

    /// Cancel daily notification
    func cancelDailyNotification() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyNotificationIdentifier])
    }

    /// Update daily notification (call when weeks change or settings change)
    func updateDailyNotification(enabled: Bool, weeksRemaining: Int, at time: Date) {
        if enabled {
            scheduleDailyNotification(weeksRemaining: weeksRemaining, at: time)
        } else {
            cancelDailyNotification()
        }
    }

    // MARK: - Milestone Notifications

    /// Schedule milestone notification for a specific date
    /// PRD: Decade birthdays, halfway point
    func scheduleMilestoneNotification(title: String, body: String, on date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("⚠️ NotificationService: Failed to schedule milestone - \(error)")
            }
        }
    }

    /// Schedule all upcoming milestone notifications for a user
    func scheduleUpcomingMilestones(birthDate: Date, currentAge: Int, lifeExpectancy: Int) {
        let calendar = Calendar.current

        // Calculate upcoming decade birthdays
        let nextDecade = ((currentAge / 10) + 1) * 10

        for decade in stride(from: nextDecade, through: lifeExpectancy, by: 10) {
            guard let decadeDate = calendar.date(byAdding: .year, value: decade, to: birthDate) else { continue }

            // Only schedule if in the future
            if decadeDate > Date() {
                let weeksAtDecade = decade * 52
                let weeksRemaining = max(0, (lifeExpectancy * 52) - weeksAtDecade)

                scheduleMilestoneNotification(
                    title: "Milestone",
                    body: "You've now lived \(decade) years. \(weeksRemaining.formatted()) weeks remaining.",
                    on: decadeDate,
                    identifier: "finite.milestone.decade.\(decade)"
                )
            }
        }

        // Calculate halfway point
        let halfwayAge = lifeExpectancy / 2
        if currentAge < halfwayAge {
            if let halfwayDate = calendar.date(byAdding: .year, value: halfwayAge, to: birthDate),
               halfwayDate > Date() {
                let halfwayWeeks = halfwayAge * 52
                scheduleMilestoneNotification(
                    title: "Halfway",
                    body: "You've reached the halfway point. \(halfwayWeeks.formatted()) weeks lived, \(halfwayWeeks.formatted()) remaining.",
                    on: halfwayDate,
                    identifier: "finite.milestone.halfway"
                )
            }
        }
    }

    /// Cancel all milestone notifications
    func cancelAllMilestones() {
        notificationCenter.getPendingNotificationRequests { requests in
            let milestoneIds = requests
                .filter { $0.identifier.hasPrefix("finite.milestone.") }
                .map { $0.identifier }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: milestoneIds)
        }
    }

    /// Cancel all notifications (daily + milestones)
    func cancelAll() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
}
