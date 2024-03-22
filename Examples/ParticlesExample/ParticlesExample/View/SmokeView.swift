//
//  SmokeView.swift
//
//
//  Created by Demirhan Mehmet Atabey on 22.03.2024.
//

import SwiftUI
import Particles
import ParticlesPresets

struct SmokeView: View {
  
  @State var dirty = false
  
  var body: some View {
    ZStack(alignment: .top) {
      ParticleSystem {
        Preset.Smoke(dirty: dirty)
      }
      .statePersistent("smoke")
      HStack {
        Toggle("Dirty Smoke", isOn: $dirty)
      }
      .padding()
    }
  }
}
