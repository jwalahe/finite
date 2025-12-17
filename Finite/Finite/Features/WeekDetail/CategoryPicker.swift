//
//  CategoryPicker.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/16/25.
//

import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedCategory: WeekCategory?

    // CRAFT_SPEC: Icon size 24pt, touch target 48pt, spacing 12pt
    private let iconSize: CGFloat = 24
    private let touchTarget: CGFloat = 48
    private let spacing: CGFloat = 12

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(WeekCategory.allCases, id: \.self) { category in
                CategoryButton(
                    category: category,
                    isSelected: selectedCategory == category,
                    iconSize: iconSize,
                    touchTarget: touchTarget
                ) {
                    withAnimation(.snappy(duration: 0.2)) {
                        if selectedCategory == category {
                            // Deselect if already selected
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                        }
                    }
                    // CRAFT_SPEC: Light haptic on selection
                    HapticService.shared.light()
                }
            }
        }
        .frame(maxWidth: .infinity) // Center the HStack
    }
}

struct CategoryButton: View {
    let category: WeekCategory
    let isSelected: Bool
    let iconSize: CGFloat
    let touchTarget: CGFloat
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Background circle when selected
                    if isSelected {
                        Circle()
                            .fill(Color.bgSecondary)
                            .frame(width: touchTarget, height: touchTarget)
                    }

                    Image(systemName: category.iconName)
                        .font(.system(size: iconSize))
                        .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                }
                .frame(width: touchTarget, height: touchTarget)

                Text(category.shortName)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textTertiary)
            }
        }
        .buttonStyle(CategoryButtonStyle())
    }
}

struct CategoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.snappy(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Short name extension for categories

extension WeekCategory {
    var shortName: String {
        switch self {
        case .work: return "Work"
        case .health: return "Health"
        case .growth: return "Growth"
        case .relationships: return "Social"
        case .rest: return "Rest"
        case .adventure: return "Adventure"
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedCategory: WeekCategory? = .work

        var body: some View {
            VStack(spacing: 40) {
                CategoryPicker(selectedCategory: $selectedCategory)

                if let category = selectedCategory {
                    Text("Selected: \(category.displayName)")
                        .font(.title3)
                } else {
                    Text("No category selected")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.bgPrimary)
        }
    }

    return PreviewWrapper()
}
