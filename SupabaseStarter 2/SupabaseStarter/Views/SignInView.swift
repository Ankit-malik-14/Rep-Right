//
//  SignInView.swift
//  SupabaseStarter
//
//  Created by Shruti Sachdeva on 22/04/26.
//

import SwiftUI

struct SignInView: View {
    @State var email:String
    @State var password: String
    @Environment(AuthViewModel.self) var authViewModel
    
    var body: some View {
        Form {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
        }
        .onSubmit {
            authViewModel.signIn(email: email, password: password)
        }
    }
}

#Preview {
    SignInView(email: "some email", password: "some password")
        .environment(AuthViewModel())
}
