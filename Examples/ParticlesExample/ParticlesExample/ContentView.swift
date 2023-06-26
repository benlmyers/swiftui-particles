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
          Text("🚀")
          Text("⭐️")
        }
        .particlesInheritVelocity(false)
        .initialVelocity(x: 0.0, y: 1.0)
        .emitVelocity(x: 1.0, y: 0.0)
        Emitter {
          Text("x")
          Text("o")
        }
        .initialVelocity(x: 2.0, y: 2.0)
      }
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
