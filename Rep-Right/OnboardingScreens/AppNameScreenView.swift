import SwiftUI

struct AppNameScreenView: View {
    @State private var isActive = false
    
    var body: some View {

        Image("RepRightIcon")
            .resizable()
            .scaledToFit()
            .frame(width: 200,height: 200,alignment: .center)
            .foregroundStyle(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .shadow(radius: 10)
    }
}
#Preview {
    AppNameScreenView()
}


