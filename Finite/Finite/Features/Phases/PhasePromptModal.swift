//
//  PhasePromptModal.swift
//  Finite
//
//  Modal shown after Reveal: "Your past is empty. Add life chapters?"
//  CRAFT_SPEC: Present 1s after Reveal completes, slide up 0.3s with slight bounce
//

import SwiftUI
import SwiftData

struct PhasePromptModal: View {
    @Environment(\.modelContext) private var modelContext

    let user: User
    let onAddChapters: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Main content
            VStack(spacing: 12) {
                Text("Your past is empty.")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                Text("Add life chapters?")
                    .font(.body)
                    .foregroundStyle(Color.textSecondary)
            }
            .multilineTextAlignment(.center)

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button {
                    HapticService.shared.medium()
                    markPromptSeen()
                    onAddChapters()
                } label: {
                    Text("Yes, add chapters")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.bgPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.textPrimary)
                        .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())

                Button {
                    HapticService.shared.light()
                    markPromptSeen()
                    onSkip()
                } label: {
                    Text("Skip for now")
                        .font(.body)
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgPrimary)
        .cornerRadius(16)
        .padding(.horizontal, 24)
        .padding(.vertical, 48)
    }

    private func markPromptSeen() {
        user.hasSeenPhasePrompt = true
    }
}

// MARK: - Phase Prompt Overlay (for use in GridView)

struct PhasePromptOverlay: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var phases: [LifePhase]

    let user: User
    @Binding var isPresented: Bool
    @Binding var showPhaseBuilder: Bool

    var body: some View {
        ZStack {
            // Dim overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss on background tap
                    HapticService.shared.light()
                    dismissPrompt()
                }

            // Modal
            PhasePromptModal(
                user: user,
                onAddChapters: {
                    isPresented = false
                    // Small delay before showing builder
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showPhaseBuilder = true
                    }
                },
                onSkip: {
                    dismissPrompt()
                }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func dismissPrompt() {
        user.hasSeenPhasePrompt = true
        withAnimation(.smooth(duration: 0.25)) {
            isPresented = false
        }
    }
}

// MARK: - Phase Flow Coordinator

/// Manages the full phase creation flow: Prompt → Builder → Confirmation → (repeat or done)
struct PhaseFlowCoordinator: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var phases: [LifePhase]

    let user: User
    @Binding var isPresented: Bool

    @State private var currentScreen: PhaseFlowScreen = .builder
    @State private var lastAddedPhase: LifePhase?

    enum PhaseFlowScreen {
        case builder
        case confirmation
    }

    var body: some View {
        switch currentScreen {
        case .builder:
            PhaseBuilderView(
                user: user,
                existingPhases: phases
            ) { newPhase in
                lastAddedPhase = newPhase
                currentScreen = .confirmation
            }

        case .confirmation:
            if let phase = lastAddedPhase {
                PhaseConfirmationView(
                    user: user,
                    addedPhase: phase,
                    allPhases: phases,
                    onAddAnother: {
                        currentScreen = .builder
                    },
                    onDone: {
                        isPresented = false
                    }
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("Phase Prompt") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, LifePhase.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    return PhasePromptModal(
        user: user,
        onAddChapters: {},
        onSkip: {}
    )
    .modelContainer(container)
}
