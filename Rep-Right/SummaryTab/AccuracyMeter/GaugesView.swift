import SwiftUI

struct GaugesView: View {
    
   @Binding var value: Double

    var valueColor: Color {
        switch value {
        case 0..<40:
            return .red
        case 40..<75:
            return .orange
        case 75...100:
            return .green
        default:
            return .primary
        }
    }
    
    var body: some View {
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    //.background(.ultraThinMaterial)
                    .foregroundStyle(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    //.shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
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
    @Previewable @State var value = 30.0
    ZStack {
        Color.blue.opacity(0.3).ignoresSafeArea()
        GaugesView(value: $value )
    }
}
