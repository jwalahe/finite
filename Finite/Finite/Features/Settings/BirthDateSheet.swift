//
//  BirthDateSheet.swift
//  Finite
//
//  Picker sheet for changing birth date
//  Note: This is rare - most users set once and forget
//

import SwiftUI

struct BirthDateSheet: View {
    @Binding var birthDate: Date
    @Environment(\.dismiss) private var dismiss

    // Local state for picker
    @State private var selectedDate: Date

    init(birthDate: Binding<Date>) {
        self._birthDate = birthDate
        self._selectedDate = State(initialValue: birthDate.wrappedValue)
    }

    // Calculate weeks lived for the selected date
    private var weeksLived: Int {
        let days = Calendar.current.dateComponents([.day], from: selectedDate, to: Date()).day ?? 0
        return (days / 7) + 1
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Weeks lived counter
                VStack(spacing: 4) {
                    Text("\(weeksLived)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.15), value: weeksLived)

                    Text("weeks lived")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.top, 16)

                // Date picker
                DatePicker(
                    "Birth Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color.textPrimary)

                Spacer()
            }
            .padding(24)
            .background(Color.bgPrimary)
            .navigationTitle("Birth Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        birthDate = selectedDate
                        HapticService.shared.medium()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    BirthDateSheet(birthDate: .constant(Calendar.current.date(byAdding: .year, value: -30, to: Date())!))
}
