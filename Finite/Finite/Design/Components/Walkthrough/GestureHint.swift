//
//  GestureHint.swift
//  Finite
//
//  Animated hand indicators for walkthrough gestures
//

import SwiftUI

enum GestureHintType {
    case tap
    case longPress
    case swipeLeft
    case swipeRight
    case swipeUp
}

struct GestureHint: View {
    let type: GestureHintType
    let position: CGPoint

    @State private var animationPhase: CGFloat = 0
    @State private var isVisible = false
    @State private var animationTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            // Hand/finger icon
            Image(systemName: handIcon)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.white)
                .offset(animationOffset)
                .scaleEffect(animationScale)
                .opacity(isVisible ? 1 : 0)
        }
        .position(position)
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            animationTask?.cancel()
        }
    }

    private var handIcon: String {
        switch type {
        case .tap, .longPress: return "hand.point.up.fill"
        case .swipeLeft, .swipeRight: return "hand.draw.fill"
        case .swipeUp: return "hand.point.up.fill"
        }
    }

    private var animationOffset: CGSize {
        switch type {
        case .tap:
            return CGSize(width: 0, height: animationPhase * -10)
        case .longPress:
            return CGSize(width: 0, height: animationPhase * -5)
        case .swipeLeft:
            return CGSize(width: -animationPhase * 60, height: 0)
        case .swipeRight:
            return CGSize(width: animationPhase * 60, height: 0)
        case .swipeUp:
            return CGSize(width: 0, height: -animationPhase * 40)
        }
    }

    private var animationScale: CGFloat {
        switch type {
        case .tap:
            return 1.0 - (animationPhase * 0.15)  // Press down effect
        case .longPress:
            return animationPhase > 0.5 ? 0.85 : 1.0  // Hold down
        default:
            return 1.0
        }
    }

    private func startAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            isVisible = true
        }

        // Start gesture animation based on type
        switch type {
        case .tap:
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true).delay(0.5)) {
                animationPhase = 1
            }

        case .longPress:
            animateLongPress()

        case .swipeLeft, .swipeRight, .swipeUp:
            animateSwipe()
        }
    }

    private func animateLongPress() {
        animationTask = Task {
            while !Task.isCancelled {
                // Press down
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.3)) {
                        animationPhase = 1
                    }
                }

                try? await Task.sleep(nanoseconds: 1_200_000_000)  // Hold for 1.2s

                // Release
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.2)) {
                        animationPhase = 0
                    }
                }

                try? await Task.sleep(nanoseconds: 500_000_000)  // Wait 0.5s before repeat
            }
        }
    }

    private func animateSwipe() {
        animationTask = Task {
            while !Task.isCancelled {
                await MainActor.run {
                    animationPhase = 0
                }

                try? await Task.sleep(nanoseconds: 300_000_000)  // Initial delay

                // Swipe animation
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        animationPhase = 1
                    }
                }

                try? await Task.sleep(nanoseconds: 800_000_000)  // Wait for animation

                // Reset
                await MainActor.run {
                    animationPhase = 0
                }

                try? await Task.sleep(nanoseconds: 400_000_000)  // Pause before repeat
            }
        }
    }
}
