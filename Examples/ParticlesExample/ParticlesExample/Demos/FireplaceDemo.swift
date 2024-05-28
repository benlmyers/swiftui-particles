//
//  FireplaceDemo.swift
//  ParticlesExample
//
//  Created by Ben Myers on 5/27/24.
//

import SwiftUI
import Particles
import ParticlesPresets

/// A demo with `Lattice`.
struct FireplaceDemo: View {
  
  @Environment(\.debug) var debug: Bool
  
  var body: some View {
    ZStack {
      Color.black
      Image("fireplace").resizable().aspectRatio(contentMode: .fit)
      ParticleSystem {
        Preset.Fire(flameSize: 15.0, spawnRadius: .init(width: 200.0, height: 5.0))
          .fixPosition(.init(x: 0.5, y: 0.65))
      }
      .debug(debug)
    }
  }
}
