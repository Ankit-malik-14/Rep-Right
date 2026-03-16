//
//  CustomPreset.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPreset: View {
    var body: some View {
        VStack{
            HStack{
                Text("Custom")
                    .font(.largeTitle.bold())
                Spacer()
                Button("See all") {
                    //
                }.buttonStyle(.borderless)
                    .tint(.orange)
            }.padding()
            
            ScrollView(.horizontal){
                HStack{
                    ForEach(1...10,id: \.self){ i in
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.background.secondary)
                                .frame(width: 180,height: 160)
                            Text("Body part \(i)")
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    CustomPreset()
}
