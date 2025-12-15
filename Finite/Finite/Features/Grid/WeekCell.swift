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

// Pulsating current week cell - separate view for the animation
struct CurrentWeekCell: View {
    let cellSize: CGFloat

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(Color.gridFilled)
            .frame(width: cellSize, height: cellSize)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.4
                }
            }
    }
}

// Ripple effect overlay for current week
struct PulsingCurrentWeekOverlay: View {
    let cellSize: CGFloat
    let position: CGPoint

    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6

    var body: some View {
        Circle()
            .stroke(Color.primary.opacity(opacity), lineWidth: 1)
            .frame(width: cellSize, height: cellSize)
            .scaleEffect(scale)
            .position(position)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    scale = 3.0
                    opacity = 0.0
                }
            }
    }
}

#Preview {
    HStack(spacing: 8) {
        WeekCell(weekNumber: 1, isLived: true, isCurrentWeek: false, rating: nil, isRevealed: true)
            .frame(width: 10, height: 10)
        WeekCell(weekNumber: 2, isLived: true, isCurrentWeek: false, rating: 5, isRevealed: true)
            .frame(width: 10, height: 10)
        CurrentWeekCell(cellSize: 10)
        WeekCell(weekNumber: 4, isLived: false, isCurrentWeek: false, rating: nil, isRevealed: true)
            .frame(width: 10, height: 10)
    }
    .padding()
}
