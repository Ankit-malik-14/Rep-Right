//
//  ViewStore.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-23.
//

import SwiftUI

//MARK: - Data types
enum assistanceTagType{
    case icon
    case text
    case iconAndText
}
enum PresetViewType {
    case large
    case small
}

enum AppCardMetrics {
    static let cornerRadius: CGFloat = 20
    static let tileHeight: CGFloat = 185
    static let tileWidth: CGFloat = 168
    static let compactCornerRadius: CGFloat = 16
}

struct AppCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppCardMetrics.cornerRadius, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCardMetrics.cornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            }
    }
}

struct AppPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.orange.opacity(configuration.isPressed ? 0.82 : 1))
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

extension View {
    func appCardStyle() -> some View {
        modifier(AppCardModifier())
    }
}

//MARK: - Assistance Availability Indicator

@ViewBuilder
func assisstanceAvailablityTag(type: assistanceTagType) -> some View{
    switch type{
    case .icon:
        ZStack{
            Circle()
                .frame(width: 30)
                .foregroundStyle(.orange.opacity(0.8))
            Image(systemName: "camera.viewfinder")
                .foregroundStyle(.white)
        }
    case .text:
        Text("AI Assistance")
            .font(.footnote)
            .padding(8)
            .bold()
            .foregroundStyle(.white)
            .background {
                Capsule()
                    .foregroundStyle(.orange)
            }
    case .iconAndText:
        HStack{
            Image(systemName: "camera.viewfinder")
            Text("AI Assistance")
                .font(.footnote)
                .bold()
        }.foregroundStyle(.orange)
            .padding(8)
            .background(Capsule().foregroundStyle(.background.tertiary))
    }
}

//MARK: - Preset View maker

struct PresetTileViewType: View {
    var preset: Preset
    var type: PresetViewType
    var showsSelection: Bool = false
    var isSelected: Bool = false
    var body: some View {
        switch type {
        case .large:
            ZStack(alignment: .topLeading){
                Group {
                    if let imageName = preset.image {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.background.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: AppCardMetrics.tileHeight)
                .clipShape(RoundedRectangle(cornerRadius: AppCardMetrics.cornerRadius))

                LinearGradient(
                    colors: [.black.opacity(0.08), .black.opacity(0.45)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: AppCardMetrics.cornerRadius))

                VStack(alignment: .leading, spacing: 8) {
                    if showsSelection {
                        HStack {
                            Spacer()
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(isSelected ? .orange : .white.opacity(0.9))
                                .padding(12)
                        }
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(preset.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        Text("\(preset.exercises.count) Exercises")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding(14)
                }
            }
            .frame(width: AppCardMetrics.tileWidth, height: AppCardMetrics.tileHeight)
            .clipShape(RoundedRectangle(cornerRadius: AppCardMetrics.cornerRadius))
            .appCardStyle()
            .overlay {
                RoundedRectangle(cornerRadius: AppCardMetrics.cornerRadius)
                    .stroke(isSelected ? .orange : .clear, lineWidth: 2)
            }
        case .small:
            HStack(alignment: .center){
                //Image Placeholder
                if preset.image != nil{
                    Image(preset.image!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 67, height: 64)
                        .clipShape(.rect(cornerRadius: AppCardMetrics.compactCornerRadius))
                        .foregroundStyle(.background.secondary)
                        
                        .padding(6)
                }
                else{
                    RoundedRectangle(cornerRadius: AppCardMetrics.compactCornerRadius)
                        .frame(width: 67, height: 64)
                        .foregroundStyle(.background.secondary)
                        .padding(6)
                }
                VStack(alignment: .leading){
                    Text(preset.name)
                        .font(.headline)
                    HStack{
                        Text(arrayToString(arrayOfStrings: preset.focousArea))
                        
                        Text("•")
                        Text("\(preset.exercises.count) Exercises")
                    }.font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
            }/*.background(.background.secondary,in: RoundedRectangle(cornerRadius: 20)).padding(.horizontal)*/
        }
        
    }
}

//MARK: - CONTINUE BUTTON
struct ContinueButton: View{
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 40)
                .frame(maxWidth: .infinity, maxHeight: 70)
                .foregroundStyle(.orange)
                .padding()
            Text("Continue")
                .font(.title3)
                .foregroundStyle(.white)
        }
    }
}

        
//MARK: - View Testing
struct ViewStore: View {
    var body: some View {
        assisstanceAvailablityTag(type: .iconAndText)
        PresetTileViewType(preset: Presets().presets[2], type: .large)
        ContinueButton()
    }
}


#Preview {
    ViewStore()
}
