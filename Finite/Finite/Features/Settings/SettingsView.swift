//
//  SettingsView.swift
//  Finite
//
//  Settings screen for notifications, security, and preferences
//

import SwiftUI

struct SettingsView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss

    // Local state for toggles (synced to user model)
    @State private var notificationsEnabled: Bool
    @State private var notificationTime: Date

    init(user: User) {
        self.user = user
        _notificationsEnabled = State(initialValue: user.dailyNotificationEnabled)
        _notificationTime = State(initialValue: user.dailyNotificationTime)
    }

    var body: some View {
        NavigationStack {
            List {
                // Notifications Section
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        Label {
                            Text("Daily Reminder")
                        } icon: {
                            Image(systemName: "bell.fill")
                        }
                    }
                    .onChange(of: notificationsEnabled) { _, newValue in
                        user.dailyNotificationEnabled = newValue
                        HapticService.shared.light()
                        updateNotificationSchedule()
                    }

                    if notificationsEnabled {
                        DatePicker(
                            selection: $notificationTime,
                            displayedComponents: .hourAndMinute
                        ) {
                            Label {
                                Text("Time")
                            } icon: {
                                Image(systemName: "clock.fill")
                            }
                        }
                        .onChange(of: notificationTime) { _, newValue in
                            user.dailyNotificationTime = newValue
                            updateNotificationSchedule()
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Receive a daily reminder with your weeks remaining")
                }

                // About Section
                Section {
                    HStack {
                        Text("Life Expectancy")
                        Spacer()
                        Text("\(user.lifeExpectancy) years")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Total Weeks")
                        Spacer()
                        Text(user.totalWeeks.formatted())
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Weeks Lived")
                        Spacer()
                        Text(user.weeksLived.formatted())
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Your Life")
                }

                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            requestNotificationPermissionIfNeeded()
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
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
}

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    return SettingsView(user: user)
}
