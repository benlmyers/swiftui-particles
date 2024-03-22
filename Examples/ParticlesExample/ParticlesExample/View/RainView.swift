//
//  RainView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 3/22/24.
//

import SwiftUI
import Particles
import ParticlesPresets

struct RainView: View {
  
  @State var color: Color = .red
  @State var intensity: Double = 20
  @State var wind: CGFloat = 0.5
  
  var body: some View {
    ZStack(alignment: .top) {
      ParticleSystem {
        Preset.Rain(lifetime: 5.0, intensity: Int(intensity), wind: wind)
      }
      .statePersistent("rain")
      HStack {
        Slider(value: $intensity, in: 1 ... 100, label: { Text("Intensity (\(Int(intensity)))") })
        Slider(value: $wind, in: -2.0 ... 2.0, label: { Text("Wind (\(String(format: "%.1f", wind)))") })
      }
      .padding()
    }
  }
}
