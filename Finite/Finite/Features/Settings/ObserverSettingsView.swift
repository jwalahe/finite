//
//  ObserverSettingsView.swift
//  Finite
//
//  Detailed settings for Death Voice - "The Observer"
//  Philosophy: Death is not your enemy. Death is your witness.
//

import SwiftUI

struct ObserverSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var controller = DeathVoiceController.shared
    @ObservedObject private var voice = MortalityVoice.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Intro text
                    introSection

                    // Frequency selector
                    frequencySection

                    // Category toggles
                    speakAboutSection

                    // Preview button
                    previewSection
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .background(Color.bgPrimary)
            .navigationTitle("The Observer")
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
    }

    // MARK: - Intro Section

    private var introSection: some View {
        VStack(spacing: 8) {
            Text("\"Death is not your enemy.\nDeath is your witness.\"")
                .font(.system(size: 15, weight: .light))
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textSecondary)

            Text("A calm voice that observes your journey through time.")
                .font(.caption)
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Frequency Section

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VOICE FREQUENCY")
                .font(.caption)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)
                .tracking(1)

            VStack(spacing: 0) {
                ForEach(DeathVoiceSettings.Frequency.allCases, id: \.self) { freq in
                    FrequencyRow(
                        frequency: freq,
                        isSelected: controller.frequency == freq
                    ) {
                        controller.frequency = freq
                        HapticService.shared.selection()
                    }

                    if freq != .more {
                        SettingsDivider()
                    }
                }
            }
            .background(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Speak About Section

    private var speakAboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SPEAK ABOUT")
                .font(.caption)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)
                .tracking(1)

            VStack(spacing: 0) {
                CategoryToggleRow(
                    label: "Achievements",
                    description: "When I complete things",
                    isOn: Binding(
                        get: { controller.speakAboutAchievements },
                        set: { controller.speakAboutAchievements = $0 }
                    )
                )

                SettingsDivider()

                CategoryToggleRow(
                    label: "Missed moments",
                    description: "When deadlines pass",
                    isOn: Binding(
                        get: { controller.speakAboutMissedMoments },
                        set: { controller.speakAboutMissedMoments = $0 }
                    )
                )

                SettingsDivider()

                CategoryToggleRow(
                    label: "Absences",
                    description: "When I've been away",
                    isOn: Binding(
                        get: { controller.speakAboutAbsences },
                        set: { controller.speakAboutAbsences = $0 }
                    )
                )
            }
            .background(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Preview Section

    private var previewSection: some View {
        VStack(spacing: 12) {
            Button {
                if !voice.isSpeaking {
                    voice.speakPreview()
                    HapticService.shared.medium()
                }
            } label: {
                HStack {
                    if voice.isSpeaking {
                        ProgressView()
                            .tint(Color.textSecondary)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                    }

                    Text(voice.isSpeaking ? "Speaking..." : "Hear a preview")
                        .font(.subheadline)
                }
                .foregroundStyle(Color.textSecondary)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color.bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(voice.isSpeaking)

            // Voice quality indicator
            voiceQualityInfo
        }
    }

    // MARK: - Voice Quality Info

    private var voiceQualityInfo: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Text("Voice:")
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)

                Text(voice.selectedVoiceName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                if voice.hasEnhancedVoice {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.green.opacity(0.8))
                }
            }

            if !voice.hasEnhancedVoice {
                Text("For better voice quality, download enhanced voices in Settings → Accessibility → Spoken Content → Voices")
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Frequency Row

private struct FrequencyRow: View {
    let frequency: DeathVoiceSettings.Frequency
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(frequency.displayName)
                        .font(.body)
                        .foregroundStyle(Color.textPrimary)

                    Text(frequency.description)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Toggle Row

private struct CategoryToggleRow: View {
    let label: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onChange(of: isOn) { _, _ in
            HapticService.shared.light()
        }
    }
}

#Preview {
    ObserverSettingsView()
}
