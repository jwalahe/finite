//
//  PulseRing.swift
//  Finite
//
//  Attention ring around spotlight targets
//

import SwiftUI

struct PulseRing: View {
    let frame: CGRect

    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.8

    var body: some View {
        ZStack {
            // Inner ring
            RoundedRectangle(cornerRadius: frame.width / 2)
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                .frame(width: frame.width, height: frame.height)

            // Outer pulsing ring
            RoundedRectangle(cornerRadius: frame.width / 2)
                .stroke(Color.white.opacity(opacity), lineWidth: 2)
                .frame(width: frame.width, height: frame.height)
                .scaleEffect(scale)
        }
        .position(x: frame.midX, y: frame.midY)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                scale = 1.6
                opacity = 0
            }
        }
    }
}
