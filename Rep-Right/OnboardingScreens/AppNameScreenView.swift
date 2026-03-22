import SwiftUI

struct AppNameScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        VStack {
            ZStack{
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: 300,height: 300,alignment: .center)
                    .foregroundStyle(.ultraThinMaterial)
                VStack{
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200,height: 200)
                        .foregroundStyle(.orange)
                        .padding()
                    Text("Rep Right")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}
    #Preview {
        AppNameScreenView()
    }


