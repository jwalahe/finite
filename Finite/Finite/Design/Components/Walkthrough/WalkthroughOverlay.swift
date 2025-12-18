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

    private var currentStep: WalkthroughStep? {
        walkthrough.currentStep
    }

    private var shouldPassTouchesThrough: Bool {
        currentStep?.requiresUserAction == true
    }

    var body: some View {
        ZStack {
            if let step = currentStep {
                // Dimmed background with spotlight cutout
                SpotlightMask(
                    step: step,
                    gridFrame: walkthrough.gridFrame,
                    currentWeekFrame: walkthrough.currentWeekFrame,
                    dotIndicatorFrame: walkthrough.dotIndicatorFrame
                )
                .ignoresSafeArea()

                // Coach mark (text only, positioned safely on screen)
                CoachMark(
                    step: step,
                    gridFrame: walkthrough.gridFrame,
                    onTap: { handleTap(for: step) }
                )

                // Skip button (minimal) - always tappable
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
                            ForEach(0..<7, id: \.self) { index in
                                Circle()
                                    .fill(index <= step.rawValue ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 5, height: 5)
                            }
                        }
                        .padding(.bottom, 50)
                    }
                    .allowsHitTesting(false)
                }
            }
        }
        // For steps that require user action (swipe, tap week, long-press),
        // let all touches pass through to the grid underneath
        .allowsHitTesting(!shouldPassTouchesThrough)
        // For tap-to-continue steps, handle tap on the whole overlay
        .onTapGesture {
            if let step = currentStep {
                handleTap(for: step)
            }
        }
    }

    // MARK: - Tap Handling

    private func handleTap(for step: WalkthroughStep) {
        switch step {
        case .gridIntro:
            walkthrough.advance()

        case .currentWeekIntro:
            walkthrough.advance()

        case .swipeToChapters:
            // Touches pass through - grid handles swipe
            break

        case .explainChapters:
            walkthrough.advance()

        case .addPhase:
            // Open the phase form
            onPhasePrompt()

        case .swipeToQuality:
            // Touches pass through - grid handles swipe
            break

        case .markWeek:
            // Touches pass through - grid handles long-press
            break

        case .complete:
            walkthrough.skip()
        }
    }
}
