//
//  ExerciseList.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct ExerciseList: View {
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
                            HStack(alignment: .center){
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 70, height: 70)
                                    .foregroundStyle(.background.secondary)
                                VStack(alignment: .leading){
                                    Text("Exercise name")
                                        .font(.title2)
                                    Text("Description")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                
                            }
                        }
                    
                }.listRowSpacing(10)
        }
    }
}

#Preview {
    ExerciseList()
}
