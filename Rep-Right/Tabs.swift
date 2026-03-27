//
//  Tabs.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 17/03/26.
//

import SwiftUI

struct Tabs: View {
    var body: some View {
        TabView {
            Tab("home", image:"") {
                WorkoutScreen()
            }
            Tab("Summary", image: "") {
                SummaryTabView()
            }
        }

    }
}
#Preview {
    Tabs()
}
