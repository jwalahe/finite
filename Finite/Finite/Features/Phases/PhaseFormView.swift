//
//  PhaseFormView.swift
//  Finite
//
//  Unified form for adding and editing life phases
//  Philosophy: Same component for add and edit - consistency is trust
//

import SwiftUI
import SwiftData

enum PhaseFormMode {
    case add
    case edit(LifePhase)
}

struct PhaseFormView: View {
    let mode: PhaseFormMode
    let user: User
    let existingPhases: [LifePhase]
    let onSave: (LifePhase) -> Void
    let onDelete: (() -> Void)?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var startYear: Int
    @State private var endYear: Int
    @State private var rating: Int?
    @State private var selectedColor: PhaseColor
    @State private var showDeleteConfirmation = false

    @FocusState private var isNameFieldFocused: Bool

    // Computed properties
    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var navigationTitle: String {
        isEditMode ? "Edit Chapter" : "Add Chapter"
    }

    private var saveButtonTitle: String {
        isEditMode ? "Save Changes" : "Add Chapter"
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        startYear <= endYear &&
        startYear >= user.birthYear &&
        endYear <= user.currentYear
    }

    // Filter out the current phase from existing phases (for edit mode)
    private var otherPhases: [LifePhase] {
        if case .edit(let phase) = mode {
            return existingPhases.filter { $0.id != phase.id }
        }
        return existingPhases
    }

    // Initializer
    init(
        mode: PhaseFormMode,
        user: User,
        existingPhases: [LifePhase],
        onSave: @escaping (LifePhase) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.user = user
        self.existingPhases = existingPhases
        self.onSave = onSave
        self.onDelete = onDelete

        // Initialize state based on mode
        switch mode {
        case .add:
            _name = State(initialValue: "")
            _startYear = State(initialValue: user.birthYear)
            _endYear = State(initialValue: min(user.birthYear + 5, user.currentYear))
            _rating = State(initialValue: nil)
            _selectedColor = State(initialValue: .indigo)
        case .edit(let phase):
            _name = State(initialValue: phase.name)
            _startYear = State(initialValue: phase.startYear)
            _endYear = State(initialValue: phase.endYear)
            _rating = State(initialValue: phase.defaultRating)
            _selectedColor = State(initialValue: PhaseColor.from(hex: phase.colorHex) ?? .indigo)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Grid preview
                    PhaseGridPreviewNew(
                        user: user,
                        existingPhases: otherPhases,
                        previewStartYear: startYear,
                        previewEndYear: endYear,
                        previewColor: selectedColor.color
                    )
                    .frame(height: 100)
                    .padding(.horizontal, 24)

                    Divider()
                        .padding(.horizontal, 24)

                    // Chapter name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chapter name")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)

                        TextField("College, First Job, Travel Year...", text: $name)
                            .font(.body)
                            .padding(12)
                            .background(Color.bgSecondary)
                            .cornerRadius(8)
                            .focused($isNameFieldFocused)
                    }
                    .padding(.horizontal, 24)

                    // Year pickers
                    YearWheelPicker(
                        startYear: $startYear,
                        endYear: $endYear,
                        minYear: user.birthYear,
                        maxYear: user.currentYear
                    )
                    .padding(.horizontal, 24)

                    // Color picker (4x4 grid)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Chapter color")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)

                        PhaseColorGrid(selectedColor: $selectedColor)
                    }
                    .padding(.horizontal, 24)

                    // Rating (optional)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How was it overall? (optional)")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)

                        PhaseRatingGrid(rating: $rating)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 24)

                    // Primary action button
                    Button(action: savePhase) {
                        Text(saveButtonTitle)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(isValid ? Color.bgPrimary : Color.textTertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isValid ? Color.textPrimary : Color.bgTertiary)
                            .cornerRadius(12)
                    }
                    .disabled(!isValid)
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 24)

                    // Delete button (edit mode only)
                    if isEditMode, onDelete != nil {
                        Button(action: { showDeleteConfirmation = true }) {
                            Text("Delete Chapter")
                                .font(.body)
                                .foregroundStyle(Color.ratingAwful)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    } else {
                        Spacer(minLength: 24)
                    }
                }
            }
            .background(Color.bgPrimary)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticService.shared.light()
                        dismiss()
                    }
                }
            }
            .alert("Delete Chapter?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    HapticService.shared.success()
                    onDelete?()
                    dismiss()
                }
            } message: {
                Text("This will remove \"\(name)\" from your life chapters. This cannot be undone.")
            }
        }
    }

    private func savePhase() {
        guard isValid else { return }

        HapticService.shared.medium()

        switch mode {
        case .add:
            let newPhase = LifePhase(
                name: name.trimmingCharacters(in: .whitespaces),
                startYear: startYear,
                endYear: endYear,
                colorHex: selectedColor.rawValue
            )
            newPhase.defaultRating = rating
            newPhase.sortOrder = existingPhases.count
            modelContext.insert(newPhase)
            onSave(newPhase)

        case .edit(let phase):
            phase.name = name.trimmingCharacters(in: .whitespaces)
            phase.startYear = startYear
            phase.endYear = endYear
            phase.colorHex = selectedColor.rawValue
            phase.defaultRating = rating
            onSave(phase)
        }

        dismiss()
    }
}

// MARK: - Phase Color Grid (4x4)

struct PhaseColorGrid: View {
    @Binding var selectedColor: PhaseColor

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(PhaseColor.allCases, id: \.self) { color in
                ColorSwatch(
                    color: color,
                    isSelected: selectedColor == color
                ) {
                    withAnimation(.snappy(duration: 0.15)) {
                        selectedColor = color
                    }
                    HapticService.shared.light()
                }
            }
        }
    }
}

struct ColorSwatch: View {
    let color: PhaseColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 44, height: 44)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.snappy(duration: 0.15), value: isSelected)
    }
}

// MARK: - Phase Rating Grid (1-5 with optional deselect)

struct PhaseRatingGrid: View {
    @Binding var rating: Int?

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { value in
                    Button {
                        withAnimation(.snappy(duration: 0.15)) {
                            if rating == value {
                                rating = nil  // Deselect
                            } else {
                                rating = value
                            }
                        }
                        HapticService.shared.selection()
                    } label: {
                        Circle()
                            .fill(rating == value ? Color.ratingColor(for: value) : Color.bgTertiary)
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text("\(value)")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(rating == value ? .white : Color.textSecondary)
                            }
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(rating == value ? 1.1 : 1.0)
                    .animation(.snappy(duration: 0.15), value: rating)
                }
            }

            // Labels
            HStack {
                Text("Awful")
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary)
                Spacer()
                Text("Great")
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Phase Grid Preview (updated)

struct PhaseGridPreviewNew: View {
    let user: User
    let existingPhases: [LifePhase]
    let previewStartYear: Int
    let previewEndYear: Int
    let previewColor: Color

    private let rowHeight: CGFloat = 8
    private let spacing: CGFloat = 2

    var body: some View {
        GeometryReader { geo in
            let totalYears = user.lifeExpectancy
            let yearWidth = (geo.size.width - CGFloat(totalYears - 1) * spacing) / CGFloat(totalYears)

            HStack(spacing: spacing) {
                ForEach(0..<totalYears, id: \.self) { yearOffset in
                    let year = user.birthYear + yearOffset
                    let color = colorForYear(year)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: max(yearWidth, 2))
                }
            }
            .frame(height: rowHeight)
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }

    private func colorForYear(_ year: Int) -> Color {
        let currentYear = user.currentYear

        // Future years - always empty
        if year > currentYear {
            return Color.weekEmpty
        }

        // Check if this year is in the preview range
        if year >= previewStartYear && year <= min(previewEndYear, currentYear) {
            return previewColor
        }

        // Check existing phases
        for phase in existingPhases {
            if year >= phase.startYear && year <= min(phase.endYear, currentYear) {
                return Color.fromHex(phase.colorHex)
            }
        }

        // Past years without phase
        return Color.weekFilled.opacity(0.3)
    }
}

// MARK: - Preview

#Preview("Add Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, LifePhase.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    return PhaseFormView(
        mode: .add,
        user: user,
        existingPhases: [],
        onSave: { _ in }
    )
    .modelContainer(container)
}

#Preview("Edit Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, LifePhase.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    let phase = LifePhase(name: "College", startYear: 2012, endYear: 2016, colorHex: "#6366F1")
    phase.defaultRating = 4
    container.mainContext.insert(phase)

    return PhaseFormView(
        mode: .edit(phase),
        user: user,
        existingPhases: [phase],
        onSave: { _ in },
        onDelete: { }
    )
    .modelContainer(container)
}
