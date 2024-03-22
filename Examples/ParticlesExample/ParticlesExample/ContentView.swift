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
  
  @State var burst: Bool = false
  
  var body: some View {
    VStack(spacing: 50) {
      Text("Whats up")
        .particleSystem(atop: false) {
          Preset.Fire()
        }
      Text("Not much lol")
        .emits(every: 0.01, atop: false) {
          Particle { Text("👋") }.initialVelocity { c in
              .init(angle: .random(), magnitude: 1.0)
          }
        }
      Text("burst me")
        .dissolve(if: burst)
      Button("burst") { burst.toggle() }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
