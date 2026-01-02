//
//  MilestoneDetailSheet.swift
//  Finite
//
//  Detail sheet for viewing and acting on a milestone
//  Shows stats, allows completion and editing
//
//  SST §8.5: Clean layout, scrollable for long content
//

import SwiftUI
import SwiftData

struct MilestoneDetailSheet: View {
    let milestone: Milestone
    let user: User
    let onEdit: (() -> Void)?
    let onComplete: (() -> Void)?

    // Determine if we need more space for notes
    private var hasLongNotes: Bool {
        guard let notes = milestone.notes else { return false }
        return notes.count > 100
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with icon and name
                headerSection
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                // Stats row
                statsSection
                    .padding(.bottom, 24)

                // Divider
                Rectangle()
                    .fill(Color.textTertiary.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 24)

                // Notes section (if present)
                if let notes = milestone.notes, !notes.isEmpty {
                    notesSection(notes)
                        .padding(.top, 24)
                }

                // Actions
                actionsSection
                    .padding(.top, 32)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .presentationDetents(hasLongNotes ? [.medium, .large] : [.medium])
        .presentationDragIndicator(.visible)
        .background(Color.bgPrimary)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: milestone.iconName ?? "hexagon.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(categoryColor)
            }

            // Name - allow full display, no truncation
            Text(milestone.name)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            // Category
            if let category = milestone.category {
                Text(category.displayName)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }

            // Status badge
            statusBadge
        }
    }

    private var statusBadge: some View {
        let status = milestone.status(currentWeek: user.currentWeekNumber)

        return Group {
            switch status {
            case .thisWeek:
                statusPill(text: "This Week", color: Color.fromHex("#16A34A"))

            case .overdue:
                statusPill(text: "Overdue", color: Color.fromHex("#DC2626"))

            case .completed:
                statusPill(text: "Completed", color: Color.fromHex("#16A34A"))

            case .upcoming:
                EmptyView()
            }
        }
        .padding(.top, 4)
    }

    private func statusPill(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: 0) {
            statBlock(
                value: "\(milestone.weeksRemaining(from: user.currentWeekNumber))",
                label: "weeks"
            )
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(Color.textTertiary.opacity(0.3))
                .frame(width: 1, height: 40)

            statBlock(
                value: "\(milestone.targetAge(birthYear: user.birthYear))",
                label: "age"
            )
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(Color.textTertiary.opacity(0.3))
                .frame(width: 1, height: 40)

            statBlock(
                value: targetDateString,
                label: "target"
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .background(Color.bgSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Notes Section

    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTES")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.textTertiary)
                .tracking(1)

            Text(notes)
                .font(.body)
                .foregroundStyle(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.bgSecondary.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Complete button (only if not completed)
            if !milestone.isCompleted {
                Button {
                    HapticService.shared.medium()
                    onComplete?()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                        Text("Mark Complete")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            // Edit button
            Button {
                HapticService.shared.light()
                onEdit?()
            } label: {
                Text("Edit Horizon")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.bgSecondary)
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private var categoryColor: Color {
        Color.fromHex(milestone.displayColorHex)
    }

    private var targetDateString: String {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .weekOfYear, value: milestone.targetWeekNumber, to: user.birthDate) else {
            return "—"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("With Notes") {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    let milestone = Milestone(name: "Ship Finite to App Store", targetWeekNumber: 1625, category: .growth)
    milestone.notes = "Shipping this app to App Store and beta testing with friends. This will be the culmination of weeks of focused work. Need to finalize the onboarding flow, fix remaining bugs, and prepare marketing materials."

    return MilestoneDetailSheet(
        milestone: milestone,
        user: user,
        onEdit: { print("Edit") },
        onComplete: { print("Complete") }
    )
}

#Preview("Short") {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    let milestone = Milestone(name: "Run a Marathon", targetWeekNumber: 1600, category: .health)

    return MilestoneDetailSheet(
        milestone: milestone,
        user: user,
        onEdit: { print("Edit") },
        onComplete: { print("Complete") }
    )
}
