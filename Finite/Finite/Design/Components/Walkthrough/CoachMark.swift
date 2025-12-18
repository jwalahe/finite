//
//  CoachMark.swift
//  Finite
//
//  Minimal tooltip for walkthrough guidance
//  Matches app's contemplative aesthetic - no flashy materials
//

import SwiftUI

struct CoachMark: View {
    let step: WalkthroughStep
    let gridFrame: CGRect
    let onTap: () -> Void

    @State private var isVisible = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Title
                Text(step.title)
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                // Message
                Text(step.message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // Action hint (subtle)
                if let hint = step.actionHint {
                    Text(hint)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: 320)
            .position(tooltipPosition(in: geometry.size))
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                    isVisible = true
                }
            }
            .onChange(of: step) { _, _ in
                isVisible = false
                withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                    isVisible = true
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if !step.requiresUserAction {
                    onTap()
                }
            }
        }
    }

    private func tooltipPosition(in screenSize: CGSize) -> CGPoint {
        switch step {
        case .gridIntro, .chaptersExplanation, .addPhase, .complete:
            // Center of screen
            return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

        case .currentWeek:
            // Above or below the grid depending on where current week is
            let gridMidY = gridFrame.midY
            if gridMidY < screenSize.height / 2 {
                // Grid is in top half, put tooltip below
                return CGPoint(x: screenSize.width / 2, y: gridFrame.maxY + 80)
            } else {
                // Grid is in bottom half, put tooltip above
                return CGPoint(x: screenSize.width / 2, y: gridFrame.minY - 80)
            }

        case .viewModesIntro, .markWeek:
            // Position above the grid
            return CGPoint(x: screenSize.width / 2, y: gridFrame.minY - 60)
        }
    }
}
