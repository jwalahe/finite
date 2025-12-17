//
//  PhaseEditView.swift
//  Finite
//
//  Edit an existing life phase (name, years, rating, color)
//

import SwiftUI
import SwiftData

struct PhaseEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allPhases: [LifePhase]

    let user: User
    @Bindable var phase: LifePhase

    @State private var phaseName: String
    @State private var startYear: Int
    @State private var endYear: Int
    @State private var selectedRating: Int
    @State private var selectedColorHex: String

    @State private var showDeleteConfirmation: Bool = false

    init(user: User, phase: LifePhase) {
        self.user = user
        self.phase = phase
        _phaseName = State(initialValue: phase.name)
        _startYear = State(initialValue: phase.startYear)
        _endYear = State(initialValue: phase.endYear)
        _selectedRating = State(initialValue: phase.defaultRating ?? 3)
        _selectedColorHex = State(initialValue: phase.colorHex)
    }

    var body: some View {
        Form {
            // Name
            Section("Name") {
                TextField("Chapter name", text: $phaseName)
            }

            // Years
            Section("Years") {
                YearWheelPicker(
                    startYear: $startYear,
                    endYear: $endYear,
                    minYear: user.birthYear,
                    maxYear: user.currentYear
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            // Rating
            Section("Overall Rating") {
                PhaseRatingPicker(selectedRating: $selectedRating)
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            }

            // Color
            Section("Color") {
                PhaseColorPicker(
                    selectedHex: $selectedColorHex,
                    existingPhases: allPhases.filter { $0.id != phase.id }
                )
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            }

            // Delete
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete Chapter")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Edit Chapter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(!canSave)
            }
        }
        .confirmationDialog(
            "Delete \"\(phase.name)\"?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deletePhase()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove this chapter from your life grid. This action cannot be undone.")
        }
    }

    private var canSave: Bool {
        !phaseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveChanges() {
        HapticService.shared.medium()

        phase.name = phaseName.trimmingCharacters(in: .whitespacesAndNewlines)
        phase.startYear = startYear
        phase.endYear = endYear
        phase.defaultRating = selectedRating
        phase.colorHex = selectedColorHex

        dismiss()
    }

    private func deletePhase() {
        HapticService.shared.medium()
        modelContext.delete(phase)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, LifePhase.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    let phase = LifePhase(name: "College", startYear: 2012, endYear: 2016)
    phase.colorHex = "#4F46E5"
    container.mainContext.insert(phase)

    return NavigationStack {
        PhaseEditView(user: user, phase: phase)
    }
    .modelContainer(container)
}
