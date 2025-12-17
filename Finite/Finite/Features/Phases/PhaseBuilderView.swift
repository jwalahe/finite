//
//  PhaseBuilderView.swift
//  Finite
//
//  Full-screen modal for creating life phases
//  CRAFT_SPEC: Modal present 0.3s, year wheel scroll with 0.15 bounce
//

import SwiftUI
import SwiftData

struct PhaseBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let user: User
    let existingPhases: [LifePhase]
    let onPhaseAdded: (LifePhase) -> Void

    @State private var phaseName: String = ""
    @State private var startYear: Int
    @State private var endYear: Int
    @State private var selectedRating: Int = 3
    @State private var selectedColorHex: String

    @FocusState private var isNameFieldFocused: Bool

    init(user: User, existingPhases: [LifePhase], onPhaseAdded: @escaping (LifePhase) -> Void) {
        self.user = user
        self.existingPhases = existingPhases
        self.onPhaseAdded = onPhaseAdded

        // Initialize with reasonable defaults
        let birthYear = user.birthYear
        let currentYear = user.currentYear
        _startYear = State(initialValue: birthYear)
        _endYear = State(initialValue: min(birthYear + 5, currentYear))
        _selectedColorHex = State(initialValue: PhaseColorService.shared.nextAvailableColorHex(existingPhases: existingPhases))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Grid Preview
                    PhaseGridPreview(
                        user: user,
                        existingPhases: existingPhases,
                        previewStartYear: startYear,
                        previewEndYear: endYear,
                        previewColorHex: selectedColorHex
                    )
                    .frame(height: 120)
                    .padding(.horizontal, 24)

                    Divider()
                        .padding(.horizontal, 24)

                    // Phase Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chapter name")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)

                        TextField("College, First Job, etc.", text: $phaseName)
                            .font(.body)
                            .padding(12)
                            .background(Color.bgSecondary)
                            .cornerRadius(8)
                            .focused($isNameFieldFocused)
                    }
                    .padding(.horizontal, 24)

                    // Year Wheel Pickers
                    YearWheelPicker(
                        startYear: $startYear,
                        endYear: $endYear,
                        minYear: user.birthYear,
                        maxYear: user.currentYear
                    )
                    .padding(.horizontal, 24)

                    // Optional Rating
                    VStack(spacing: 12) {
                        Text("How was it overall?")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)

                        PhaseRatingPicker(selectedRating: $selectedRating)
                    }
                    .padding(.horizontal, 24)

                    // Color Picker (optional, shows auto-assigned)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)

                        PhaseColorPicker(
                            selectedHex: $selectedColorHex,
                            existingPhases: existingPhases
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 32)

                    // Add Chapter Button
                    Button {
                        addPhase()
                    } label: {
                        Text("Add Chapter")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.bgPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canAddPhase ? Color.textPrimary : Color.textTertiary)
                            .cornerRadius(12)
                    }
                    .disabled(!canAddPhase)
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .background(Color.bgPrimary)
            .navigationTitle("Add Chapter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticService.shared.light()
                        dismiss()
                    }
                }
            }
        }
    }

    private var canAddPhase: Bool {
        !phaseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addPhase() {
        guard canAddPhase else { return }

        HapticService.shared.medium()

        let trimmedName = phaseName.trimmingCharacters(in: .whitespacesAndNewlines)
        let newPhase = LifePhase(
            name: trimmedName,
            startYear: startYear,
            endYear: endYear
        )
        newPhase.defaultRating = selectedRating
        newPhase.colorHex = selectedColorHex
        newPhase.sortOrder = existingPhases.count

        modelContext.insert(newPhase)

        onPhaseAdded(newPhase)
        dismiss()
    }
}

// MARK: - Phase Rating Picker

struct PhaseRatingPicker: View {
    @Binding var selectedRating: Int

    var body: some View {
        HStack(spacing: 16) {
            ForEach(1...5, id: \.self) { rating in
                Button {
                    HapticService.shared.selection()
                    selectedRating = rating
                } label: {
                    Circle()
                        .fill(selectedRating == rating ? Color.ratingColor(for: rating) : Color.clear)
                        .stroke(Color.ratingColor(for: rating), lineWidth: 2)
                        .frame(width: 32, height: 32)
                        .overlay {
                            if selectedRating == rating {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.white)
                            }
                        }
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }

        // Rating labels
        HStack(spacing: 0) {
            Text("Awful")
                .font(.caption2)
                .foregroundStyle(Color.textTertiary)
            Spacer()
            Text("Great")
                .font(.caption2)
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Phase Color Picker

struct PhaseColorPicker: View {
    @Binding var selectedHex: String
    let existingPhases: [LifePhase]

    private let colors = Color.phaseColorPalette

    var body: some View {
        HStack(spacing: 12) {
            ForEach(colors, id: \.hex) { item in
                let isUsed = existingPhases.contains { $0.colorHex == item.hex }
                let isSelected = selectedHex == item.hex

                Button {
                    HapticService.shared.light()
                    selectedHex = item.hex
                } label: {
                    Circle()
                        .fill(item.color)
                        .frame(width: 28, height: 28)
                        .overlay {
                            if isSelected {
                                Circle()
                                    .stroke(Color.textPrimary, lineWidth: 2)
                                    .frame(width: 36, height: 36)
                            }
                        }
                        .opacity(isUsed && !isSelected ? 0.4 : 1.0)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}

// MARK: - Phase Grid Preview (simplified mini grid)

struct PhaseGridPreview: View {
    let user: User
    let existingPhases: [LifePhase]
    let previewStartYear: Int
    let previewEndYear: Int
    let previewColorHex: String

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

        // Check if this year is in the preview range (only up to current year)
        if year >= previewStartYear && year <= min(previewEndYear, currentYear) {
            return Color.fromHex(previewColorHex)
        }

        // Check existing phases (only up to current year)
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, LifePhase.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    return PhaseBuilderView(user: user, existingPhases: []) { _ in }
        .modelContainer(container)
}
