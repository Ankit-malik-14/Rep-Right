//
//  CalibrationScreen2.swift
//  Rep-Right
//
//  Created by Jugad on 27/03/26.
//

import SwiftUI

struct CalibrationScreen2: View {
    var detector: BackContourDetector
    
    var body: some View {
        ZStack {
            VStack(spacing: 220) {
                HStack {
                    Spacer()
                    Button {
                        // will show tips
                    } label: {
                        HStack {
                            Image(systemName: "lightbulb.max.fill")
                            Text("Tips")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.orange)
                    .buttonStyle(.bordered)
                    .padding(.trailing, 30)
                }
                
                Text("\(detector.timerTime)")
                    .font(.system(size: 100))
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                
                // Timer for 3 seconds
                HStack {
                    VStack(spacing: 50) {
                        Text("Detection starting ...")
                        HStack {
                            ForEach(1...3, id: \.self) { index in
                                Capsule()
                                    .fill(index == 3 - detector.timerTime ? Color.orange : Color.orange.opacity(0.3))
                                    .frame(width: 100, height: 8)
                            }
                        }
                    }
                }
                .frame(width: 380, height: 150)
                .background(.secondary, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}
