//
//  BreathingAura.swift
//  Finite
//
//  Subtle edge glow with current phase color
//  CRAFT_SPEC: Radial gradient at screen edges, 15% opacity, 0.5s transition
//

import SwiftUI

struct BreathingAura: View {
    let phaseColor: Color

    // CRAFT_SPEC: 80pt radius from each edge
    private let auraRadius: CGFloat = 80
    // CRAFT_SPEC: 15% opacity
    private let auraOpacity: Double = 0.15

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Top edge
                RadialGradient(
                    gradient: Gradient(colors: [
                        phaseColor.opacity(auraOpacity),
                        phaseColor.opacity(0)
                    ]),
                    center: .top,
                    startRadius: 0,
                    endRadius: auraRadius
                )
                .frame(height: auraRadius)
                .frame(maxHeight: .infinity, alignment: .top)

                // Bottom edge
                RadialGradient(
                    gradient: Gradient(colors: [
                        phaseColor.opacity(auraOpacity),
                        phaseColor.opacity(0)
                    ]),
                    center: .bottom,
                    startRadius: 0,
                    endRadius: auraRadius
                )
                .frame(height: auraRadius)
                .frame(maxHeight: .infinity, alignment: .bottom)

                // Left edge
                RadialGradient(
                    gradient: Gradient(colors: [
                        phaseColor.opacity(auraOpacity),
                        phaseColor.opacity(0)
                    ]),
                    center: .leading,
                    startRadius: 0,
                    endRadius: auraRadius
                )
                .frame(width: auraRadius)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Right edge
                RadialGradient(
                    gradient: Gradient(colors: [
                        phaseColor.opacity(auraOpacity),
                        phaseColor.opacity(0)
                    ]),
                    center: .trailing,
                    startRadius: 0,
                    endRadius: auraRadius
                )
                .frame(width: auraRadius)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .allowsHitTesting(false)
        // CRAFT_SPEC: 0.5s ease-in-out transition when phase color changes
        .animation(.easeInOut(duration: 0.5), value: phaseColor)
    }
}

#Preview {
    ZStack {
        Color.bgPrimary

        BreathingAura(phaseColor: Color.fromHex("#4F46E5"))

        Text("Content here")
            .foregroundStyle(Color.textPrimary)
    }
}
