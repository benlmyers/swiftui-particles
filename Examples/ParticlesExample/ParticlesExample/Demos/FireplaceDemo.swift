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
      Image("fireplace").resizable().frame(width: 300.0, height: 250.0).aspectRatio(contentMode: .fill)
      ParticleSystem {
        Preset.Fire(color: .orange, flameSize: 15.0, spawnRadius: .init(width: 200.0, height: 5.0))
          .fixPosition(.init(x: 0.5, y: 0.65))
      }
      .debug(debug)
      .scaleEffect(0.5)
    }
  }
}
