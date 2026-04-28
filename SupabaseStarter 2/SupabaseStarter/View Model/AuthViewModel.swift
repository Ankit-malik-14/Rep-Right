//
//  AuthViewModel.swift
//  SupabaseStarter
//
//  Created by Shruti Sachdeva on 22/04/26.
//

import Foundation
import Supabase

@Observable
class AuthViewModel {
    var user: User?
    var supabaseManager = SupabaseManager.shared
    
    func signIn(email: String, password: String) {
        Task {
            do {
                try await supabaseManager.signIn(email: email, password: password)
                print("Successfully signed in")
                user = supabaseManager.currentUser
            } catch {
                print("Error signing in: \(error.localizedDescription)")
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await supabaseManager.signOut()
                print("User signed out successfully")
                user = nil
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    }
}
