//
//  SettingsComponents.swift
//  Finite
//
//  Reusable components for the Settings screen
//  Philosophy: Settings should feel like part of the contemplative experience
//

import SwiftUI

// MARK: - Section Container

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                content
            }
            .background(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Standard Row (Tappable with Value)

struct SettingsRow: View {
    let label: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticService.shared.light()
            action()
        }) {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text(value)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Navigation Row (with Chevron)

struct SettingsNavigationRow<Destination: View>: View {
    let label: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Toggle Row

struct SettingsToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    var onChange: ((Bool) -> Void)?

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onChange(of: isOn) { _, newValue in
            HapticService.shared.light()
            onChange?(newValue)
        }
    }
}

// MARK: - Time Picker Row

struct SettingsTimeRow: View {
    let label: String
    @Binding var time: Date
    var onChange: ((Date) -> Void)?

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(Color.textPrimary)
            Spacer()
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .tint(Color.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onChange(of: time) { _, newValue in
            onChange?(newValue)
        }
    }
}

// MARK: - Destructive Row

struct SettingsDestructiveRow: View {
    let label: String
    let action: () -> Void

    private let destructiveRed = Color(hex: 0xDC2626)

    var body: some View {
        Button(action: {
            HapticService.shared.light()
            action()
        }) {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundStyle(destructiveRed)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(destructiveRed.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Info Row (Non-interactive)

struct SettingsInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// MARK: - Divider

struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.border)
            .frame(height: 1)
            .padding(.leading, 16)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScrollView {
            VStack(spacing: 32) {
                SettingsSection(title: "YOUR LIFE") {
                    SettingsRow(label: "Born", value: "March 15, 1996") { }
                    SettingsDivider()
                    SettingsRow(label: "Expected lifespan", value: "80 years") { }
                }

                SettingsSection(title: "CHAPTERS") {
                    SettingsNavigationRow(label: "Manage phases") {
                        Text("Phase Manager")
                    }
                }

                SettingsSection(title: "DATA") {
                    SettingsDestructiveRow(label: "Erase everything") { }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(Color.bgPrimary)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
