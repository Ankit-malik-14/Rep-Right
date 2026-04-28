//
//  CaliberationScreen.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 22/03/26.
//

import SwiftUI

struct CaliberationScreen: View {
    @State private var showSheet: Bool = true
    @State private var detector = BackContourDetector()
    
    var body: some View {
        ZStack {
            // Camera Feed
            CameraFeedView(session: detector.captureSession)
                .ignoresSafeArea()
            
            // Camera switch button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        detector.toggleCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .font(.title2)
                            .padding()
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding()
                }
                Spacer()
            }
            
            // Overlay based on phase
            if detector.phase == .detectingPerson {
                VStack {
                    Spacer()
                    Text(detector.detectionFeedback)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .padding()
                        .background(.black.opacity(0.6), in: Capsule())
                        .padding(.bottom, 50)
                }
            } else if detector.phase == .timer {
                CalibrationScreen2(detector: detector)
            } else if detector.phase == .analyzing {
                BackContourOverlayView(detector: detector)
            }
        }
        .onAppear {
            detector.startSession()
        }
        .onDisappear {
            detector.stopSession()
        }
        .sheet(isPresented: $showSheet, onDismiss: {
            detector.startDetectingPerson()
        }) {
            CaliberationSheetView(showSheet: $showSheet)
                .presentationDetents([.custom(CustomDetents.self), .large])
                .interactiveDismissDisabled() // Force user to tap Continue
        }
    }
}

struct CaliberationSheetView: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                //hip height
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width: 80, height: 90)
                        Image(systemName: "lines.measurement.vertical")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 50)
                    }
                    Text("Hip Height")
                        .font(.callout.bold())
                }
                .padding()
                
                //full body
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width: 80, height: 90)
                        Image(systemName: "rectangle.dashed")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .rotationEffect(Angle(degrees: 90))
                        Image(systemName: "figure")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 30)
                    }
                    Text("Full body")
                        .font(.callout.bold())
                }
                .padding()
                
                //6-8 feet
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width: 80, height: 90)
                        Image(systemName: "ruler")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    Text("6-8 feet")
                        .font(.callout.bold())
                }
                .padding()
            }
            
            //Text information
            VStack {
                Text("Wear body hugging clothes for better accuracy")
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                Text("For this exercise place camera facing sideways")
            }
            .padding(10)
            
            Text("Scanning Environment...")
                .bold()
                .padding(10)
            
            Button {
                showSheet = false
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button("Cancel", role: .cancel) {
                showSheet = false
            }.tint(.orange)
                .padding(.top, 8)
        }
        .padding()
    }
}

struct CustomDetents: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        context.maxDetentValue - 250
    }
}

#Preview {
    CaliberationScreen()
}
