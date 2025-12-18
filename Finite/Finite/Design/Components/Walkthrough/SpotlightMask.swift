//
//  SpotlightMask.swift
//  Finite
//
//  Dimmed overlay with spotlight cutout for walkthrough
//

import SwiftUI

struct SpotlightMask: View {
    let step: WalkthroughStep
    let gridFrame: CGRect
    let currentWeekFrame: CGRect
    let dotIndicatorFrame: CGRect

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Fill entire canvas with dim color
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(.black.opacity(dimOpacity))
                )

                // Cut out spotlight area if applicable
                if let spotlightRect = spotlightRect {
                    context.blendMode = .destinationOut

                    let cornerRadius = spotlightCornerRadius
                    let spotlightPath = Path(
                        roundedRect: spotlightRect,
                        cornerRadius: cornerRadius
                    )
                    context.fill(spotlightPath, with: .color(.white))
                }
            }
        }
        .animation(.easeOut(duration: 0.4), value: step)
    }

    // MARK: - Computed

    private var dimOpacity: Double {
        switch step {
        case .complete: return 0.85  // Darker for finale
        default: return 0.75
        }
    }

    private var spotlightRect: CGRect? {
        switch step {
        case .gridIntro:
            // Large spotlight on entire grid
            return gridFrame.insetBy(dx: -16, dy: -16)

        case .currentWeek:
            // Small spotlight on current week
            return currentWeekFrame.insetBy(dx: -24, dy: -24)

        case .viewModesIntro:
            // Spotlight on dot indicator + nearby grid area
            let indicatorSpotlight = dotIndicatorFrame.insetBy(dx: -40, dy: -20)
            let gridBottom = CGRect(
                x: gridFrame.minX,
                y: gridFrame.maxY - 100,
                width: gridFrame.width,
                height: 100
            )
            return indicatorSpotlight.union(gridBottom)

        case .chaptersExplanation:
            // Spotlight on grid (showing colors)
            return gridFrame.insetBy(dx: -16, dy: -16)

        case .markWeek:
            // Spotlight on a region of filled weeks (left of current week)
            let targetArea = CGRect(
                x: max(gridFrame.minX, currentWeekFrame.minX - 120),
                y: max(gridFrame.minY, currentWeekFrame.minY - 60),
                width: 160,
                height: 120
            )
            return targetArea

        case .addPhase, .complete:
            return nil  // No spotlight
        }
    }

    private var spotlightCornerRadius: CGFloat {
        switch step {
        case .currentWeek: return 50  // Circular for single week
        default: return 16
        }
    }
}
