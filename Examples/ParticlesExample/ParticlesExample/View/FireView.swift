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
  @State var flameSize: Double = 15.0
  @State var spawnRadius: CGFloat = 8.0
  
  var body: some View {
    ZStack(alignment: .top) {
      ParticleSystem {
        Preset.Fire(color: color, flameSize: flameSize, spawnRadius: .init(width: spawnRadius, height: spawnRadius))
      }
      .statePersistent("fire", refreshesViews: true)
      HStack {
        ColorPicker("Color", selection: $color)
        Slider(value: $flameSize, in: 5.0 ... 40.0, label: { Text("Flame Size (\(String(format: "%.1f", flameSize)))") })
      }
      .padding()
    }
  }
}
