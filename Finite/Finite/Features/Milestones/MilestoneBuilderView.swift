//
//  MilestoneBuilderView.swift
//  Finite
//
//  Sheet for creating and editing milestones
//  Minimal friction design with live grid preview
//

import SwiftUI
import SwiftData

struct MilestoneBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let user: User
    let mode: Mode
    let onSave: ((Milestone) -> Void)?
    let onDelete: (() -> Void)?

    enum Mode {
        case add(preselectedWeek: Int? = nil)
        case edit(Milestone)
    }

    // Form state
    @State private var name: String = ""
    @State private var targetWeekNumber: Int
    @State private var category: WeekCategory?
    @State private var notes: String = ""

    // UI state
    @State private var showDeleteConfirm = false

    init(user: User, mode: Mode, onSave: ((Milestone) -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.user = user
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete

        // Initialize state based on mode
        switch mode {
        case .add(let preselectedWeek):
            // Use preselected week or default to 1 year from now
            _targetWeekNumber = State(initialValue: preselectedWeek ?? (user.currentWeekNumber + 52))
        case .edit(let milestone):
            _name = State(initialValue: milestone.name)
            _targetWeekNumber = State(initialValue: milestone.targetWeekNumber)
            _category = State(initialValue: milestone.category)
            _notes = State(initialValue: milestone.notes ?? "")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Mini grid preview (PRD: shows where milestone will land)
                    MilestoneGridPreview(
                        user: user,
                        targetWeekNumber: targetWeekNumber,
                        categoryColor: category.map { Color.fromHex($0.colorHex) }
                    )

                    // Name input
                    nameSection

                    // Stats display
                    statsSection

                    // Target week picker
                    targetWeekSection

                    // Category picker
                    categorySection

                    // Notes input
                    notesSection

                    // Delete button (edit mode only)
                    if case .edit = mode {
                        deleteSection
                    }
                }
                .padding(24)
            }
            .background(Color.bgPrimary)
            .navigationTitle(isEditMode ? "Edit Horizon" : "Add Horizon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditMode ? "Save" : "Set Horizon") {
                        saveAndDismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .confirmationDialog("Delete Horizon?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                onDelete?()
                dismiss()
            }
        } message: {
            Text("This cannot be undone.")
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WHAT'S YOUR HORIZON?")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            TextField("Launch my startup", text: $name)
                .font(.title3)
                .padding(12)
                .background(Color.bgSecondary)
                .cornerRadius(8)
        }
    }

    private var statsSection: some View {
        HStack(spacing: 24) {
            statBlock(value: "\(weeksRemaining)", label: "weeks")
            statBlock(value: "\(targetAge)", label: "age")
            statBlock(value: targetDateString, label: "target")
        }
        .padding(16)
        .background(Color.bgSecondary)
        .cornerRadius(12)
    }

    private var targetWeekSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TARGET")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            MilestoneWeekPicker(
                user: user,
                selectedWeekNumber: $targetWeekNumber
            )
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CATEGORY (optional)")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            MilestoneCategoryPicker(selection: $category)
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTES (optional)")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            TextField("What does achieving this look like?", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .padding(12)
                .background(Color.bgSecondary)
                .cornerRadius(8)
        }
    }

    private var deleteSection: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Horizon")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.bordered)
        .tint(.red)
    }

    // MARK: - Stat Block

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.semibold).monospacedDigit())
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Computed

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var weeksRemaining: Int {
        max(0, targetWeekNumber - user.currentWeekNumber)
    }

    private var targetAge: Int {
        targetWeekNumber / 52
    }

    private var targetDateString: String {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .weekOfYear, value: targetWeekNumber, to: user.birthDate) else {
            return "—"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: - Actions

    private func saveAndDismiss() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        switch mode {
        case .add:
            let milestone = Milestone(
                name: trimmedName,
                targetWeekNumber: targetWeekNumber,
                category: category
            )
            milestone.notes = notes.isEmpty ? nil : notes
            modelContext.insert(milestone)
            onSave?(milestone)

            // Death Voice: Trigger for milestone creation
            triggerDeathVoiceForCreation(milestoneName: trimmedName)

        case .edit(let existingMilestone):
            let oldWeekNumber = existingMilestone.targetWeekNumber
            existingMilestone.name = trimmedName
            existingMilestone.targetWeekNumber = targetWeekNumber
            existingMilestone.category = category
            existingMilestone.notes = notes.isEmpty ? nil : notes
            existingMilestone.updatedAt = Date()
            onSave?(existingMilestone)

            // Death Voice: Trigger for milestone moved (if week changed significantly)
            let weekDifference = targetWeekNumber - oldWeekNumber
            if abs(weekDifference) >= 4 {
                triggerDeathVoiceForMove(milestoneName: trimmedName, weekDifference: weekDifference)
            }
        }

        HapticService.shared.success()
        dismiss()
    }

    /// Death Voice trigger for milestone creation
    private func triggerDeathVoiceForCreation(milestoneName: String) {
        let controller = DeathVoiceController.shared

        // Get current milestone count (approximate - will be updated after save)
        let milestoneCount = (try? modelContext.fetchCount(FetchDescriptor<Milestone>())) ?? 1

        if milestoneCount == 1 {
            // First milestone ever
            controller.onEvent(DeathTrigger(
                type: .firstMilestoneEver,
                context: DeathTrigger.Context(userName: "Traveler", milestoneName: milestoneName)
            ))
        } else if controller.shouldSpeakForMilestoneCount(milestoneCount) {
            // Subsequent milestone (sparse)
            controller.onEvent(DeathTrigger(
                type: .milestoneCreated,
                context: DeathTrigger.Context(userName: "Traveler", milestoneCount: milestoneCount)
            ))
        }
    }

    /// Death Voice trigger for milestone moved
    private func triggerDeathVoiceForMove(milestoneName: String, weekDifference: Int) {
        let controller = DeathVoiceController.shared
        controller.onEvent(DeathTrigger(
            type: .milestoneMoved,
            context: DeathTrigger.Context(
                userName: "Traveler",
                milestoneName: milestoneName,
                weeksAway: weekDifference > 0 ? weekDifference : nil
            )
        ))
    }
}

// MARK: - Week Picker

struct MilestoneWeekPicker: View {
    let user: User
    @Binding var selectedWeekNumber: Int

    // Computed date from week number
    private var selectedDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: selectedWeekNumber, to: user.birthDate) ?? Date()
    }

    // Minimum date: next week
    private var minimumDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: user.currentWeekNumber + 1, to: user.birthDate) ?? Date()
    }

    // Maximum date: end of expected life
    private var maximumDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: user.totalWeeks, to: user.birthDate) ?? Date()
    }

    var body: some View {
        HStack(spacing: 0) {
            // Date-based picker
            DatePicker(
                "",
                selection: Binding(
                    get: { selectedDate },
                    set: { newDate in
                        selectedWeekNumber = weekNumber(for: newDate)
                    }
                ),
                in: minimumDate...maximumDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()

            Spacer()

            // Week number display
            VStack(alignment: .trailing, spacing: 2) {
                Text("Week \(selectedWeekNumber)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color.textSecondary)
                Text("Age \(targetAge)")
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(12)
        .background(Color.bgSecondary)
        .cornerRadius(8)
    }

    private func weekNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: user.birthDate, to: date)
        let days = components.day ?? 0
        return max(user.currentWeekNumber + 1, (days / 7) + 1)
    }

    private var targetAge: Int {
        selectedWeekNumber / 52
    }
}

// MARK: - Category Picker

struct MilestoneCategoryPicker: View {
    @Binding var selection: WeekCategory?

    // Split categories into 2 rows of 3
    private var topRowCategories: [WeekCategory] {
        Array(WeekCategory.allCases.prefix(3))
    }

    private var bottomRowCategories: [WeekCategory] {
        Array(WeekCategory.allCases.suffix(3))
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(topRowCategories, id: \.self) { category in
                    categoryButton(category)
                }
            }
            HStack(spacing: 8) {
                ForEach(bottomRowCategories, id: \.self) { category in
                    categoryButton(category)
                }
            }
        }
    }

    private func categoryButton(_ category: WeekCategory) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.2)) {
                if selection == category {
                    selection = nil  // Deselect
                } else {
                    selection = category
                }
            }
            HapticService.shared.selection()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: category.iconName)
                    .font(.system(size: 18))
                Text(category.displayName)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selection == category ? Color.fromHex(category.colorHex).opacity(0.2) : Color.bgSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(selection == category ? Color.fromHex(category.colorHex) : Color.clear, lineWidth: 2)
            )
            .foregroundStyle(selection == category ? Color.fromHex(category.colorHex) : Color.textSecondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Add Mode") {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    return MilestoneBuilderView(user: user, mode: .add())
}

#Preview("Edit Mode") {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    let milestone = Milestone(name: "Launch Startup", targetWeekNumber: 1625, category: .work)
    milestone.notes = "MVP ready, first paying customer"
    return MilestoneBuilderView(user: user, mode: .edit(milestone))
}

// MARK: - Grid Preview Component

/// Mini grid showing current week, lived weeks, and target milestone position
/// PRD: Provides spatial context for where the milestone lands in your life
struct MilestoneGridPreview: View {
    let user: User
    let targetWeekNumber: Int
    let categoryColor: Color?

    private let weeksPerRow: Int = 52
    private let cellSize: CGFloat = 4
    private let spacing: CGFloat = 1
    private let previewHeight: CGFloat = 60

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TIMELINE PREVIEW")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            Canvas { context, size in
                let totalWeeks = user.totalWeeks
                let currentWeek = user.currentWeekNumber

                // Calculate how many rows we can show
                let rowHeight = cellSize + spacing
                let visibleRows = Int(size.height / rowHeight)

                // Center the preview around the target week
                let targetRow = (targetWeekNumber - 1) / weeksPerRow
                let startRow = max(0, targetRow - visibleRows / 2)
                let endRow = min(totalWeeks / weeksPerRow, startRow + visibleRows)

                for row in startRow..<endRow {
                    for col in 0..<weeksPerRow {
                        let weekNumber = row * weeksPerRow + col + 1
                        guard weekNumber <= totalWeeks else { continue }

                        let x = CGFloat(col) * (cellSize + spacing)
                        let y = CGFloat(row - startRow) * rowHeight
                        let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)

                        if weekNumber == targetWeekNumber {
                            // Target week - hexagon with category color
                            let hexPath = hexagonPath(in: rect)
                            let color = categoryColor ?? Color.textSecondary
                            context.fill(hexPath, with: .color(color))
                        } else if weekNumber == currentWeek {
                            // Current week - bright marker
                            let circle = Path(ellipseIn: rect)
                            context.fill(circle, with: .color(Color.textPrimary))
                        } else if weekNumber < currentWeek {
                            // Past weeks - dimmer
                            let circle = Path(ellipseIn: rect)
                            context.fill(circle, with: .color(Color.textTertiary.opacity(0.3)))
                        } else {
                            // Future weeks
                            let circle = Path(ellipseIn: rect)
                            context.fill(circle, with: .color(Color.textTertiary.opacity(0.15)))
                        }
                    }
                }
            }
            .frame(height: previewHeight)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(12)
        .background(Color.bgSecondary)
        .cornerRadius(12)
    }

    private func hexagonPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
