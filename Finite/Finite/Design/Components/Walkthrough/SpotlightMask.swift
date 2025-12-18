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

        case .currentWeek:
            // Small circular spotlight on current week
            guard currentWeekFrame != .zero else { return nil }
            return currentWeekFrame.insetBy(dx: -20, dy: -20)

        case .viewModesIntro:
            // Spotlight the grid area for swiping
            return gridFrame.insetBy(dx: -12, dy: -12)

        case .chaptersExplanation:
            // Spotlight grid showing phase colors
            return gridFrame.insetBy(dx: -12, dy: -12)

        case .markWeek:
            // Spotlight a region of the grid for long-press
            guard currentWeekFrame != .zero && gridFrame != .zero else { return nil }
            return gridFrame.insetBy(dx: -12, dy: -12)

        case .addPhase, .complete:
            return nil  // Full dim, no spotlight
        }
    }

    private var spotlightCornerRadius: CGFloat {
        switch step {
        case .currentWeek: return 100  // Circular
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
