//
//  StarsView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 3/22/24.
//

import SwiftUI
import Particles
import ParticlesPresets

struct StarsView: View {
  
  @State var size: CGFloat = 20.0
  @State var intensity: Double = 20
  
  var body: some View {
    ZStack(alignment: .top) {
      ParticleSystem {
        Preset.Stars(size: size, lifetime: 5.0, intensity: Int(intensity), twinkle: true)
      }
      .statePersistent("stars", refreshesViews: true)
      HStack {
        Slider(value: $size, in: 1 ... 50, label: { Text("Size (\(String(format: "%.1f", size)))") })
        Slider(value: $intensity, in: 1 ... 100, label: { Text("Intensity (\(Int(intensity)))") })
      }
      .padding()
    }
  }
}
