//
//  LifeExpectancySheet.swift
//  Finite
//
//  Picker sheet for setting life expectancy
//  Philosophy: This is a philosophical moment - user declares how long they expect to live
//

import SwiftUI

struct LifeExpectancySheet: View {
    @Binding var lifeExpectancy: Int
    @Environment(\.dismiss) private var dismiss

    // Local state for picker
    @State private var selectedValue: Int

    init(lifeExpectancy: Binding<Int>) {
        self._lifeExpectancy = lifeExpectancy
        self._selectedValue = State(initialValue: lifeExpectancy.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Week count - the philosophical weight
                Text("\(selectedValue * 52)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.15), value: selectedValue)

                Text("weeks")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                Spacer()

                // Wheel picker
                Picker("Years", selection: $selectedValue) {
                    ForEach(60...120, id: \.self) { age in
                        Text("\(age) years").tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .onChange(of: selectedValue) { _, _ in
                    HapticService.shared.selection()
                }

                Spacer()
            }
            .padding(24)
            .background(Color.bgPrimary)
            .navigationTitle("Expected Lifespan")
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
                        lifeExpectancy = selectedValue
                        HapticService.shared.medium()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    LifeExpectancySheet(lifeExpectancy: .constant(80))
}
