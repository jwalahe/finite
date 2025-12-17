//
//  ContentView.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var users: [User]

    @State private var hasCompletedOnboarding = false
    @State private var currentUser: User?
    @State private var isUnlocked = false
    @State private var needsLock = false

    var body: some View {
        Group {
            if let user = users.first, user.biometricLockEnabled, !isUnlocked, needsLock {
                // Show lock screen for returning user with biometric enabled
                LockScreen {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isUnlocked = true
                    }
                }
            } else if hasCompletedOnboarding, let user = currentUser {
                // Just completed onboarding - show grid WITH reveal animation
                GridView(user: user, shouldReveal: true)
                    .onAppear {
                        syncWidgetData(for: user)
                        setupNotifications(for: user)
                    }
            } else if let user = users.first {
                // Returning user - show grid without reveal animation
                GridView(user: user, shouldReveal: false)
                    .onAppear {
                        syncWidgetData(for: user)
                        setupNotifications(for: user)
                    }
            } else {
                // No user - show onboarding
                OnboardingView { user in
                    currentUser = user
                    hasCompletedOnboarding = true
                    syncWidgetData(for: user)
                    setupNotifications(for: user)
                }
            }
        }
        .onAppear {
            // Check if we need lock on initial appear
            if let user = users.first, user.biometricLockEnabled {
                needsLock = true
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Re-lock when app goes to background
            if newPhase == .background {
                if let user = users.first, user.biometricLockEnabled {
                    isUnlocked = false
                    needsLock = true
                }
            }
        }
    }

    /// Sync user data to widget via App Group UserDefaults
    private func syncWidgetData(for user: User) {
        WidgetDataProvider.shared.updateWidgetData(from: user)
    }

    /// Setup notifications for the user
    private func setupNotifications(for user: User) {
        // Schedule daily notification if enabled
        NotificationService.shared.updateDailyNotification(
            enabled: user.dailyNotificationEnabled,
            weeksRemaining: user.weeksRemaining,
            at: user.dailyNotificationTime
        )

        // Schedule milestone notifications
        NotificationService.shared.scheduleUpcomingMilestones(
            birthDate: user.birthDate,
            currentAge: user.yearsLived,
            lifeExpectancy: user.lifeExpectancy
        )
    }
}

#Preview("With User") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Week.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    return ContentView()
        .modelContainer(container)
}

#Preview("Onboarding") {
    ContentView()
        .modelContainer(for: [User.self, Week.self], inMemory: true)
}
