//
//  HuggingLatticeDemo.swift
//  ParticlesExample
//
//  Created by Ben Myers on 5/27/24.
//

import SwiftUI
import Particles
import ParticlesPresets

/// A demo with `Lattice`.
struct HuggingLatticeDemo: View {
  
  @Environment(\.debug) var debug: Bool
  
  var body: some View {
    ParticleSystem {
      Lattice(hugging: .all, customEntity: {
        Preset.Fire()
      }) {
        Text("Particles")
          .fontWeight(.black)
          .font(.system(size: 90))
          .foregroundStyle(Color.red)
      }
    }
    .debug(debug)
  }
}
