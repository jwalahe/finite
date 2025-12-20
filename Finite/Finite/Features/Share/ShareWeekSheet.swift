//
//  ShareWeekSheet.swift
//  Finite
//
//  Sheet for customizing and sharing Week Card
//  SST: Entry points - Settings, long-press current week
//

import SwiftUI

struct ShareWeekSheet: View {
    let user: User
    @Environment(\.dismiss) private var dismiss

    @State private var selectedStyle: WeekCardStyle = .dark
    @State private var selectedFormat: WeekCardFormat = .stories
    @State private var isExporting = false
    @State private var exportedImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Preview
                cardPreview
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                Spacer()

                // Style picker
                styleSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                // Format picker
                formatSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                // Share button
                shareButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Share Your Week")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
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
    }

    // MARK: - Card Preview

    private var cardPreview: some View {
        WeekCard(
            weekNumber: user.currentWeekNumber,
            totalWeeks: user.totalWeeks,
            style: selectedStyle,
            format: selectedFormat
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxHeight: 400)
        .animation(.easeOut(duration: 0.2), value: selectedStyle)
        .animation(.easeOut(duration: 0.2), value: selectedFormat)
    }

    // MARK: - Style Section

    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STYLE")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.textTertiary)

            HStack(spacing: 12) {
                ForEach(WeekCardStyle.allCases) { style in
                    styleButton(style)
                }
            }
        }
    }

    private func styleButton(_ style: WeekCardStyle) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                selectedStyle = style
            }
            HapticService.shared.selection()
        } label: {
            VStack(spacing: 6) {
                // Mini preview
                RoundedRectangle(cornerRadius: 6)
                    .fill(style == .light ? Color(hex: 0xFAFAFA) : Color(hex: 0x0A0A0A))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(
                                selectedStyle == style ? Color.textPrimary : Color.clear,
                                lineWidth: 2
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

    // MARK: - Format Section

    private var formatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FORMAT")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.textTertiary)

            HStack(spacing: 12) {
                ForEach(WeekCardFormat.allCases) { format in
                    formatButton(format)
                }
            }
        }
    }

    private func formatButton(_ format: WeekCardFormat) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                selectedFormat = format
            }
            HapticService.shared.selection()
        } label: {
            HStack(spacing: 8) {
                // Aspect ratio preview
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.bgTertiary)
                    .aspectRatio(format.aspectRatio, contentMode: .fit)
                    .frame(height: 24)

                Text(format.displayName)
                    .font(.subheadline)
                    .foregroundStyle(selectedFormat == format ? Color.textPrimary : Color.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedFormat == format ? Color.bgTertiary : Color.bgSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        selectedFormat == format ? Color.textPrimary.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
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
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text("Share Week \(user.currentWeekNumber.formatted())")
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
            if let image = WeekCardExporter.exportImage(
                weekNumber: user.currentWeekNumber,
                totalWeeks: user.totalWeeks,
                style: selectedStyle,
                format: selectedFormat
            ) {
                exportedImage = image
                showShareSheet = true
                HapticService.shared.success()
            }
            isExporting = false
        }
    }
}

// MARK: - UIKit Share Sheet Wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)

    return ShareWeekSheet(user: user)
}
