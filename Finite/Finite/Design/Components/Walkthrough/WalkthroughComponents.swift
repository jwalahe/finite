//
//  WalkthroughComponents.swift
//  Finite
//
//  Supporting components for the walkthrough system
//

import SwiftUI

// MARK: - Skip Button

struct SkipButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Skip")
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.15))
                )
        }
    }
}

// MARK: - Progress Dots

struct WalkthroughProgressDots: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 6, height: 6)
                    .scaleEffect(index == currentStep ? 1.2 : 1.0)
                    .animation(.snappy(duration: 0.2), value: currentStep)
            }
        }
    }
}

// MARK: - Preference Keys for Frame Tracking

struct GridFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct CurrentWeekFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct DotIndicatorFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
