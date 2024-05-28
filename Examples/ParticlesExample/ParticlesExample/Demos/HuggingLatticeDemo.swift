//
//  HuggingLatticeDemo.swift
//  ParticlesExample
//
//  Created by Ben Myers on 5/27/24.
//

import SwiftUI
import Particles
import ParticlesPresets

/// A demo with `Lattice` using a `hugging` mode.
struct HuggingLatticeDemo: View {
  
  @Environment(\.debug) var debug: Bool
  
  var body: some View {
    ZStack {
      p
      ParticleSystem {
        Lattice(hugging: .top, customEntity: {
          Preset.Fire()
        }) {
          p
        }
        .emitChance(0.1)
      }
      .debug(debug)
    }
  }
  
  var p: some View {
    Text("Particles")
      .fontWeight(.black)
      .font(.system(size: 90))
      .foregroundStyle(Color.orange)
  }
}
