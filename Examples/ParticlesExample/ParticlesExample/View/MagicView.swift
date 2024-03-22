//
//  MagicView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 3/22/24.
//

import SwiftUI
import Particles
import ParticlesPresets

struct MagicView: View {
  
  @State var color: Color = .pink
  
  var body: some View {
    ZStack(alignment: .top) {
      ParticleSystem {
        Preset.Magic(color: color)
      }
      .statePersistent("magic")
      HStack {
        ColorPicker("Color", selection: $color)
      }
      .padding()
    }
  }
}
