//
//  SpotlightMask.swift
//  Finite
//
//  Dimmed overlay with spotlight cutout for walkthrough
//  Uses mask modifier for proper cutout rendering
//

import SwiftUI

struct SpotlightMask: View {
    let step: WalkthroughStep
    let gridFrame: CGRect
    let currentWeekFrame: CGRect
    let dotIndicatorFrame: CGRect
    let spineFrame: CGRect
    let addPhaseButtonFrame: CGRect

    var body: some View {
        // Semi-transparent overlay with cutout
        Rectangle()
            .fill(Color.black.opacity(dimOpacity))
            .reverseMask {
                if let spotlight = spotlightRect {
                    RoundedRectangle(cornerRadius: spotlightCornerRadius)
                        .frame(width: spotlight.width, height: spotlight.height)
                        .position(x: spotlight.midX, y: spotlight.midY)
                }
            }
            .animation(.easeOut(duration: 0.3), value: step)
    }

    // MARK: - Computed

    private var dimOpacity: Double {
        switch step {
        case .complete: return 0.9
        default: return 0.8
        }
    }

    private var spotlightRect: CGRect? {
        switch step {
        case .gridIntro:
            // Spotlight entire grid
            return gridFrame.insetBy(dx: -12, dy: -12)

        case .currentWeekIntro:
            // Spotlight on the current week
            guard currentWeekFrame != .zero else { return gridFrame.insetBy(dx: -12, dy: -12) }
            return currentWeekFrame.insetBy(dx: -24, dy: -24)

        case .swipeToChapters, .swipeToQuality:
            // Spotlight the grid area for swiping
            return gridFrame.insetBy(dx: -12, dy: -12)

        case .explainChapters:
            // Spotlight grid to show chapter colors
            return gridFrame.insetBy(dx: -12, dy: -12)

        case .tapSpine:
            // Spotlight the timeline spine on the left
            guard spineFrame != .zero else { return gridFrame.insetBy(dx: -12, dy: -12) }
            return spineFrame.insetBy(dx: -8, dy: -8)

        case .markWeek:
            // Spotlight the grid for long-press
            return gridFrame.insetBy(dx: -12, dy: -12)

        case .addPhase:
            // Spotlight the "+" button on TimeSpine
            guard addPhaseButtonFrame != .zero else { return spineFrame.insetBy(dx: -8, dy: -8) }
            return addPhaseButtonFrame.insetBy(dx: -12, dy: -12)

        case .complete:
            return nil  // Full dim, no spotlight
        }
    }

    private var spotlightCornerRadius: CGFloat {
        switch step {
        case .currentWeekIntro: return 100  // Circular for current week
        case .addPhase: return 24  // Rounded for button
        default: return 12
        }
    }
}

// MARK: - Reverse Mask Extension

extension View {
    @ViewBuilder
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(
            Rectangle()
                .overlay(
                    mask()
                        .blendMode(.destinationOut)
                )
        )
    }
}
