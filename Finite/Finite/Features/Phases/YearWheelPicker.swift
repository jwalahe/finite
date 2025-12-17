//
//  YearWheelPicker.swift
//  Finite
//
//  Dual year wheel picker for phase start/end year selection
//

import SwiftUI

struct YearWheelPicker: View {
    @Binding var startYear: Int
    @Binding var endYear: Int

    let minYear: Int  // User's birth year
    let maxYear: Int  // Current year

    var body: some View {
        HStack(spacing: 32) {
            // Start Year Picker
            VStack(spacing: 8) {
                Text("From")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)

                Picker("Start Year", selection: $startYear) {
                    ForEach(minYear...maxYear, id: \.self) { year in
                        Text(String(year))
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100, height: 150)
                .clipped()
                .onChange(of: startYear) { oldValue, newValue in
                    HapticService.shared.selection()
                    // Ensure end year is not before start year
                    if endYear < newValue {
                        endYear = newValue
                    }
                }
            }

            // "to" label
            Text("to")
                .font(.body)
                .foregroundStyle(Color.textSecondary)
                .padding(.top, 24)

            // End Year Picker
            VStack(spacing: 8) {
                Text("To")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)

                Picker("End Year", selection: $endYear) {
                    ForEach(startYear...maxYear, id: \.self) { year in
                        Text(String(year))
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100, height: 150)
                .clipped()
                .onChange(of: endYear) { oldValue, newValue in
                    HapticService.shared.selection()
                }
            }
        }
    }
}

// MARK: - Single Year Picker (for reuse)

struct SingleYearPicker: View {
    let title: String
    @Binding var selectedYear: Int
    let years: ClosedRange<Int>

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            Picker(title, selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(String(year))
                        .tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100, height: 150)
            .clipped()
            .onChange(of: selectedYear) { _, _ in
                HapticService.shared.selection()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var start = 2010
    @Previewable @State var end = 2014

    VStack {
        YearWheelPicker(
            startYear: $start,
            endYear: $end,
            minYear: 1995,
            maxYear: 2025
        )

        Text("Selected: \(start) - \(end)")
            .padding(.top, 24)
    }
    .padding()
    .background(Color.bgPrimary)
}
