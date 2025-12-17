//
//  BiometricService.swift
//  Finite
//
//  Handles Face ID / Touch ID authentication
//

import Foundation
import LocalAuthentication

final class BiometricService {
    static let shared = BiometricService()

    private init() {}

    // MARK: - Biometric Type

    enum BiometricType {
        case none
        case touchID
        case faceID
    }

    /// Get the available biometric type on this device
    var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .faceID // Treat Vision Pro optic ID like Face ID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }

    /// Human-readable name for the biometric type
    var biometricName: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .none:
            return "Passcode"
        }
    }

    /// Check if biometrics are available
    var isBiometricAvailable: Bool {
        biometricType != .none
    }

    // MARK: - Authentication

    /// Authenticate with biometrics or device passcode
    /// Returns true if authenticated successfully
    func authenticate(reason: String = "Unlock Finite") async -> Bool {
        let context = LAContext()
        var error: NSError?

        // Check if device supports biometric or passcode authentication
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print("⚠️ BiometricService: Device doesn't support authentication - \(error?.localizedDescription ?? "unknown")")
            return false
        }

        do {
            // This will try biometrics first, then fall back to passcode
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            return success
        } catch let error as LAError {
            switch error.code {
            case .userCancel:
                print("ℹ️ BiometricService: User cancelled authentication")
            case .userFallback:
                print("ℹ️ BiometricService: User chose passcode fallback")
            case .biometryNotAvailable:
                print("⚠️ BiometricService: Biometry not available")
            case .biometryNotEnrolled:
                print("⚠️ BiometricService: Biometry not enrolled")
            case .biometryLockout:
                print("⚠️ BiometricService: Biometry locked out")
            default:
                print("⚠️ BiometricService: Authentication failed - \(error.localizedDescription)")
            }
            return false
        } catch {
            print("⚠️ BiometricService: Unexpected error - \(error)")
            return false
        }
    }
}
