//
//  GhostNumber.swift
//  Finite
//
//  Weeks remaining at 8% opacity, tap to summon to 100%
//  CRAFT_SPEC: Focus view only, subliminal presence, tap to confront
//

import SwiftUI

struct GhostNumber: View {
    let weeksRemaining: Int

    // CRAFT_SPEC: 8% opacity default, tap summons to 100%
    @State private var numberOpacity: Double = 0.08
    @State private var isSummoned: Bool = false
    @State private var summonTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 8) {
            Text(weeksRemaining.formatted())
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary.opacity(numberOpacity))

            Text("weeks left")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.textSecondary.opacity(numberOpacity))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            summonNumber()
        }
        // Reset to ghost state when view disappears (mode switch)
        .onDisappear {
            summonTask?.cancel()
            numberOpacity = 0.08
            isSummoned = false
        }
    }

    // CRAFT_SPEC: Tap to summon - 0.2s rise to 100%, hold 2s, 0.3s fade back to 8%
    private func summonNumber() {
        // Cancel any existing summon task
        summonTask?.cancel()

        HapticService.shared.light()

        withAnimation(.easeOut(duration: 0.2)) {
            numberOpacity = 1.0
            isSummoned = true
        }

        // SST §18.4: Trigger share prompt on first ghost reveal
        // "Mortality salience at peak. Powerful share moment."
        ShareFlowController.shared.onGhostNumberRevealed()

        summonTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.3)) {
                    numberOpacity = 0.08
                    isSummoned = false
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.bgPrimary
            .ignoresSafeArea()

        VStack {
            Text("Tap the ghost number below")
                .foregroundStyle(Color.textSecondary)

            Spacer()

            GhostNumber(weeksRemaining: 2647)

            Spacer()
        }
    }
}
