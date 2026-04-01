import SwiftUI

struct AppNameScreenView: View {
    @State private var isActive = false
    
    var body: some View {

        Image("RepRightIcon")
            .resizable()
            .scaledToFit()
            .frame(width: 300,height: 300,alignment: .center)
            .foregroundStyle(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .shadow(radius: 20)
    }
}
#Preview {
    AppNameScreenView()
}


