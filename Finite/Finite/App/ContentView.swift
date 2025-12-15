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

    @State private var hasCompletedOnboarding = false
    @State private var currentUser: User?

    var body: some View {
        Group {
            if hasCompletedOnboarding, let user = currentUser {
                // Just completed onboarding - show grid WITH reveal animation
                // This must be checked FIRST because @Query updates immediately
                GridView(user: user, shouldReveal: true)
            } else if let user = users.first {
                // Returning user - show grid without reveal animation
                GridView(user: user, shouldReveal: false)
            } else {
                // No user - show onboarding
                OnboardingView { user in
                    currentUser = user
                    hasCompletedOnboarding = true
                }
            }
        }
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
