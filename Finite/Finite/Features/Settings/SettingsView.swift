//
//  SettingsView.swift
//  Finite
//
//  Settings screen with custom styling that matches the app aesthetic
//  Philosophy: Settings should feel like part of the contemplative experience
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Sheet states
    @State private var showBirthDateSheet: Bool = false
    @State private var showLifeExpectancySheet: Bool = false
    @State private var showEraseConfirmation: Bool = false

    // Local state for notification settings (synced to user model)
    @State private var notificationsEnabled: Bool
    @State private var milestoneAlertsEnabled: Bool
    @State private var notificationTime: Date

    init(user: User) {
        self.user = user
        _notificationsEnabled = State(initialValue: user.dailyNotificationEnabled)
        _milestoneAlertsEnabled = State(initialValue: user.milestoneAlertsEnabled)
        _notificationTime = State(initialValue: user.dailyNotificationTime)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // YOUR LIFE
                    yourLifeSection

                    // REMINDERS
                    remindersSection

                    // DATA
                    dataSection

                    // Footer
                    footerView
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .onAppear {
            requestNotificationPermissionIfNeeded()
        }
        .sheet(isPresented: $showBirthDateSheet) {
            BirthDateSheet(birthDate: Binding(
                get: { user.birthDate },
                set: { user.birthDate = $0 }
            ))
        }
        .sheet(isPresented: $showLifeExpectancySheet) {
            LifeExpectancySheet(lifeExpectancy: Binding(
                get: { user.lifeExpectancy },
                set: { user.lifeExpectancy = $0 }
            ))
        }
        .alert("Erase Everything?", isPresented: $showEraseConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Erase", role: .destructive) {
                eraseAllData()
            }
        } message: {
            Text("This will delete all your life data including phases, marked weeks, and horizons. This cannot be undone.")
        }
    }

    // MARK: - YOUR LIFE Section

    private var yourLifeSection: some View {
        SettingsSection(title: "YOUR LIFE") {
            SettingsRow(
                label: "Born",
                value: user.birthDate.formatted(.dateTime.month(.wide).day().year())
            ) {
                showBirthDateSheet = true
            }

            SettingsDivider()

            SettingsRow(
                label: "Expected lifespan",
                value: "\(user.lifeExpectancy) years"
            ) {
                showLifeExpectancySheet = true
            }
        }
    }

    // MARK: - REMINDERS Section

    private var remindersSection: some View {
        SettingsSection(title: "REMINDERS") {
            SettingsToggleRow(
                label: "Daily notification",
                isOn: $notificationsEnabled
            ) { newValue in
                user.dailyNotificationEnabled = newValue
                updateNotificationSchedule()
            }

            if notificationsEnabled {
                SettingsDivider()

                SettingsTimeRow(
                    label: "Time",
                    time: $notificationTime
                ) { newValue in
                    user.dailyNotificationTime = newValue
                    updateNotificationSchedule()
                }
            }

            SettingsDivider()

            SettingsToggleRow(
                label: "Milestone alerts",
                isOn: $milestoneAlertsEnabled
            ) { newValue in
                user.milestoneAlertsEnabled = newValue
            }
        }
    }

    // MARK: - DATA Section

    private var dataSection: some View {
        SettingsSection(title: "DATA") {
            SettingsDestructiveRow(label: "Erase everything") {
                showEraseConfirmation = true
            }
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        VStack(spacing: 4) {
            Text("finite v\(appVersion)")
                .font(.caption)
                .foregroundStyle(Color.textTertiary)

            Text("\"Hurry up and live.\" — Seneca")
                .font(.system(size: 11))
                .italic()
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.top, 24)
        .padding(.bottom, 32)
    }

    // MARK: - Helpers

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return version
    }

    private func requestNotificationPermissionIfNeeded() {
        if notificationsEnabled {
            Task {
                let granted = await NotificationService.shared.requestPermission()
                if !granted {
                    await MainActor.run {
                        notificationsEnabled = false
                        user.dailyNotificationEnabled = false
                    }
                }
            }
        }
    }

    private func updateNotificationSchedule() {
        NotificationService.shared.updateDailyNotification(
            enabled: notificationsEnabled,
            weeksRemaining: user.weeksRemaining,
            at: notificationTime
        )
    }

    private func eraseAllData() {
        // Delete all weeks
        let weekDescriptor = FetchDescriptor<Week>()
        if let weeks = try? modelContext.fetch(weekDescriptor) {
            weeks.forEach { modelContext.delete($0) }
        }

        // Delete all phases
        let phaseDescriptor = FetchDescriptor<LifePhase>()
        if let phases = try? modelContext.fetch(phaseDescriptor) {
            phases.forEach { modelContext.delete($0) }
        }

        // Delete all milestones
        let milestoneDescriptor = FetchDescriptor<Milestone>()
        if let milestones = try? modelContext.fetch(milestoneDescriptor) {
            milestones.forEach { modelContext.delete($0) }
        }

        // Reset user settings to defaults (keep birth date)
        user.lifeExpectancy = 80
        user.currentViewMode = .focus
        user.hasSeenReveal = false
        user.hasSeenPhasePrompt = false
        user.hasSeenSwipeHint = false

        // Cancel all notifications
        NotificationService.shared.cancelAll()

        // Haptic feedback
        HapticService.shared.success()

        // Dismiss settings
        dismiss()
    }
}

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    return SettingsView(user: user)
}
