//
//  WorkoutRestView.swift
//  Rep-Right
//
//  Created by GU on 19/03/26.
//

import SwiftUI

struct WorkoutRestView: View {
    
    @State var isSetFinished: Bool = false
    
    var body: some View {
        ZStack{
            Color.blue
                .ignoresSafeArea()
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
                RestCardView(dismissSheet: $isSetFinished, isLastSet: true)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            
        }
        
    }
}

#Preview {
    WorkoutRestView()
}
