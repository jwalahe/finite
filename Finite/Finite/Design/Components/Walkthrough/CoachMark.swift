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
        // Safe area padding
        let safeTop: CGFloat = 120
        let safeBottom: CGFloat = 120

        switch step {
        case .addPhase, .complete:
            // Center of screen (no grid spotlight)
            return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

        case .gridIntro, .currentWeekIntro, .swipeToChapters, .explainChapters, .tapSpine, .swipeToQuality, .markWeek:
            // Position below the grid
            let belowGrid = gridFrame.maxY + 80
            let safeY = min(belowGrid, screenSize.height - safeBottom)
            return CGPoint(x: screenSize.width / 2, y: safeY)
        }
    }
}
