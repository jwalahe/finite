//
//  PhaseEditView.swift
//  Finite
//
//  Wrapper that presents PhaseFormView in edit mode
//  Now uses the same polished form as Add Chapter
//

import SwiftUI
import SwiftData

struct PhaseEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allPhases: [LifePhase]

    let user: User
    let phase: LifePhase

    var body: some View {
        PhaseFormView(
            mode: .edit(phase),
            user: user,
            existingPhases: allPhases,
            onSave: { _ in
                // SwiftData handles updates automatically
            },
            onDelete: {
                modelContext.delete(phase)
            }
        )
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, LifePhase.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    let phase = LifePhase(name: "College", startYear: 2012, endYear: 2016, colorHex: "#6366F1")
    phase.defaultRating = 4
    container.mainContext.insert(phase)

    return NavigationStack {
        PhaseEditView(user: user, phase: phase)
    }
    .modelContainer(container)
}
