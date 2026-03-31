import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .padding(.bottom, 20)
            
            
            VStack(spacing: 16) {
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.gray)
                        .frame(width: 30)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding()
                .background(.gray.opacity(0.3))
                .cornerRadius(12)
                
               
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.gray)
                        .frame(width: 30)
                    SecureField("Password", text: $password)
                }
                .padding()
                .background(.gray.opacity(0.3))
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            
            
            Button(action: {
                
                print("Attempting to sign in with: \(email)")
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            
           
            Button("Forgot Password?") {
                // Action here
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    SignInView()
}

