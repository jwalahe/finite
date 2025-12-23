//
//  PerspectiveShareSheet.swift
//  Finite
//
//  SST §18: Share sheet for Perspective Card
//  Appears after emotional peaks (first rating, ghost reveal)
//  Includes quote picker for identity expression
//

import SwiftUI

struct PerspectiveShareSheet: View {
    let user: User
    let triggerType: ShareSheetType

    @Environment(\.dismiss) private var dismiss
    @StateObject private var shareFlow = ShareFlowController.shared

    @State private var selectedStyle: PerspectiveCardStyle = .dark
    @State private var selectedQuote: String = PerspectiveQuotes.random
    @State private var customQuote: String = ""
    @State private var isUsingCustomQuote: Bool = false
    @State private var isExporting: Bool = false
    @State private var exportedImage: UIImage?
    @State private var showShareSheet: Bool = false

    // Header text based on trigger
    private var headerTitle: String {
        switch triggerType {
        case .firstWeek:
            return "Your journey begins"
        case .ghostReveal:
            return "This number will never be this high again"
        case .quickShare:
            return "Share your week"
        default:
            return "Share your perspective"
        }
    }

    private var activeQuote: String {
        isUsingCustomQuote ? customQuote : selectedQuote
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

                // Quote picker
                quoteSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

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
            Text(headerTitle)
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            if triggerType == .firstWeek {
                Text("Week \(user.currentWeekNumber.formatted()) of your intentional life.")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Card Preview

    private var cardPreview: some View {
        PerspectiveCard(
            weekNumber: user.currentWeekNumber,
            totalWeeks: user.totalWeeks,
            quote: activeQuote,
            style: selectedStyle
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxHeight: 340)
        .animation(.easeOut(duration: 0.2), value: selectedStyle)
        .animation(.easeOut(duration: 0.15), value: activeQuote)
    }

    // MARK: - Quote Section

    private var quoteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR PERSPECTIVE")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.textTertiary)

            // Quote options as horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PerspectiveQuotes.defaults, id: \.self) { quote in
                        quoteChip(quote)
                    }

                    // Custom quote option
                    customQuoteChip
                }
            }

            // Custom quote text field (if selected)
            if isUsingCustomQuote {
                TextField("Write your own...", text: $customQuote, axis: .vertical)
                    .lineLimit(2)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func quoteChip(_ quote: String) -> some View {
        let isSelected = !isUsingCustomQuote && selectedQuote == quote

        return Button {
            withAnimation(.easeOut(duration: 0.15)) {
                isUsingCustomQuote = false
                selectedQuote = quote
            }
            HapticService.shared.selection()
        } label: {
            Text(quote)
                .font(.caption)
                .lineLimit(2)
                .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.bgTertiary : Color.bgSecondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isSelected ? Color.textPrimary.opacity(0.3) : Color.clear,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 180)
    }

    private var customQuoteChip: some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                isUsingCustomQuote = true
            }
            HapticService.shared.selection()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "pencil")
                    .font(.caption)
                Text("Custom")
                    .font(.caption)
            }
            .foregroundStyle(isUsingCustomQuote ? Color.textPrimary : Color.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isUsingCustomQuote ? Color.bgTertiary : Color.bgSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isUsingCustomQuote ? Color.textPrimary.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
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
                Text("Share perspective")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.textPrimary)
            .foregroundStyle(Color.bgPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isExporting || (isUsingCustomQuote && customQuote.isEmpty))
        .opacity((isUsingCustomQuote && customQuote.isEmpty) ? 0.5 : 1)
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Export

    private func exportAndShare() {
        isExporting = true
        HapticService.shared.light()

        Task { @MainActor in
            if let image = PerspectiveCardExporter.exportImage(
                weekNumber: user.currentWeekNumber,
                totalWeeks: user.totalWeeks,
                quote: activeQuote,
                style: selectedStyle
            ) {
                exportedImage = image
                showShareSheet = true
                shareFlow.onShareCompleted(type: .perspective)
                HapticService.shared.success()
            }
            isExporting = false
        }
    }
}

// MARK: - Preview

#Preview("First Week") {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)

    return PerspectiveShareSheet(user: user, triggerType: .firstWeek)
}

#Preview("Ghost Reveal") {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)

    return PerspectiveShareSheet(user: user, triggerType: .ghostReveal)
}
