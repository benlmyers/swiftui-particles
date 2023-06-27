//
//  ContentView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Particles

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      ParticleSystem {
        Emitter {
          Particle {
            Text("⭐️")
          }
          .initialVelocity(x: 3.0, y: 3.0)
          .initialAcceleration(x: 0.0, y: -0.05)
          .initialTorque(.degrees(-1.0))
        }
        //.initialVelocity(x: 1.0, y: 1.0)
        //.particlesInheritVelocity(false)
      }
      .debug()
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
