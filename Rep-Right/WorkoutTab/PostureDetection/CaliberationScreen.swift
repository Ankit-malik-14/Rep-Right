//
//  CaliberationScreen.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 22/03/26.
//

import SwiftUI

struct CaliberationScreen: View {
    @State private var showSheet: Bool = false
    var body: some View {
        Button("Show") {
            showSheet = true
        }
        .sheet(isPresented: $showSheet){
            CaliberationSheetView()
                .presentationDetents([.custom(CustomDetents.self)])
        }
    }
}

struct CaliberationSheetView: View{
    @Environment(\.dismiss) private var dismiss
    var body: some View{
        VStack(alignment: .center){
            HStack{
                //hip height
                VStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width: 80, height: 90)
                        Image(systemName: "lines.measurement.vertical")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 50)
                    }
                    Text("Hip Height")
                        .font(.callout.bold())
                }
                .padding()
                
                //full body
                VStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width: 80, height: 90)
                        Image(systemName: "rectangle.dashed")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .rotationEffect(Angle(degrees: 90))
                        Image(systemName: "figure")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 30)
                    }
                    Text("Full body")
                        .font(.callout.bold())
                }
                
                .padding()
                
                //6-8 feet
                VStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width: 80, height: 90)
                        Image(systemName: "ruler")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    Text("6-8 feet")
                        .font(.callout.bold())
                }
                .padding()
            }
//            .padding()
            
            //Text information
            VStack{
                Text("Wear body hugging clothes for better accuracy")
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                    .padding()
                Text("For this exercise place camera facing front")
            }
            
            .padding(10)
            
            Text("Scanning Environment...")
                .bold()
            
                .padding(10)
                ContinueButton()
            
            
            Button("Cancel", role: .cancel) {
                dismiss()
            }.tint(.orange)
        } .padding()
    }
}

struct CustomDetents: CustomPresentationDetent{
    static func height(in context: Context) -> CGFloat? {
        context.maxDetentValue-250
    }
}
#Preview {
    CaliberationScreen()
}

