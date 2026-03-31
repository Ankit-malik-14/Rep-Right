import SwiftUI

struct FormInsightView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.black)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Form Insight")
                    .font(.headline)
                    .bold()
                
                Text("Your depth on Barbell Squats improved by 12% in the last session. Keep hitting those 90° angles.")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial.opacity(0.5),in: RoundedRectangle(cornerRadius: 20))
//        .background(
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color.gray.opacity(0.1))
//        )
        .padding(.horizontal)
    }
}

#Preview {
    FormInsightView()
}

