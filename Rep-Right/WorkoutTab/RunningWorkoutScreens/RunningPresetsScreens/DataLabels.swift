//
//  DataLabels.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 19/03/26.
//

import SwiftUI

struct DataLabels: View {
    var body: some View {
        LazyHGrid(rows: [GridItem(.flexible())], alignment: .center, spacing: 20) {
            //timer
            Label {
                Text("18.42")
            } icon: {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
            }
            .padding(10)
            .background(.secondary.opacity(0.2))
            .clipShape(.capsule)
            
            
            //Progress
            Label {
                Text("75 %")
            } icon: {
                Image(systemName: "chart.bar.horizontal.page.fill")
                    .foregroundStyle(.orange)
            }
            .padding(10)
            .background(.secondary.opacity(0.2))
            .clipShape(.capsule)
            
            //Calories
            Label {
                Text("456")
            } icon: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }
            .padding(10)
            .background(.secondary.opacity(0.2))
            .clipShape(.capsule)
            
        }.frame(maxHeight: 50)
    }
}

#Preview {
    DataLabels()
}
