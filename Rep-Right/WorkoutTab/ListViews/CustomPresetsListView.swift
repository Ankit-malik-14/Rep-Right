//
//  CustomPresetsListView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPresetsListView: View {
    var preset: CustomPresetsDummyData
    @State var showAddSheet: Bool = false
    var body: some View {
       
            List{
                ForEach(preset.customPresets){ preset1 in
                    NavigationLink(value: WorkoutRoute.presetDetail(preset1)) {
                        HStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 80, height: 80)
                                .foregroundStyle(.background.secondary)
                            VStack(alignment: .leading){
                                Text(preset1.name)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
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
                    .buttonStyle(.plain)
                }
            }.listRowSpacing(10)
                .navigationTitle("Custom")
                

                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(role: .destructive){
                            showAddSheet=true
                        } label: {
                            Image(systemName: "plus")
                        }
                        Button{
                            //
                        }
                        label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
                .sheet(isPresented: $showAddSheet) {
                    CustomPresetAdditionView(isPresented: $showAddSheet)
                }

    }
}

#Preview {
    NavigationStack{
        CustomPresetsListView(preset: CustomPresetsDummyData())
            .environment(CustomPresetsDummyData())
    }
}
