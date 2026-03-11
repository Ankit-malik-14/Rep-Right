//
//  CustomPreset.swift
//  RepRight
//
//  Created by Mayurakshi Das on 11/03/26.
//

import SwiftUI

struct CustomPreset: View {
    var body: some View {
        ScrollView(.horizontal){
            HStack{
                ForEach(1...10, id: \.self){ i in
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 150, height: 120)
                            .foregroundStyle(.background.secondary)
                        Text("Custom \(i)")
                    }
                }
            }
        }.scrollIndicators(.hidden)
            .navigationTitle("Custom Preset")
        
    }
}

#Preview {
    CustomPreset()
}
