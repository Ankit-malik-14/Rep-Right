//
//  Calendar.swift
//  Summary
//
//  Created by apple on 13/03/26.
//

import SwiftUI
// Basic Template for calendar
struct Calendar: View {
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            DatePicker(
                "Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.wheel)
            .padding()
        }
    }
}

#Preview {
    Calendar()
}
