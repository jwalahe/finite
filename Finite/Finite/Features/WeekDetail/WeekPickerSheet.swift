//
//  WeekPickerSheet.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/16/25.
//

import SwiftUI
import SwiftData

struct WeekPickerSheet: View {
    let user: User
    let weeks: [Week]
    let onWeekSelected: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var selectedYear: Int
    @State private var selectedWeekOfYear: Int = 1

    private let weeksPerYear = 52

    init(user: User, weeks: [Week], onWeekSelected: @escaping (Int) -> Void) {
        self.user = user
        self.weeks = weeks
        self.onWeekSelected = onWeekSelected

        // Start at current year
        let currentYear = user.currentWeekNumber / 52
        _selectedYear = State(initialValue: currentYear)
    }

    // Years lived (0-indexed: Year 0, Year 1, etc.)
    private var yearsLived: Int {
        user.yearsLived
    }

    // Convert year + week to absolute week number
    private var absoluteWeekNumber: Int {
        selectedYear * weeksPerYear + selectedWeekOfYear
    }

    // Check if selected week is valid (lived)
    private var isValidSelection: Bool {
        absoluteWeekNumber >= 1 && absoluteWeekNumber <= user.weeksLived
    }

    // Get rating for a week if it exists
    private func ratingFor(weekNumber: Int) -> Int? {
        weeks.first { $0.weekNumber == weekNumber }?.rating
    }

    // Date range for selected week
    private var weekDateRange: String {
        let calendar = Calendar.current
        let startOfLife = calendar.startOfDay(for: user.birthDate)

        guard let weekStart = calendar.date(byAdding: .day, value: (absoluteWeekNumber - 1) * 7, to: startOfLife),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return "\(formatter.string(from: weekStart)) – \(formatter.string(from: weekEnd))"
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 4) {
                Text("Select a Week")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)

                Text("Tap the grid or choose below")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.top, 8)

            // Pickers
            HStack(spacing: 16) {
                // Year picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Year")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)

                    Picker("Year", selection: $selectedYear) {
                        ForEach(0...yearsLived, id: \.self) { year in
                            Text("Year \(year + 1)")
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                }
                .frame(maxWidth: .infinity)

                // Week picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Week")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)

                    Picker("Week", selection: $selectedWeekOfYear) {
                        ForEach(1...weeksPerYear, id: \.self) { week in
                            let weekNum = selectedYear * weeksPerYear + week
                            let isLived = weekNum <= user.weeksLived

                            HStack {
                                Text("Week \(week)")
                                if let rating = ratingFor(weekNumber: weekNum) {
                                    Circle()
                                        .fill(Color.ratingColor(for: rating))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .foregroundStyle(isLived ? Color.textPrimary : Color.textTertiary)
                            .tag(week)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)

            // Selected week preview
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    // Week indicator
                    if isValidSelection {
                        Circle()
                            .fill(ratingFor(weekNumber: absoluteWeekNumber).map { Color.ratingColor(for: $0) } ?? Color.gridFilled)
                            .frame(width: 24, height: 24)
                    } else {
                        Circle()
                            .stroke(Color.textTertiary, lineWidth: 1)
                            .frame(width: 24, height: 24)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Week \(absoluteWeekNumber.formatted())")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(isValidSelection ? Color.textPrimary : Color.textTertiary)

                        if isValidSelection {
                            Text(weekDateRange)
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        } else {
                            Text("Not yet lived")
                                .font(.caption)
                                .foregroundStyle(Color.textTertiary)
                        }
                    }

                    Spacer()

                    if isValidSelection {
                        if ratingFor(weekNumber: absoluteWeekNumber) != nil {
                            Text("Marked")
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.bgTertiary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(16)
                .background(Color.bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)

            Spacer()

            // Action buttons
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(ScaleButtonStyle())

                Button {
                    if isValidSelection {
                        HapticService.shared.light()
                        onWeekSelected(absoluteWeekNumber)
                    }
                } label: {
                    Text("Select")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isValidSelection ? Color.textPrimary : Color.textTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(!isValidSelection)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.vertical)
        .background(Color.bgPrimary)
        .onChange(of: selectedYear) { _, newYear in
            // Adjust week if it's beyond what's lived in the new year
            let maxWeekInYear = min(weeksPerYear, user.weeksLived - newYear * weeksPerYear)
            if selectedWeekOfYear > maxWeekInYear && maxWeekInYear > 0 {
                selectedWeekOfYear = maxWeekInYear
            }
            HapticService.shared.selection()
        }
        .onChange(of: selectedWeekOfYear) { _, _ in
            HapticService.shared.selection()
        }
    }
}

#Preview {
    @Previewable @State var user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)

    WeekPickerSheet(user: user, weeks: []) { weekNumber in
        print("Selected week: \(weekNumber)")
    }
}
