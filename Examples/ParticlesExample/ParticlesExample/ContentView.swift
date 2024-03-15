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
//      Preset.Fire()
      Emitter {
        Particle {
          Circle().frame(width: 30.0, height: 30.0).foregroundStyle(.red)
        }
        .initialPosition(.center)
        .initialVelocity(y: 0.3)
        .transition(.opacity)
        .lifetime(3)
      }
    }
    .debug()
    .background(Color.black)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
