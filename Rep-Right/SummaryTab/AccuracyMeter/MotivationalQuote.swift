//
//  MotivationalQuote.swift
//  Rep-Right
//
//  Created by GU on 17/03/26.
//

import SwiftUI

struct MotivationalQuote: View {
    
    @Binding var value : Double
    
    var quote: String {
        switch value {
        case 0...20:
            return "The hardest part is showing up. You've taken the first step."
        case 21...40:
            return "Focus on the form. Strength is built with patience and precision."
        case 41...60:
            return "You're finding your rhythm. Keep that momentum steady."
        case 61...80:
            return "The finish line is in sight. Stay sharp and push through."
        case 81...100:
            return "Exceptional work. You've mastered the movement today."
        default:
            return "Keep moving forward."
        }
    }

    var body: some View {
        VStack(alignment: .center) {
            Text(quote)
                .font(.title2)
                .fontWeight(.light)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

#Preview {
    @Previewable @State var value = 40.0
    MotivationalQuote(value: $value)
}
