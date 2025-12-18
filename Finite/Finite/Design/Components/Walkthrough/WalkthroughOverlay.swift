//
//  WalkthroughOverlay.swift
//  Finite
//
//  Main coordinator view for the interactive walkthrough
//  Philosophy: Learn by doing, not reading
//

import SwiftUI

struct WalkthroughOverlay: View {
    @ObservedObject var walkthrough: WalkthroughService
    let onPhasePrompt: () -> Void  // Triggers phase modal

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
                .allowsHitTesting(spotlightBlocksTouches(for: step))
                .onTapGesture {
                    handleBackgroundTap(for: step)
                }

                // Coach mark (tooltip)
                CoachMark(
                    step: step,
                    targetFrame: targetFrame(for: step),
                    onTap: { handleTap(for: step) }
                )

                // Gesture hint (animated hand)
                if let gestureType = gestureType(for: step) {
                    GestureHint(
                        type: gestureType,
                        position: gesturePosition(for: step)
                    )
                }

                // Pulse ring around target
                if let pulseFrame = spotlightFrame(for: step), step.requiresUserAction {
                    PulseRing(frame: pulseFrame)
                }

                // Skip button
                if walkthrough.canSkip {
                    VStack {
                        HStack {
                            Spacer()
                            SkipButton {
                                walkthrough.skip()
                            }
                            .padding(.trailing, 24)
                            .padding(.top, 60)
                        }
                        Spacer()
                    }
                }

                // Progress indicator
                if step != .complete {
                    VStack {
                        Spacer()
                        WalkthroughProgressDots(
                            totalSteps: WalkthroughStep.allCases.count - 1,  // Exclude .complete
                            currentStep: step.rawValue
                        )
                        .padding(.bottom, 40)
                    }
                }
            }

            // Celebration burst
            if walkthrough.showCelebration {
                CelebrationBurst()
            }
        }
        .animation(.easeOut(duration: 0.3), value: walkthrough.currentStep)
    }

    // MARK: - Tap Handling

    private func handleTap(for step: WalkthroughStep) {
        switch step {
        case .gridIntro, .chaptersExplanation:
            // Tap anywhere advances
            walkthrough.advance()

        case .addPhase:
            // Trigger phase prompt modal
            onPhasePrompt()

        default:
            // Other steps require specific user action
            break
        }
    }

    private func handleBackgroundTap(for step: WalkthroughStep) {
        // For non-action steps, tapping background advances
        if !step.requiresUserAction {
            walkthrough.advance()
        }
    }

    // MARK: - Frame Helpers

    private func targetFrame(for step: WalkthroughStep) -> CGRect {
        switch step {
        case .gridIntro:
            return walkthrough.gridFrame
        case .currentWeek:
            return walkthrough.currentWeekFrame
        case .viewModesIntro:
            return walkthrough.dotIndicatorFrame
        case .chaptersExplanation:
            return walkthrough.gridFrame
        case .addPhase:
            return .zero  // Modal handles its own positioning
        case .markWeek:
            // Target a filled week region
            return CGRect(
                x: walkthrough.currentWeekFrame.midX - 80,
                y: walkthrough.currentWeekFrame.midY - 30,
                width: 80,
                height: 60
            )
        case .complete:
            return .zero
        }
    }

    private func spotlightFrame(for step: WalkthroughStep) -> CGRect? {
        switch step {
        case .currentWeek:
            return walkthrough.currentWeekFrame.insetBy(dx: -20, dy: -20)
        case .viewModesIntro:
            return walkthrough.dotIndicatorFrame.insetBy(dx: -30, dy: -20)
        case .markWeek:
            // Spotlight a region of filled weeks
            return CGRect(
                x: max(walkthrough.gridFrame.minX, walkthrough.currentWeekFrame.minX - 100),
                y: max(walkthrough.gridFrame.minY, walkthrough.currentWeekFrame.minY - 40),
                width: 120,
                height: 80
            )
        default:
            return nil
        }
    }

    private func spotlightBlocksTouches(for step: WalkthroughStep) -> Bool {
        // Block touches on dimmed area for steps that require specific target
        switch step {
        case .currentWeek, .markWeek:
            return false  // Allow touches through to grid
        default:
            return true  // Block touches, handle in overlay
        }
    }

    private func gestureType(for step: WalkthroughStep) -> GestureHintType? {
        switch step {
        case .currentWeek: return .tap
        case .viewModesIntro: return .swipeLeft
        case .markWeek: return .longPress
        default: return nil
        }
    }

    private func gesturePosition(for step: WalkthroughStep) -> CGPoint {
        switch step {
        case .currentWeek:
            return CGPoint(
                x: walkthrough.currentWeekFrame.midX,
                y: walkthrough.currentWeekFrame.midY + 60
            )
        case .viewModesIntro:
            return CGPoint(
                x: walkthrough.gridFrame.midX,
                y: walkthrough.gridFrame.midY
            )
        case .markWeek:
            return CGPoint(
                x: walkthrough.currentWeekFrame.midX - 60,
                y: walkthrough.currentWeekFrame.midY + 40
            )
        default:
            return .zero
        }
    }
}
