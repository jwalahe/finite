//
//  OnboardingView.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    @State private var isButtonPressed = false

    var onComplete: (User) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Title
            VStack(spacing: 8) {
                Text("Finite")
                    .font(.system(size: 48, weight: .light, design: .default))
                    .tracking(2)
                    .foregroundStyle(Color.textPrimary)

                Text("Your life in weeks.")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.bottom, 64) // 8pt multiple

            // Birthday picker
            VStack(spacing: 16) { // 8pt multiple
                Text("When were you born?")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                DatePicker(
                    "",
                    selection: $viewModel.birthDate,
                    in: viewModel.minimumDate...viewModel.maximumDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .onChange(of: viewModel.birthDate) { _, _ in
                    viewModel.isDateSelected = true
                    HapticService.shared.selection()
                }
            }

            Spacer()

            // Preview stats (subtle)
            if viewModel.isDateSelected {
                VStack(spacing: 4) {
                    Text("\(viewModel.previewWeeksLived.formatted()) weeks lived")
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                    Text("\(viewModel.previewWeeksRemaining.formatted()) weeks remaining")
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                }
                .padding(.bottom, 24) // 8pt multiple
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // Continue button - CRAFT_SPEC: scale 0.96x on press, haptic on tap
            Button {
                HapticService.shared.light()
                let user = viewModel.createUser(in: modelContext)
                onComplete(user)
            } label: {
                Text("See Your Life")
                    .font(.headline)
                    .foregroundStyle(Color.bgPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16) // 8pt multiple
                    .background(Color.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .scaleEffect(isButtonPressed ? 0.96 : 1.0)
            .animation(.snappy(duration: 0.12), value: isButtonPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isButtonPressed {
                            isButtonPressed = true
                            HapticService.shared.light()
                        }
                    }
                    .onEnded { _ in
                        isButtonPressed = false
                    }
            )
            .padding(.horizontal, 24) // CRAFT_SPEC: 24pt screen margins
            .padding(.bottom, 48) // 8pt multiple
        }
        .background(Color.bgPrimary)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isDateSelected)
    }
}

#Preview {
    OnboardingView { _ in }
        .modelContainer(for: User.self, inMemory: true)
}
