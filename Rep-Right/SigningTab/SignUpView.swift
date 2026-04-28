import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()

                    HStack {
                        Group {
                            if isPasswordVisible {
                                TextField("Create Password", text: $password)
                            } else {
                                SecureField("Create Password", text: $password)
                            }
                        }
                        .textContentType(.newPassword)

                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                } footer: {
                    Text("Your password must be at least 8 characters long.")
                }

                Section {
                    Button {
                        print("Attempting to sign up with: \(email)")
                    } label: {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Sign Up")
        }
    }
}

#Preview {
    SignUpView()
}
