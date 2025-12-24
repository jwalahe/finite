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
    @Query private var users: [User]

    @State private var shouldShowReveal: Bool? = nil  // nil = not determined yet
    @State private var showFirstLaunchSequence: Bool = false  // SST §7.2 cinematic intro
    @State private var pendingUser: User? = nil  // User created during onboarding, waiting for sequence

    var body: some View {
        ZStack {
            Group {
                if showFirstLaunchSequence, let user = pendingUser ?? users.first {
                    // SST §7.2: First Launch Sequence - cinematic scale revelation
                    FirstLaunchSequence(user: user) {
                        // Sequence complete - transition to grid with reveal
                        withAnimation(.easeOut(duration: 0.3)) {
                            showFirstLaunchSequence = false
                            shouldShowReveal = true
                        }
                    }
                    .transition(.opacity)
                } else if let user = users.first {
                    // Existing user - use cached shouldShowReveal state
                    GridView(user: user, shouldReveal: shouldShowReveal ?? false)
                        .onAppear {
                            syncWidgetData(for: user)
                            setupNotifications(for: user)
                        }
                } else {
                    // No user - show onboarding
                    OnboardingView { user in
                        // New user just completed onboarding
                        pendingUser = user
                        syncWidgetData(for: user)
                        setupNotifications(for: user)
                        // Start the cinematic first launch sequence
                        withAnimation(.easeIn(duration: 0.3)) {
                            showFirstLaunchSequence = true
                        }
                    }
                }
            }
        }
        .onAppear {
            // Determine reveal state once on initial appear
            if let user = users.first {
                if shouldShowReveal == nil {
                    // First time checking - use persisted value
                    shouldShowReveal = !user.hasSeenReveal
                    // Mark as seen immediately so it won't show again
                    if !user.hasSeenReveal {
                        user.hasSeenReveal = true
                    }
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
