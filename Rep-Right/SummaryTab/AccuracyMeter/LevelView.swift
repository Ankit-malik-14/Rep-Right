//
//  LevelView.swift
//  Rep-Right
//
//  Created by GU on 17/03/26.
//

import SwiftUI

struct LevelView: View {
    @Binding var value : Double
    var quote: String {
        switch value {
        case 0..<35:
            return "Danger"
        case 35..<69:
            return "Cautious"
        case 69...100:
            return "Perfect"
        default:
            return "Keep moving forward."
        }
    }
    
    var quoteColor: Color {
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
        VStack(alignment: .center) {
            HStack(spacing: 20){
                Text("Accuracy")
                    .fontWeight(.bold)
                    .font(.title2)
                Text(quote)
                    .fontWeight(.light)
                    .font(.title2)
                    .foregroundStyle(quoteColor)
                    .multilineTextAlignment(.center)
            }
            
        }
    }
}
#Preview {
    @Previewable @State var value = 40.0
    LevelView(value: $value)
}
