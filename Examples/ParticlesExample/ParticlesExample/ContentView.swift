//
//  ContentView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Particles
import PresetParticles

struct ContentView: View {
  
  @State var pause: Bool = false
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      ParticleSystem {
        Particle(color: .red, radius: 5.0)
//          .starts(at: .center)
          .lifetime(8.0)
          .starts(atPoint: .init(x: 100, y: 100))
          .initialVelocity(.init(dx: 1.0, dy: 1.5))
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
