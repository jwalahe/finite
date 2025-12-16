//
//  WeekCell.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import SwiftUI

struct WeekCell: View {
    let weekNumber: Int
    let isLived: Bool
    let isCurrentWeek: Bool
    let rating: Int?
    let isRevealed: Bool

    private var fillColor: Color {
        if let rating = rating {
            return Color.ratingColor(for: rating)
        } else if isLived && isRevealed {
            return .gridFilled
        } else {
            return .gridUnfilled
        }
    }

    var body: some View {
        Circle()
            .fill(fillColor)
    }
}

// Current week pulse overlay - per CRAFT_SPEC: scale 1.0→1.08, 2.0s duration
struct PulsingCurrentWeekOverlay: View {
    let cellSize: CGFloat
    let position: CGPoint

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(Color.weekCurrent)
            .frame(width: cellSize, height: cellSize)
            .scaleEffect(scale)
            .position(position)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.08
                }
            }
    }
}

#Preview {
    ZStack {
        Color.bgPrimary
        HStack(spacing: 8) {
            WeekCell(weekNumber: 1, isLived: true, isCurrentWeek: false, rating: nil, isRevealed: true)
                .frame(width: 10, height: 10)
            WeekCell(weekNumber: 2, isLived: true, isCurrentWeek: false, rating: 5, isRevealed: true)
                .frame(width: 10, height: 10)
            PulsingCurrentWeekOverlay(cellSize: 10, position: CGPoint(x: 50, y: 50))
            WeekCell(weekNumber: 4, isLived: false, isCurrentWeek: false, rating: nil, isRevealed: true)
                .frame(width: 10, height: 10)
        }
    }
}
