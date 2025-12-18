//
//  CoachMark.swift
//  Finite
//
//  Tooltip bubble for walkthrough guidance
//

import SwiftUI

enum TooltipPosition {
    case above, below, left, right, center
}

struct CoachMark: View {
    let step: WalkthroughStep
    let targetFrame: CGRect
    let onTap: () -> Void

    @State private var isVisible = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                // Title
                Text(step.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                // Message
                Text(step.message)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // Action hint
                if let hint = step.actionHint {
                    Text(hint)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 8)
                }
            }
            .padding(24)
            .frame(maxWidth: 300)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .position(tooltipPosition(in: geometry.size))
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.9)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                    isVisible = true
                }
            }
            .onChange(of: step) { _, _ in
                // Reset animation for new step
                isVisible = false
                withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                    isVisible = true
                }
            }
            .onTapGesture {
                if !step.requiresUserAction {
                    onTap()
                }
            }
        }
    }

    private func tooltipPosition(in screenSize: CGSize) -> CGPoint {
        let position = calculatePosition(for: step, screenSize: screenSize)

        switch position {
        case .center:
            return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        case .above:
            return CGPoint(
                x: min(max(targetFrame.midX, 160), screenSize.width - 160),
                y: max(120, targetFrame.minY - 120)
            )
        case .below:
            return CGPoint(
                x: min(max(targetFrame.midX, 160), screenSize.width - 160),
                y: min(screenSize.height - 120, targetFrame.maxY + 120)
            )
        default:
            return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        }
    }

    private func calculatePosition(for step: WalkthroughStep, screenSize: CGSize) -> TooltipPosition {
        switch step {
        case .gridIntro: return .center
        case .currentWeek: return targetFrame.midY > screenSize.height / 2 ? .above : .below
        case .viewModesIntro: return .above
        case .chaptersExplanation: return .center
        case .addPhase: return .center
        case .markWeek: return targetFrame.midY > screenSize.height / 2 ? .above : .below
        case .complete: return .center
        }
    }
}
