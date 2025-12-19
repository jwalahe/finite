//
//  MilestoneMarker.swift
//  Finite
//
//  Hexagon marker for milestones on the life grid
//  Appears on future weeks where milestones are pinned
//

import SwiftUI

struct MilestoneMarker: View {
    let milestone: Milestone
    let size: CGFloat
    let isHighlighted: Bool

    @State private var pulsePhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Base hexagon
            Image(systemName: milestone.iconName ?? "hexagon.fill")
                .font(.system(size: size))
                .foregroundStyle(markerColor)

            // Highlight ring (when selected)
            if isHighlighted {
                Image(systemName: "hexagon")
                    .font(.system(size: size + 4))
                    .foregroundStyle(markerColor.opacity(0.5))
                    .scaleEffect(1.0 + pulsePhase * 0.3)
                    .opacity(1.0 - pulsePhase * 0.8)
            }
        }
        .onAppear {
            if isHighlighted {
                withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    pulsePhase = 1.0
                }
            }
        }
        .onChange(of: isHighlighted) { _, newValue in
            if newValue {
                pulsePhase = 0
                withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    pulsePhase = 1.0
                }
            } else {
                pulsePhase = 0
            }
        }
    }

    private var markerColor: Color {
        Color.fromHex(milestone.displayColorHex)
    }
}

// MARK: - Compact Marker (for grid cells)

/// A simpler marker for rendering within the grid canvas
struct MilestoneMarkerCompact: View {
    let colorHex: String
    let size: CGFloat

    var body: some View {
        Image(systemName: "hexagon.fill")
            .font(.system(size: size))
            .foregroundStyle(Color.fromHex(colorHex))
    }
}

// MARK: - Preview

#Preview {
    let milestone1 = Milestone(name: "Launch Startup", targetWeekNumber: 1625, category: .work)
    let milestone2 = Milestone(name: "Run Marathon", targetWeekNumber: 1700, category: .health)
    let milestone3 = Milestone(name: "Write Book", targetWeekNumber: 1800, category: .growth)

    return VStack(spacing: 32) {
        Text("Normal")
            .font(.caption)
            .foregroundStyle(.secondary)

        HStack(spacing: 24) {
            MilestoneMarker(milestone: milestone1, size: 24, isHighlighted: false)
            MilestoneMarker(milestone: milestone2, size: 24, isHighlighted: false)
            MilestoneMarker(milestone: milestone3, size: 24, isHighlighted: false)
        }

        Text("Highlighted")
            .font(.caption)
            .foregroundStyle(.secondary)

        HStack(spacing: 24) {
            MilestoneMarker(milestone: milestone1, size: 24, isHighlighted: true)
            MilestoneMarker(milestone: milestone2, size: 24, isHighlighted: true)
            MilestoneMarker(milestone: milestone3, size: 24, isHighlighted: true)
        }

        Text("Compact (Grid Size)")
            .font(.caption)
            .foregroundStyle(.secondary)

        HStack(spacing: 8) {
            MilestoneMarkerCompact(colorHex: "#0D9488", size: 8)
            MilestoneMarkerCompact(colorHex: "#DC2626", size: 8)
            MilestoneMarkerCompact(colorHex: "#4F46E5", size: 8)
        }
    }
    .padding()
    .background(Color.bgPrimary)
}
