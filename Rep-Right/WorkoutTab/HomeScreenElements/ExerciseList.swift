//
//  ExerciseList.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct ExerciseList: View {
    @State private var isDetectable: Bool = false
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("Exercises")
                    .font(.largeTitle.bold())
                    .padding()
                Spacer()
                Button("See all") {
                    //
                }.tint(.orange)
                .padding()
            }
            List{
                ForEach(0...7, id: \.self){ i in
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.background.secondary)
                        VStack(alignment: .leading){
                            Text("Exercise name")
                            Text("Description")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
//                        Spacer()
//                        isDetectable ? Image(systemName: "camera.viewfinder") : Image(systemName:"")
                    }
                }
            }.listRowSpacing(23)
        }
    }
}

#Preview {
    ExerciseList()
}
