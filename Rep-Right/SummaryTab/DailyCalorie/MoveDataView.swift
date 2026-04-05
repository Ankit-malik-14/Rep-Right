//
//  MoveDataView.swift
//  Rep_Right
//
//  Created by GU on 01/04/26.
//

import SwiftUI

struct MoveDataView: View {
    @Binding var cal: Int
    //@Binding var goal: Int
    var body: some View {
        VStack(alignment: .leading){
            Text("Move")
                .font(.callout)
                .fontWeight(.light)
            HStack{
                Text("\(cal)/1000")
                //should be replaced with Text("\(cal)/\($goal)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                Text("CAL")
                    .font(.title3)
                    .fontWeight(.light)
            }
        }
        .padding()
    }
}
#Preview {
    @Previewable @State var calorie = 100
    MoveDataView(cal: $calorie)
}

