//
//  PhaseBuilderView.swift
//  Finite
//
//  Wrapper that presents PhaseFormView in add mode
//  CRAFT_SPEC: Modal present 0.3s, year wheel scroll with 0.15 bounce
//

import SwiftUI
import SwiftData

struct PhaseBuilderView: View {
    let user: User
    let existingPhases: [LifePhase]
    let onPhaseAdded: (LifePhase) -> Void

    var body: some View {
        PhaseFormView(
            mode: .add,
            user: user,
            existingPhases: existingPhases,
            onSave: onPhaseAdded
        )
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
