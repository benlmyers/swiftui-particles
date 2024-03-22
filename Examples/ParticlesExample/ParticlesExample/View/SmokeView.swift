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
    VStack {
      HStack {
        Button {
          dirty.toggle()
        } label: {
          Text(dirty ? "Disable Dirty" : "Enable Dirty")
        }
      }
      ParticleSystem {
        Preset.Smoke(dirty: dirty)
      }
      .statePersistent("smoke")
      .frame(width: 600, height: 600)
    }
  }
}
