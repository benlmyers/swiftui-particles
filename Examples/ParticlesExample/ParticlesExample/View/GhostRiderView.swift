//
//  GhostRiderView.swift
//
//
//  Created by Demirhan Mehmet Atabey on 22.03.2024.
//

import SwiftUI
import Particles
import ParticlesPresets

struct GhostRiderView: View {
  
  @State var motorcyclePosition: CGFloat = 0
  
  var body: some View {
    ZStack {
      HStack {
        Image("chopper")
          .resizable()
          .scaledToFit()
          .frame(width: 800, height: 150)
          .frame(height: 900)
          .overlay {
            Text("💀")
              .font(.system(size: 30))
              .particleSystem(atop: true, offset: CGPoint(x: 0, y: -15)) {
                Preset.Fire()
              }
              .offset(x: -15, y: -15)
          }
          .particleSystem(offset: CGPoint(x: -60, y: 0)) {
            Preset.Smoke(
              dirty: true,
              spawnPoint: .topLeading,
              startRadius: 6,
              endRadius: 25
            )
          }
        Spacer()
      }
      .offset(x: motorcyclePosition)
      .onAppear {
        withAnimation(.easeInOut(duration: 3)) {
          motorcyclePosition = 300
        }
      }
    }
  }
}
