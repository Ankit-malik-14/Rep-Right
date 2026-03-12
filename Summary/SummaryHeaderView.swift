import SwiftUI

struct SummaryHeaderView: View {
    var body: some View {
        HStack {
            Text("Summary")
                .font(.system(size: 32, weight: .bold))

            Spacer()
            
            Button(action: {}) {
                Image(systemName: "person.circle")
                    .font(.system(size: 28))
                    .foregroundStyle(.black)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    SummaryHeaderView()
}
