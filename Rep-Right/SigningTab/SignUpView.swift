import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            Text("Sign Up")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.bottom, 20)
            
            
            VStack(spacing: 16) {
               
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.primary)
                        .frame(width: 30)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        //.textInputAutocapitalization(.never)
                        //.autocorrectionDisabled(true)
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(12)
                
              
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.primary)
                        .frame(width: 30)
                    
                    SecureField("Create Password", text: $password)
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            
            
            Button(action: {
                
                print("Attempting to sign in with: \(email)")
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    SignUpView()
}
