//
//  MoveDataView.swift
//  Rep_Right
//
//  Created by GU on 01/04/26.
//

import SwiftUI

struct MoveDataView: View {
    @State private var cal = 100
    var body: some View {
        VStack(alignment: .leading){
            Text("Move")
                .font(.callout)
                .fontWeight(.light)
            HStack{
                Text("\(cal)/1000")
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
    MoveDataView()
}
