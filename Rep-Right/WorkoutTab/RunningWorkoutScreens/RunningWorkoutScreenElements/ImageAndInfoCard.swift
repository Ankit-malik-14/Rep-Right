//
//  ImageAndInfoCard.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 19/03/26.
//

import SwiftUI

struct ImageAndInfoCard: View {
    var body: some View {
        ZStack(alignment: .bottom){
            //image
            RoundedRectangle(cornerRadius: 30)
                .frame(maxWidth: .infinity, maxHeight: 300)
                .glassEffect(.identity, in: .rect(cornerRadius: 40))
                .padding()
            
            //Info card
            //ZStack{
                RoundedRectangle(cornerRadius: 40)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 180)
                    .padding()
                    .foregroundStyle(.background.secondary)
                    .overlay{
                        //VSTack for name set and weight
                        VStack(alignment: .leading,spacing: 3){
                            Text("Deadlift")
                                .font(.largeTitle)
                                .bold()
                            //hstack for set and veight
                            HStack{
                                //set and set number
                                VStack{
                                    Text("Sets")
                                        .font(.callout.bold())
                                        .foregroundStyle(.secondary)
                                    Text("3/4")
                                        .font(.title.bold())
                                }//end of vstack set and set number
                                
                                Spacer()
                                
                                //weight
                                VStack{
                                    Text("Weight")
                                        .font(.callout.bold())
                                        .foregroundStyle(.secondary)
                                    Text("60 kg")
                                        .font(.title.bold())
                                }//end of vstack weight
                                
                            }.padding()
                        }.padding(50)
                    }
            //}
        }
    }
}

#Preview {
    ImageAndInfoCard()
}
