//
//  SupabaseStarterApp.swift
//  SupabaseStarter
//
//  Created by Shruti Sachdeva on 16/04/26.
//

import SwiftUI

@main
struct SupabaseStarterApp: App {
    @State var toDoTaskViewModel = ToDoTaskViewModel()
    @State var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.user == nil {
                SignInView(email: "", password: "")
                    .environment(authViewModel)
            } else {
                ToDoListView()
                    .environment(toDoTaskViewModel)
                    .environment(authViewModel)
            }
        }
    }
}
