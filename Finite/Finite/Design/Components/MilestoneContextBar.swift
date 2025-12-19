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
    let totalCount: Int  // Total upcoming milestones count
    let currentWeek: Int
    let user: User
    let onTap: (() -> Void)?  // Tap main area → opens List sheet
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
                    // Name with weeks inline
                    HStack(spacing: 6) {
                        Text(milestone.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textPrimary)
                            .lineLimit(1)

                        Text("•")
                            .foregroundStyle(Color.textTertiary)

                        Text("\(milestone.weeksRemaining(from: currentWeek)) weeks")
                            .font(.subheadline.weight(.medium).monospacedDigit())
                            .foregroundStyle(categoryColor(for: milestone))
                    }

                    // Details row
                    HStack(spacing: 6) {
                        Text("Age \(milestone.targetAge(birthYear: user.birthYear))")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)

                        if let category = milestone.category {
                            Text("•")
                                .foregroundStyle(Color.textTertiary)
                            Text(category.displayName)
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        }

                        // Horizons count (PRD: signals there are more to see)
                        if totalCount > 1 {
                            Text("•")
                                .foregroundStyle(Color.textTertiary)
                            Text("\(totalCount) horizons")
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }

                Spacer()

                // Add button (matching PhaseContextBar style)
                if onAddTap != nil {
                    Button(action: { onAddTap?() }) {
                        Text("Add")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color.bgTertiary)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.bgSecondary.opacity(0.8))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Empty State

    private var emptyStateRow: some View {
        Button(action: { onAddTap?() }) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)

                Text("Add a horizon for your future")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textTertiary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .foregroundStyle(Color.textTertiary.opacity(0.5))
            )
        }
        .buttonStyle(ScaleButtonStyle())
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
        Text("With Milestone (4 total)")
            .font(.caption)
            .foregroundStyle(.secondary)

        MilestoneContextBar(
            milestone: milestone,
            totalCount: 4,
            currentWeek: 1560,
            user: user,
            onTap: { print("Open list sheet") },
            onAddTap: { print("Add milestone") }
        )
        .padding(.horizontal, 24)

        Text("Single Milestone")
            .font(.caption)
            .foregroundStyle(.secondary)

        MilestoneContextBar(
            milestone: milestone,
            totalCount: 1,
            currentWeek: 1560,
            user: user,
            onTap: { print("Open list sheet") },
            onAddTap: { print("Add milestone") }
        )
        .padding(.horizontal, 24)

        Text("Empty State")
            .font(.caption)
            .foregroundStyle(.secondary)

        MilestoneContextBar(
            milestone: nil,
            totalCount: 0,
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
