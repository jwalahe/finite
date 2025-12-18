//
//  WalkthroughOverlay.swift
//  Finite
//
//  Minimal, calm walkthrough overlay
//  Philosophy: Guide without distracting
//

import SwiftUI

struct WalkthroughOverlay: View {
    @ObservedObject var walkthrough: WalkthroughService
    let onPhasePrompt: () -> Void

    var body: some View {
        ZStack {
            if let step = walkthrough.currentStep {
                // Dimmed background with spotlight cutout
                SpotlightMask(
                    step: step,
                    gridFrame: walkthrough.gridFrame,
                    currentWeekFrame: walkthrough.currentWeekFrame,
                    dotIndicatorFrame: walkthrough.dotIndicatorFrame
                )
                .ignoresSafeArea()
                .allowsHitTesting(!step.requiresUserAction)  // Let touches through for action steps
                .onTapGesture {
                    handleTap(for: step)
                }

                // Coach mark (text only, no background)
                CoachMark(
                    step: step,
                    gridFrame: walkthrough.gridFrame,
                    onTap: { handleTap(for: step) }
                )

                // Skip button (minimal)
                if walkthrough.canSkip {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                walkthrough.skip()
                            } label: {
                                Text("Skip")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 56)
                        }
                        Spacer()
                    }
                }

                // Minimal progress dots
                if step != .complete {
                    VStack {
                        Spacer()
                        HStack(spacing: 6) {
                            ForEach(0..<6, id: \.self) { index in
                                Circle()
                                    .fill(index <= step.rawValue ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 5, height: 5)
                            }
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .allowsHitTesting(walkthrough.isActive)
    }

    // MARK: - Tap Handling

    private func handleTap(for step: WalkthroughStep) {
        switch step {
        case .gridIntro:
            // Tap anywhere advances
            walkthrough.advance()

        case .currentWeek:
            // Need to tap the actual current week - let touch through
            // The GridView will call walkthrough.handleCurrentWeekTapped()
            break

        case .viewModesIntro:
            // Need to swipe - let touch through
            // The GridView will call walkthrough.handleViewModeChanged()
            break

        case .chaptersExplanation:
            // Tap anywhere advances
            walkthrough.advance()

        case .addPhase:
            // Open phase builder
            onPhasePrompt()

        case .markWeek:
            // Need to long-press a week - let touch through
            // The GridView will call walkthrough.handleWeekMarked()
            break

        case .complete:
            // Auto-dismisses, but allow tap to dismiss early
            walkthrough.skip()
        }
    }
}
