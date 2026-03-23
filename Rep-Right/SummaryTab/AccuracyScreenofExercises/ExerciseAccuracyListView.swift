import SwiftUI
struct ExerciseModel: Identifiable {
    let id = UUID()
    let name: String
    let targetMuscle: String
    let timeAgo: String
    let accuracy: Int
}

struct ExerciseAccuracyListView: View {
    //@Binding var value : value = .AccuracyMeterView
    @State private var exercises: [ExerciseModel] = [
        ExerciseModel(name: "Deadlift", targetMuscle: "Back", timeAgo: "Yesterday", accuracy: 32)
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(exercises) { exercise in
                        ZStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 12) {
                                        Text(exercise.targetMuscle)
                                        Text(exercise.timeAgo)
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(exercise.accuracy)%")
                                    .font(.headline)
                                    .foregroundStyle(.orange)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.orange)
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(.vertical, 4)
                            NavigationLink(destination: AccuracyMeterView(value: 32.0)) {
                                EmptyView()
                            }
                            .opacity(0.01)
                        }
                    }
                } header: {
                    Text("Last Week")
                        .textCase(.none)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Exercise History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ExerciseAccuracyListView()
}
