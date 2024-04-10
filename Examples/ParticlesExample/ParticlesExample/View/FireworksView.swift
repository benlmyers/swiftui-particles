//
//  FireworksView.swift
//
//
//  Created by Demirhan Mehmet Atabey on 31.03.2024.
//

import SwiftUI
import Particles
import ParticlesPresets

struct FireworksView: View {
  
  @State var color: Color = .pink
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      ParticleSystem {
        Preset.Fireworks(color: color)
      }
      #if !os(watchOS)
      HStack {
        ColorPicker("Color", selection: $color)
      }
      .padding()
      #endif
    }
  }
}
