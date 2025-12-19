//
//  MilestoneDetailSheet.swift
//  Finite
//
//  Detail sheet for viewing and acting on a milestone
//  Shows stats, allows completion and editing
//

import SwiftUI
import SwiftData

struct MilestoneDetailSheet: View {
    let milestone: Milestone
    let user: User
    let onEdit: (() -> Void)?
    let onComplete: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            // Header
            headerSection

            // Stats
            statsSection

            // Notes
            if let notes = milestone.notes, !notes.isEmpty {
                notesSection(notes)
            }

            Spacer()

            // Actions
            actionsSection
        }
        .padding(24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: milestone.iconName ?? "hexagon.fill")
                .font(.system(size: 40))
                .foregroundStyle(categoryColor)

            Text(milestone.name)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textPrimary)

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
                Text("This Week!")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.fromHex("#16A34A")))

            case .overdue:
                Text("Overdue")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.fromHex("#DC2626")))

            case .completed:
                Text("Completed")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.fromHex("#16A34A")))

            case .upcoming:
                EmptyView()
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 32) {
            statBlock(
                value: "\(milestone.weeksRemaining(from: user.currentWeekNumber))",
                label: "weeks"
            )
            statBlock(
                value: "\(milestone.targetAge(birthYear: user.birthYear))",
                label: "age"
            )
            statBlock(
                value: targetDateString,
                label: "target"
            )
        }
    }

    private func notesSection(_ notes: String) -> some View {
        Text(notes)
            .font(.body)
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.bgSecondary)
            .cornerRadius(8)
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Complete button (only if not completed)
            if !milestone.isCompleted {
                Button {
                    onComplete?()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Mark Complete")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
            }

            // Edit button
            Button {
                onEdit?()
            } label: {
                Text("Edit Horizon")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Helpers

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.weight(.semibold).monospacedDigit())
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
    }

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

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    let milestone = Milestone(name: "Launch Startup", targetWeekNumber: 1625, category: .work)
    milestone.notes = "MVP ready, first paying customer. This will be the culmination of 2 years of hard work."

    return MilestoneDetailSheet(
        milestone: milestone,
        user: user,
        onEdit: { print("Edit") },
        onComplete: { print("Complete") }
    )
}
