import SwiftUI

struct GaugesView: View {
    
   @Binding var value: Double

    var valueColor: Color {
        switch value {
        case 0..<35:
            return .red
        case 35..<69:
            return .orange
        case 69...100:
            return .green
        default:
            return .primary
        }
    }
    
    var body: some View {
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .frame(height: 250)
                    .padding(.horizontal)
                Gauge(value:value, in: 0...100) {
                }
                .gaugeStyle(.accessoryCircular)
                .tint(
                    Gradient(colors: [
                        .red,
                        .yellow,
                        .green
                    ])
                )
                .scaleEffect(3.5)
                
                Text("\(Int(value))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(valueColor)
                
            }

        }
    
    }
}


#Preview {
    @Previewable @State var value = 75.0
    ZStack {
        Color.blue.opacity(0.3).ignoresSafeArea()
        GaugesView(value: $value )
    }
}
