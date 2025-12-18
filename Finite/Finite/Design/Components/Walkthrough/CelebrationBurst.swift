//
//  CelebrationBurst.swift
//  Finite
//
//  Subtle success animation with particles
//

import SwiftUI

struct CelebrationBurst: View {
    @State private var particles: [CelebrationParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                animateParticles()
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let colors: [Color] = [.white, .yellow, .cyan, .mint]

        particles = (0..<20).map { i in
            CelebrationParticle(
                id: i,
                position: center,
                targetPosition: CGPoint(
                    x: center.x + CGFloat.random(in: -150...150),
                    y: center.y + CGFloat.random(in: -150...150)
                ),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...10),
                opacity: 1.0
            )
        }
    }

    private func animateParticles() {
        withAnimation(.easeOut(duration: 0.6)) {
            for i in particles.indices {
                particles[i].position = particles[i].targetPosition
                particles[i].opacity = 0
            }
        }
    }
}

struct CelebrationParticle: Identifiable {
    let id: Int
    var position: CGPoint
    let targetPosition: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}
