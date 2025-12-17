//
//  LockScreen.swift
//  Finite
//
//  Biometric authentication screen shown on app launch
//

import SwiftUI

struct LockScreen: View {
    let onUnlock: () -> Void

    @State private var isAuthenticating: Bool = false
    @State private var authError: String?

    var body: some View {
        ZStack {
            Color.bgPrimary
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App title
                VStack(spacing: 8) {
                    Text("Finite")
                        .font(.system(size: 32, weight: .light))
                        .tracking(3)
                        .foregroundStyle(Color.textPrimary)

                    Text("Your life in weeks")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                // Unlock button
                VStack(spacing: 16) {
                    Button {
                        authenticate()
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: biometricIcon)
                                .font(.system(size: 44))
                                .foregroundStyle(Color.textPrimary)

                            Text("Tap to Unlock")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(isAuthenticating)

                    if let error = authError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .onAppear {
            // Auto-trigger authentication on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                authenticate()
            }
        }
    }

    private var biometricIcon: String {
        switch BiometricService.shared.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock.fill"
        }
    }

    private func authenticate() {
        guard !isAuthenticating else { return }

        isAuthenticating = true
        authError = nil

        Task {
            let success = await BiometricService.shared.authenticate(reason: "Unlock Finite to view your life")

            await MainActor.run {
                isAuthenticating = false

                if success {
                    HapticService.shared.medium()
                    onUnlock()
                } else {
                    authError = "Authentication failed. Tap to try again."
                    HapticService.shared.error()
                }
            }
        }
    }
}

#Preview {
    LockScreen {
        print("Unlocked!")
    }
}
