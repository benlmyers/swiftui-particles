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
      Text("Particles")
        .fontWeight(.black)
        .font(.system(size: 90))
        .foregroundStyle(LinearGradient(colors: [Color.clear, Color.red], startPoint: .bottom, endPoint: .top))
      ParticleSystem {
        Emitter(every: 0.005) {
          Lattice(hugging: .top, customEntity: {
            Preset.Fire(color: .red).flame
          }) {
            Text("Particles")
              .fontWeight(.black)
              .font(.system(size: 90))
              .foregroundStyle(.red)
          }
        }
        .emitSingle { _ in
            .random(in: 0 ... 999)
        }
      }
      .debug(debug)
    }
  }
}
