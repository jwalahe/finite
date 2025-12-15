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

    var onComplete: (User) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Title
            VStack(spacing: 8) {
                Text("Finite")
                    .font(.system(size: 48, weight: .light, design: .default))
                    .tracking(2)

                Text("Your life in weeks.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 60)

            // Birthday picker
            VStack(spacing: 16) {
                Text("When were you born?")
                    .font(.headline)
                    .foregroundStyle(.primary)

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
                        .foregroundStyle(.tertiary)
                    Text("\(viewModel.previewWeeksRemaining.formatted()) weeks remaining")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.bottom, 24)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // Continue button
            Button {
                HapticService.shared.medium()
                let user = viewModel.createUser(in: modelContext)
                onComplete(user)
            } label: {
                Text("See Your Life")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(Color.finiteBackground)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isDateSelected)
    }
}

#Preview {
    OnboardingView { _ in }
        .modelContainer(for: User.self, inMemory: true)
}
