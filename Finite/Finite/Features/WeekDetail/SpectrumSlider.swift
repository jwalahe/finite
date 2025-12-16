//
//  SpectrumSlider.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/16/25.
//

import SwiftUI

struct SpectrumSlider: View {
    @Binding var rating: Int

    // CRAFT_SPEC: Track height 6pt, thumb size 28pt
    private let trackHeight: CGFloat = 6
    private let thumbSize: CGFloat = 28
    private let notchCount = 5

    // Gradient from awful (red) to great (green)
    private let spectrumGradient = LinearGradient(
        colors: [
            Color.ratingAwful,
            Color.ratingHard,
            Color.ratingOkay,
            Color.ratingGood,
            Color.ratingGreat
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width - thumbSize
            let notchSpacing = trackWidth / CGFloat(notchCount - 1)

            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: trackHeight / 2)
                    .fill(spectrumGradient)
                    .frame(height: trackHeight)
                    .padding(.horizontal, thumbSize / 2)

                // Notch markers (subtle dots at each position)
                HStack(spacing: 0) {
                    ForEach(0..<notchCount, id: \.self) { index in
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 4, height: 4)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, thumbSize / 2)

                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .offset(x: CGFloat(rating - 1) * notchSpacing)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - thumbSize / 2
                                let newRating = Int(round(x / notchSpacing)) + 1
                                let clampedRating = min(max(newRating, 1), 5)

                                if clampedRating != rating {
                                    rating = clampedRating
                                    // CRAFT_SPEC: Selection haptic on each notch
                                    HapticService.shared.selection()
                                }
                            }
                    )
                    .animation(.snappy(duration: 0.1, extraBounce: 0.2), value: rating)
            }
            .frame(height: thumbSize)
        }
        .frame(height: thumbSize)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var rating = 3

        var body: some View {
            VStack(spacing: 40) {
                SpectrumSlider(rating: $rating)
                    .padding(.horizontal, 24)

                Text("Rating: \(rating)")
                    .font(.title)
            }
            .padding()
            .background(Color.bgPrimary)
        }
    }

    return PreviewWrapper()
}
