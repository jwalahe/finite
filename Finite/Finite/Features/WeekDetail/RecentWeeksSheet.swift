//
//  RecentWeeksSheet.swift
//  Finite
//
//  Shows the current week + last few weeks for easy marking.
//  Designed for the weekly ritual - not for browsing history.
//

import SwiftUI
import SwiftData

struct RecentWeeksSheet: View {
    let user: User
    let weeks: [Week]
    let onWeekSelected: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    private let weeksToShow = 4 // Current + 3 previous

    private var currentWeekNumber: Int { user.currentWeekNumber }

    // Get the weeks to display (current + recent)
    private var recentWeekNumbers: [Int] {
        let start = max(1, currentWeekNumber - weeksToShow + 1)
        return Array(start...currentWeekNumber).reversed() // Current first
    }

    // Get week data
    private func weekData(for weekNumber: Int) -> Week? {
        weeks.first { $0.weekNumber == weekNumber }
    }

    // Calculate date range for a week
    private func dateRange(for weekNumber: Int) -> String {
        let calendar = Calendar.current
        let startOfLife = calendar.startOfDay(for: user.birthDate)

        guard let weekStart = calendar.date(byAdding: .day, value: (weekNumber - 1) * 7, to: startOfLife),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startStr = formatter.string(from: weekStart)

        let startMonth = calendar.component(.month, from: weekStart)
        let endMonth = calendar.component(.month, from: weekEnd)

        if startMonth == endMonth {
            formatter.dateFormat = "d"
            return "\(startStr)–\(formatter.string(from: weekEnd))"
        } else {
            return "\(startStr) – \(formatter.string(from: weekEnd))"
        }
    }

    // Label for week
    private func weekLabel(for weekNumber: Int) -> String {
        if weekNumber == currentWeekNumber {
            return "This Week"
        } else if weekNumber == currentWeekNumber - 1 {
            return "Last Week"
        } else {
            let weeksAgo = currentWeekNumber - weekNumber
            return "\(weeksAgo) weeks ago"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 4) {
                Text("Mark a Week")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)

                Text("Reflect on your recent time")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.top, 8)

            // Week list
            VStack(spacing: 12) {
                ForEach(recentWeekNumbers, id: \.self) { weekNumber in
                    WeekRow(
                        weekNumber: weekNumber,
                        label: weekLabel(for: weekNumber),
                        dateRange: dateRange(for: weekNumber),
                        rating: weekData(for: weekNumber)?.rating,
                        isCurrent: weekNumber == currentWeekNumber
                    ) {
                        HapticService.shared.light()
                        onWeekSelected(weekNumber)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            // Cancel button
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
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.vertical)
        .background(Color.bgPrimary)
    }
}

// MARK: - Week Row

struct WeekRow: View {
    let weekNumber: Int
    let label: String
    let dateRange: String
    let rating: Int?
    let isCurrent: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Week indicator circle
                ZStack {
                    if let rating = rating {
                        Circle()
                            .fill(Color.ratingColor(for: rating))
                            .frame(width: 40, height: 40)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .stroke(isCurrent ? Color.weekCurrent : Color.textTertiary, lineWidth: 2)
                            .frame(width: 40, height: 40)

                        if isCurrent {
                            Circle()
                                .fill(Color.weekCurrent)
                                .frame(width: 12, height: 12)
                        }
                    }
                }

                // Week info
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 17, weight: isCurrent ? .semibold : .medium))
                        .foregroundStyle(Color.textPrimary)

                    Text(dateRange)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
            .background(isCurrent ? Color.bgSecondary : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if !isCurrent {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.border, lineWidth: 1)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    @Previewable @State var user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)

    RecentWeeksSheet(user: user, weeks: []) { weekNumber in
        print("Selected week: \(weekNumber)")
    }
}
