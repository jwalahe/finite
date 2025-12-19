//
//  DotIndicator.swift
//  Finite
//
//  Four-dot indicator for view mode (Chapters/Quality/Focus/Horizons)
//  CRAFT_SPEC: 8pt diameter dots, 8pt spacing, crossfade 0.2s
//

import SwiftUI

struct DotIndicator: View {
    let currentMode: ViewMode
    let dotSize: CGFloat = 8
    let spacing: CGFloat = 8

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Circle()
                    .fill(mode == currentMode ? Color.textPrimary : Color.textTertiary)
                    .frame(width: dotSize, height: dotSize)
                    .animation(.easeOut(duration: 0.2), value: currentMode)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        DotIndicator(currentMode: .chapters)
        DotIndicator(currentMode: .quality)
        DotIndicator(currentMode: .focus)
        DotIndicator(currentMode: .horizons)
    }
    .padding()
    .background(Color.bgPrimary)
}
