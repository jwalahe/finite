//
//  SettingsView.swift
//  Finite
//
//  Settings screen for notifications, security, and preferences
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LifePhase.sortOrder) private var phases: [LifePhase]

    // Local state for toggles (synced to user model)
    @State private var notificationsEnabled: Bool
    @State private var notificationTime: Date
    @State private var showPhaseBuilder: Bool = false

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

                // Life Chapters Section
                Section {
                    if phases.isEmpty {
                        Button {
                            HapticService.shared.light()
                            showPhaseBuilder = true
                        } label: {
                            Label("Add Life Chapters", systemImage: "plus.circle")
                        }
                    } else {
                        ForEach(phases) { phase in
                            NavigationLink {
                                PhaseEditView(user: user, phase: phase)
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.fromHex(phase.colorHex))
                                        .frame(width: 12, height: 12)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(phase.name)
                                            .font(.body)
                                        Text("\(String(phase.startYear)) – \(String(phase.endYear))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deletePhases)

                        Button {
                            HapticService.shared.light()
                            showPhaseBuilder = true
                        } label: {
                            Label("Add Chapter", systemImage: "plus")
                        }
                    }
                } header: {
                    Text("Life Chapters")
                } footer: {
                    if phases.isEmpty {
                        Text("Add chapters to color your past in the Chapters view mode")
                    }
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
        .sheet(isPresented: $showPhaseBuilder) {
            PhaseBuilderView(user: user, existingPhases: phases) { _ in
                // Phase added, sheet will dismiss
            }
        }
    }

    private func deletePhases(at offsets: IndexSet) {
        HapticService.shared.medium()
        for index in offsets {
            modelContext.delete(phases[index])
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
