//
//  AchievementShareSheet.swift
//  Finite
//
//  SST §18.3: Share sheet for Achievement Card
//  Appears after milestone completion
//  Simpler than Perspective - no quote picker needed
//

import SwiftUI

struct AchievementShareSheet: View {
    let milestone: Milestone
    let user: User

    @Environment(\.dismiss) private var dismiss
    @StateObject private var shareFlow = ShareFlowController.shared

    @State private var selectedStyle: PerspectiveCardStyle = .dark
    @State private var isExporting: Bool = false
    @State private var exportedImage: UIImage?
    @State private var showShareSheet: Bool = false

    private var completedWeekNumber: Int {
        milestone.completedWeekNumber ?? user.currentWeekNumber
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header message
                headerSection

                // Card preview
                cardPreview
                    .padding(.horizontal, 24)

                Spacer()

                // Style picker
                styleSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                // Share button
                shareButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            .background(Color.bgPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") {
                        dismiss()
                        shareFlow.dismiss()
                    }
                    .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = exportedImage {
                ShareSheet(activityItems: [image])
            }
        }
        .onDisappear {
            shareFlow.dismiss()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Achievement unlocked")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Text("You completed \"\(milestone.name)\"")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Card Preview

    private var cardPreview: some View {
        AchievementCard(
            milestone: milestone,
            completedWeekNumber: completedWeekNumber,
            userBirthYear: user.birthYear,
            style: selectedStyle
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxHeight: 340)
        .animation(.easeOut(duration: 0.2), value: selectedStyle)
    }

    // MARK: - Style Section

    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STYLE")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.textTertiary)

            HStack(spacing: 12) {
                ForEach(PerspectiveCardStyle.allCases) { style in
                    styleButton(style)
                }
            }
        }
    }

    private func styleButton(_ style: PerspectiveCardStyle) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                selectedStyle = style
            }
            HapticService.shared.selection()
        } label: {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(style == .light ? Color(hex: 0xFAFAFA) : Color(hex: 0x0A0A0A))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(
                                selectedStyle == style ? Color.textPrimary : Color.border,
                                lineWidth: selectedStyle == style ? 2 : 1
                            )
                    )

                Text(style.displayName)
                    .font(.caption2)
                    .foregroundStyle(selectedStyle == style ? Color.textPrimary : Color.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button {
            exportAndShare()
        } label: {
            HStack(spacing: 8) {
                if isExporting {
                    ProgressView()
                        .tint(Color.bgPrimary)
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text("Share achievement")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.textPrimary)
            .foregroundStyle(Color.bgPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isExporting)
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Export

    private func exportAndShare() {
        isExporting = true
        HapticService.shared.light()

        Task { @MainActor in
            if let image = AchievementCardExporter.exportImage(
                milestone: milestone,
                completedWeekNumber: completedWeekNumber,
                userBirthYear: user.birthYear,
                style: selectedStyle
            ) {
                exportedImage = image
                showShareSheet = true
                shareFlow.onShareCompleted(type: .achievement)
                HapticService.shared.success()
            }
            isExporting = false
        }
    }
}

// MARK: - Preview

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    let milestone = Milestone(name: "Run a marathon", targetWeekNumber: 1625, category: .health)
    milestone.complete(atWeek: 1590)

    return AchievementShareSheet(milestone: milestone, user: user)
}
