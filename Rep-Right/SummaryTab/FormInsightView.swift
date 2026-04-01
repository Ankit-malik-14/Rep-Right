import SwiftUI

struct FormInsightView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.5))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.primary)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Form Insight")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .bold()
                
                Text("Your depth on Barbell Squats improved by 12% in the last session. Keep hitting those 90° angles.")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    //.fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    FormInsightView()
}

