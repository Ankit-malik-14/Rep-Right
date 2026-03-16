//
//  CustomPresetsListView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPresetsListView: View {
    var body: some View {
        List{
            ForEach(1...5, id: \.self){ i in
            HStack{
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.background.secondary)
                VStack(alignment: .leading){
                    Text("Custom \(i)")
                        .font(.title2)
                    Text("Arms-shoulder")
                        .font(.caption)
                }
            }
        }
        }.listRowSpacing(10)
            .navigationTitle("Custom")
    }
}

#Preview {
    CustomPresetsListView()
}
