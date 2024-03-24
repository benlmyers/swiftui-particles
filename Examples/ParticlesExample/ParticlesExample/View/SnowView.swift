//
//  SnowView.swift
//
//
//  Created by Demirhan Mehmet Atabey on 22.03.2024.
//

import SwiftUI
import Particles
import ParticlesPresets

struct SnowView: View {
  
  var body: some View {
    ParticleSystem {
      Preset.Snow()
    }
    .debug()
  }
}
