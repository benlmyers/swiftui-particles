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
  
  var body: some View {
    ParticleSystem {
      Preset.Fireworks()
    }
  }
}
