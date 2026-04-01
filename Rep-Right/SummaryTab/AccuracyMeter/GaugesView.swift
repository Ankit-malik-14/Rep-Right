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
                    .foregroundStyle(.ultraThinMaterial)
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

        GaugesView(value: $value)
}
