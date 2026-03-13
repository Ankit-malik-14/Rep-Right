import SwiftUI

struct Recommendation: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.secondary.opacity(0.2))
                .frame(maxWidth: .infinity, maxHeight: 120)
                .padding()

            HStack(alignment: .center, spacing: 12) {

                Circle()
                    .fill(.orange)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello Check")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Subtitle ....")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    Recommendation()
}
