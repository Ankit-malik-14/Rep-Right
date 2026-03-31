//
//  CustomPresetsListView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPresetsListView: View {
    var preset: CustomPresetsDummyData
    var body: some View {
       
            List{
                ForEach(preset.customPresets){ preset1 in
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.background.secondary)
                        VStack(alignment: .leading){
                            Text(preset1.name)
                            HStack{
                                ForEach(preset1.focousArea, id: \.self) { area in
                                    Text(area)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }.listRowSpacing(10)
                .navigationTitle("Custom")
                

        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //
                } label: {
                    Text("Edit")
                }.buttonStyle(.bordered)
                    .foregroundStyle(.orange)

            }
    }
    }
}

#Preview {
    NavigationStack{
        CustomPresetsListView(preset: CustomPresetsDummyData())
            .environment(CustomPresetsDummyData())
    }
}
