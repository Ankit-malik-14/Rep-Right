//
//  WorkoutRestView.swift
//  Rep-Right
//
//  Created by GU on 19/03/26.
//

import SwiftUI

struct WorkoutRestView: View {
    
    //user clicks finish set, since the running workout will have the current exercise info we will compute the last set logic inside the  parent running workout view and pass the values here.
    
    // Required values 1) isLastSet of current running execise.
    // 2) next exercise info for passing info to NextExerciseCard
    
    @State var isSetFinished: Bool = false
    @State var isLastSet: Bool = false
    
    var body: some View {
        ZStack{
            //Color.blue
                //.ignoresSafeArea()
            //Text("Will be acting as sheet View for rest day")
            Button {
                isSetFinished.toggle()
            } label: {
                Label("Finish Set", systemImage: "checkmark")
                    .font(.title3.bold())
            }
            .foregroundStyle(.orange)
            .padding()
            .background(.gray.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
            .sheet(isPresented: $isSetFinished){
                RestCardView(dismissSheet: $isSetFinished, isLastSet: $isLastSet)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            
        }
        
    }
}

#Preview {
    WorkoutRestView()
}
