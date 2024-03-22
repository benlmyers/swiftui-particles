//
//  FireView.swift
//
//
//  Created by Demirhan Mehmet Atabey on 22.03.2024.
//

import SwiftUI
import Particles
import ParticlesPresets

struct FireView: View {
  
  @State var color: Color = .red
  @State var flameSize: Double = 1.0
  @State var spawnRadius: CGFloat = 8.0
  
  var body: some View {
    ZStack(alignment: .top) {
      ParticleSystem {
        Preset.Fire(color: color, flameSize: flameSize, spawnRadius: .init(width: spawnRadius, height: spawnRadius))
      }
      .statePersistent("fire")
      HStack {
        ColorPicker("Color", selection: $color)
        Slider(value: $flameSize, in: 0.5 ... 2.0, label: { Text("Flame Size (\(String(format: "%.1f", flameSize)))") })
      }
      .padding()
    }
  }
}
