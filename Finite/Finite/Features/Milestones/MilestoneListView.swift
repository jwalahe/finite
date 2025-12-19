//
//  MilestoneListView.swift
//  Finite
//
//  Full list view for managing all milestones
//  Shows upcoming, overdue, and completed sections
//  PRD: Context bar tap → List sheet with .medium/.large detents
//

import SwiftUI
import SwiftData

struct MilestoneListView: View {
    let user: User
    let onSelectMilestone: ((Milestone) -> Void)?  // Tap row → dismiss, open detail

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Milestone.targetWeekNumber) private var allMilestones: [Milestone]

    @State private var showMilestoneBuilder: Bool = false

    init(user: User, onSelectMilestone: ((Milestone) -> Void)? = nil) {
        self.user = user
        self.onSelectMilestone = onSelectMilestone
    }

    // PRD: Separate upcoming (future) from overdue (past target, not completed)
    private var upcomingMilestones: [Milestone] {
        allMilestones.filter { !$0.isCompleted && $0.targetWeekNumber >= user.currentWeekNumber }
    }

    private var overdueMilestones: [Milestone] {
        allMilestones.filter { !$0.isCompleted && $0.targetWeekNumber < user.currentWeekNumber }
    }

    private var completedMilestones: [Milestone] {
        allMilestones.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            List {
                // Upcoming section
                if !upcomingMilestones.isEmpty {
                    Section("Upcoming") {
                        ForEach(upcomingMilestones) { milestone in
                            MilestoneListRow(milestone: milestone, user: user, status: .upcoming)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    handleRowTap(milestone)
                                }
                        }
                        .onDelete { indexSet in
                            deleteFromList(upcomingMilestones, at: indexSet)
                        }
                    }
                }

                // Overdue section (PRD: red tint, negative weeks)
                if !overdueMilestones.isEmpty {
                    Section("Overdue") {
                        ForEach(overdueMilestones) { milestone in
                            MilestoneListRow(milestone: milestone, user: user, status: .overdue)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    handleRowTap(milestone)
                                }
                        }
                        .onDelete { indexSet in
                            deleteFromList(overdueMilestones, at: indexSet)
                        }
                    }
                }

                // Completed section
                if !completedMilestones.isEmpty {
                    Section("Completed") {
                        ForEach(completedMilestones) { milestone in
                            MilestoneListRow(milestone: milestone, user: user, status: .completed)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    handleRowTap(milestone)
                                }
                        }
                        .onDelete { indexSet in
                            deleteFromList(completedMilestones, at: indexSet)
                        }
                    }
                }

                // Empty state
                if allMilestones.isEmpty {
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "hexagon")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.textTertiary)

                            Text("No Horizons Yet")
                                .font(.headline)
                                .foregroundStyle(Color.textPrimary)

                            Text("Pin life goals to future weeks\nand see exactly how many weeks until you get there.")
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)
                                .multilineTextAlignment(.center)

                            Button {
                                showMilestoneBuilder = true
                            } label: {
                                Text("Add Your First Horizon")
                                    .font(.subheadline.weight(.medium))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Your Horizons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showMilestoneBuilder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showMilestoneBuilder) {
            MilestoneBuilderView(user: user, mode: .add())
        }
    }

    private func handleRowTap(_ milestone: Milestone) {
        HapticService.shared.light()
        if let callback = onSelectMilestone {
            dismiss()
            // PRD: 0.3s delay before opening detail
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                callback(milestone)
            }
        }
    }

    private func deleteFromList(_ list: [Milestone], at offsets: IndexSet) {
        for index in offsets {
            let milestone = list[index]
            modelContext.delete(milestone)
        }
        HapticService.shared.medium()
    }
}

// MARK: - Milestone List Row

struct MilestoneListRow: View {
    let milestone: Milestone
    let user: User
    let status: RowStatus

    enum RowStatus {
        case upcoming
        case overdue
        case completed
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon with category color (red for overdue, muted for completed)
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)
                .frame(width: 32)

            // Name and details
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.name)
                    .font(.body)
                    .foregroundStyle(status == .completed ? Color.textSecondary : Color.textPrimary)
                    .strikethrough(status == .completed)

                detailText
            }

            Spacer()

            // Status indicator
            statusIndicator

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.vertical, 4)
        .listRowBackground(status == .overdue ? Color.red.opacity(0.08) : nil)
    }

    private var iconName: String {
        switch status {
        case .completed:
            return "checkmark.circle.fill"
        default:
            return milestone.iconName ?? "hexagon.fill"
        }
    }

    private var iconColor: Color {
        switch status {
        case .upcoming:
            return Color.fromHex(milestone.displayColorHex)
        case .overdue:
            return .red.opacity(0.8)
        case .completed:
            return Color.textTertiary
        }
    }

    @ViewBuilder
    private var detailText: some View {
        HStack(spacing: 8) {
            switch status {
            case .upcoming:
                Text("\(milestone.weeksRemaining(from: user.currentWeekNumber)) weeks")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)

                Text("•")
                    .foregroundStyle(Color.textTertiary)

                Text("Age \(milestone.targetAge(birthYear: user.birthYear))")
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)

                if let category = milestone.category {
                    Text("•")
                        .foregroundStyle(Color.textTertiary)
                    Text(category.displayName)
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                }

            case .overdue:
                // PRD: Show negative weeks "X weeks ago"
                let weeksOverdue = user.currentWeekNumber - milestone.targetWeekNumber
                Text("\(weeksOverdue) weeks ago")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.8))

                Text("•")
                    .foregroundStyle(Color.textTertiary)

                Text("Was due Age \(milestone.targetAge(birthYear: user.birthYear))")
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)

                if let category = milestone.category {
                    Text("•")
                        .foregroundStyle(Color.textTertiary)
                    Text(category.displayName)
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                }

            case .completed:
                if let completedAt = milestone.completedAt {
                    Text("Completed \(completedAt.formatted(.dateTime.month(.abbreviated).day().year()))")
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                }
            }
        }
    }

    @ViewBuilder
    private var statusIndicator: some View {
        switch status {
        case .upcoming:
            Text("\(milestone.weeksRemaining(from: user.currentWeekNumber))")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(Color.textSecondary)

        case .overdue:
            // Show exclamation badge for overdue
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)

        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Milestone.self, configurations: config)
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    // Add sample milestones
    let currentWeek = user.currentWeekNumber

    // Upcoming
    let m1 = Milestone(name: "Launch Startup", targetWeekNumber: currentWeek + 65, category: .work)
    let m2 = Milestone(name: "Run a Marathon", targetWeekNumber: currentWeek + 130, category: .health)

    // Overdue
    let m3 = Milestone(name: "Learn Piano", targetWeekNumber: currentWeek - 12, category: .growth)

    // Completed
    let m4 = Milestone(name: "Get Promoted", targetWeekNumber: currentWeek - 50, category: .work)
    m4.isCompleted = true
    m4.completedAt = Date()

    container.mainContext.insert(m1)
    container.mainContext.insert(m2)
    container.mainContext.insert(m3)
    container.mainContext.insert(m4)

    return MilestoneListView(user: user) { milestone in
        print("Selected: \(milestone.name)")
    }
    .modelContainer(container)
}
