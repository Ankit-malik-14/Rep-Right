//
//  ViewStore.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-23.
//

import SwiftUI

//MARK: - Data types
enum assistanceTagType{
    case icon
    case text
    case iconAndText
}
enum PresetViewType {
    case large
    case small
}

//MARK: - Assistance Availability Indicator

@ViewBuilder
func assisstanceAvailablityTag(type: assistanceTagType) -> some View{
    switch type{
    case .icon:
        ZStack{
            Circle()
                .frame(width: 30)
                .foregroundStyle(.orange.opacity(0.8))
            Image(systemName: "camera.viewfinder")
                .foregroundStyle(.white)
        }
    case .text:
        Text("AI Assistance")
            .font(.footnote)
            .padding(8)
            .bold()
            .foregroundStyle(.white)
            .background {
                Capsule()
                    .foregroundStyle(.orange)
            }
    case .iconAndText:
        HStack{
            Image(systemName: "camera.viewfinder")
            Text("AI Assistance")
                .font(.footnote)
                .bold()
        }.foregroundStyle(.orange)
            .padding(8)
            .background(Capsule().foregroundStyle(.background.tertiary))
    }
}

//MARK: - Preset View maker

struct PresetTileViewType: View {
    var preset: Preset
    var type: PresetViewType
    var body: some View {
        switch type {
        case .large:
            ZStack(alignment: .topLeading){
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 160, height: 185)
                    .foregroundStyle(.background.secondary)
                Text(preset.name).padding()
            }
        case .small:
            HStack(alignment: .center){
                //Image Placeholder
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 67, height: 64)
                    .foregroundStyle(.background.secondary)
                    .padding(6)
                VStack(alignment: .leading){
                    Text(preset.name)
                        .font(.headline)
                    HStack{
                        Text(arrayToString(arrayOfStrings: preset.focousArea))
                        
                        Text("•")
                        Text("\(preset.exercises.count) Exercises")
                    }.font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
            }/*.background(.background.secondary,in: RoundedRectangle(cornerRadius: 20)).padding(.horizontal)*/
        }
        
    }
}

//MARK: - CONTINUE BUTTON
struct ContinueButton: View{
    var body: some View{
        Button {
            //
        } label: {
            ZStack{
                RoundedRectangle(cornerRadius: 40)
                    .frame(maxWidth: .infinity, maxHeight: 70)
                Text("Continue")
                    .font(.title3)
                    .foregroundStyle(.white)
            }.padding()
        }.tint(.orange)
    }
}

        
//MARK: - View Testing
struct ViewStore: View {
    var body: some View {
        assisstanceAvailablityTag(type: .iconAndText)
        PresetTileViewType(preset: Presets().presets[0], type: .small)
        ContinueButton()
    }
}


#Preview {
    ViewStore()
}
