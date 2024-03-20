//
//  ContentView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Particles
import ParticlesPresets

struct ContentView: View {
  
  var body: some View {
    ParticleSystem {
//      Preset.Snow()
//      Preset.Fire()
      ForEach(Array(repeating: 1, count: 100), merges: .entities) { c in
        Particle {
          Circle()
            .frame(width: 20.0, height: 20.0)
        }
        .initialPosition(.center)
        .initialOffset(xIn: -100.0 ... 100.0)
        .initialVelocity(y: 0.1)
        .lifetime(10)
      }
    }
    .debug()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
