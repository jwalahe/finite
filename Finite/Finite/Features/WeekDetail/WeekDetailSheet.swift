//
//  WeekDetailSheet.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/16/25.
//

import SwiftUI
import SwiftData

struct WeekDetailSheet: View {
    let user: User
    let weekNumber: Int
    let existingWeek: Week?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Query existing weeks to detect first rating
    @Query private var allWeeks: [Week]

    @State private var rating: Int
    @State private var selectedCategory: WeekCategory?
    @State private var phrase: String

    private let ratingLabels = ["Awful", "Hard", "Okay", "Good", "Great"]

    /// True if this will be the user's first ever week rating
    private var isFirstRating: Bool {
        allWeeks.isEmpty && existingWeek == nil
    }

    init(user: User, weekNumber: Int, existingWeek: Week?) {
        self.user = user
        self.weekNumber = weekNumber
        self.existingWeek = existingWeek

        // Initialize state from existing week or defaults
        _rating = State(initialValue: existingWeek?.rating ?? 3)
        _selectedCategory = State(initialValue: existingWeek?.category)
        _phrase = State(initialValue: existingWeek?.phrase ?? "")
    }

    // Calculate the date range for this week
    private var weekDateRange: String {
        let calendar = Calendar.current
        let startOfLife = calendar.startOfDay(for: user.birthDate)

        // Calculate start of this week (weekNumber is 1-indexed)
        guard let weekStart = calendar.date(byAdding: .day, value: (weekNumber - 1) * 7, to: startOfLife) else {
            return ""
        }
        guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let startStr = formatter.string(from: weekStart)

        // Check if same month
        let startMonth = calendar.component(.month, from: weekStart)
        let endMonth = calendar.component(.month, from: weekEnd)

        if startMonth == endMonth {
            formatter.dateFormat = "d, yyyy"
            let endStr = formatter.string(from: weekEnd)
            return "\(startStr)–\(endStr)"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
            let endStr = formatter.string(from: weekEnd)
            return "\(startStr) – \(endStr)"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 4) {
                Text("Week \(weekNumber.formatted())")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)

                Text(weekDateRange)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.top, 8)

            // Spectrum Slider
            VStack(spacing: 12) {
                SpectrumSlider(rating: $rating)

                // Rating labels
                HStack {
                    ForEach(0..<5) { index in
                        Text(ratingLabels[index])
                            .font(.system(size: 11))
                            .foregroundStyle(rating == index + 1 ? Color.textPrimary : Color.textTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 8)

            // Category Picker
            CategoryPicker(selectedCategory: $selectedCategory)

            // Phrase Input
            VStack(alignment: .leading, spacing: 8) {
                TextField("One line about this week...", text: $phrase, axis: .vertical)
                    .lineLimit(2)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(12)
                    .background(Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Spacer()

            // Done Button
            Button(action: saveAndDismiss) {
                Text("Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.bgPrimary) // Inverts with background for contrast
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(24)
        .background(Color.bgPrimary)
    }

    private func saveAndDismiss() {
        // Capture first rating status BEFORE saving
        let wasFirstRating = isFirstRating

        // Create or update week
        if let existingWeek = existingWeek {
            existingWeek.rating = rating
            existingWeek.category = selectedCategory
            existingWeek.phrase = phrase.isEmpty ? nil : phrase
            existingWeek.markedAt = Date()
        } else {
            let newWeek = Week(weekNumber: weekNumber)
            newWeek.rating = rating
            newWeek.category = selectedCategory
            newWeek.phrase = phrase.isEmpty ? nil : phrase
            newWeek.markedAt = Date()
            modelContext.insert(newWeek)
        }

        // Haptic feedback on confirm
        HapticService.shared.medium()

        dismiss()

        // SST §18.2: Trigger share prompt after first rating
        // "Fresh Start Effect. Beginning = share trigger."
        if wasFirstRating {
            ShareFlowController.shared.onFirstWeekRated()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Week.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    return WeekDetailSheet(user: user, weekNumber: 1547, existingWeek: nil)
        .modelContainer(container)
}
