//
//  MilestoneContextBar.swift
//  Finite
//
//  Footer bar for Horizons view showing next milestone or empty state
//  Tappable to view/edit milestone details
//

import SwiftUI

struct MilestoneContextBar: View {
    let milestone: Milestone?
    let currentWeek: Int
    let user: User
    let onTap: (() -> Void)?
    let onAddTap: (() -> Void)?

    var body: some View {
        if let milestone = milestone {
            // Show next milestone info
            milestoneRow(milestone)
        } else {
            // Empty state: No milestones
            emptyStateRow
        }
    }

    // MARK: - Milestone Row

    private func milestoneRow(_ milestone: Milestone) -> some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 12) {
                // Milestone icon
                Image(systemName: milestone.iconName ?? "hexagon.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(categoryColor(for: milestone))

                // Milestone info
                VStack(alignment: .leading, spacing: 2) {
                    Text(milestone.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        // Age
                        Text("Age \(milestone.targetAge(birthYear: user.birthYear))")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)

                        // Category
                        if let category = milestone.category {
                            Text("·")
                                .foregroundStyle(Color.textTertiary)
                            Text(category.displayName)
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }

                Spacer()

                // Weeks remaining
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(milestone.weeksRemaining(from: currentWeek))")
                        .font(.title3.weight(.semibold).monospacedDigit())
                        .foregroundStyle(Color.textPrimary)
                    Text("weeks")
                        .font(.caption2)
                        .foregroundStyle(Color.textTertiary)
                }

                // Add more button
                Button(action: { onAddTap?() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bgSecondary)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyStateRow: some View {
        Button(action: { onAddTap?() }) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.textSecondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Set your first horizon")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                    Text("Pin a goal to your future")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .foregroundStyle(Color.textTertiary)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func categoryColor(for milestone: Milestone) -> Color {
        Color.fromHex(milestone.displayColorHex)
    }
}

// MARK: - Preview

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    let milestone = Milestone(name: "Launch Startup", targetWeekNumber: 1625, category: .work)

    return VStack(spacing: 24) {
        Text("With Milestone")
            .font(.caption)
            .foregroundStyle(.secondary)

        MilestoneContextBar(
            milestone: milestone,
            currentWeek: 1560,
            user: user,
            onTap: { print("View milestone") },
            onAddTap: { print("Add milestone") }
        )
        .padding(.horizontal, 24)

        Text("Empty State")
            .font(.caption)
            .foregroundStyle(.secondary)

        MilestoneContextBar(
            milestone: nil,
            currentWeek: 1560,
            user: user,
            onTap: nil,
            onAddTap: { print("Add first milestone") }
        )
        .padding(.horizontal, 24)
    }
    .padding(.vertical, 32)
    .background(Color.bgPrimary)
}
