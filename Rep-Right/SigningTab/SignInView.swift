import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var pass = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            
            Text("Sign In")
                .font(.system(size: 40, weight: .bold))
                .padding(.bottom, 20)
            
            
            VStack(spacing: 16) {
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.primary)
                        .frame(width: 30)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                       // .textInputAutocapitalization(.never)
                        //.autocorrectionDisabled(true)
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(12)
                
               
                HStack {
                    
                    Image(systemName: "lock.fill")
                        .foregroundColor(.primary)
                        .frame(width: 30)
                    if pass {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                    Button {
                        pass.toggle()
                    } label: {
                        //TextField("",text: $password)
                        if pass {
                            Image(systemName: "eye.fill")
                            
                            } else {
                            Image(systemName: "eye.slash.fill")
                            }
                    }.foregroundStyle(.primary)
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(12)
                
            }
            .padding(.horizontal, 24)
            
            Button(action: {
                
                print("Attempting to sign in with: \(email)")
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
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
            .foregroundColor(.secondary)
            .padding(.top, 8)
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    SignInView()
}

