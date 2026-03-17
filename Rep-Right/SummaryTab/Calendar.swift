//
//  Calendar.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

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
