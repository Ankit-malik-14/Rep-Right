//
//  CustomPresetsListView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPresetsListView: View {
    var preset: CustomPresetsDumyData
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
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(role: .destructive){
                            //
                        } label: {
                            Image(systemName: "trash")
                        }
                        Button{
                            //
                        }
                        label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
    }
}

#Preview {
    NavigationStack{
        CustomPresetsListView(preset: CustomPresetsDumyData())
            .environment(CustomPresetsDumyData())
    }
}
