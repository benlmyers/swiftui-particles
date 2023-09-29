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
  
  @State var velocity: CGVector = .init(dx: 1, dy: 1)
  @State var opacity: CGFloat = 1.0
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      HStack {
        Button("Vel") {
          velocity = CGVector(dx: Double.random(in: -0.5 ... 0.5), dy: Double.random(in: -0.5 ... 0.5))
        }
      }
      ParticleSystem {
        Particle(color: .yellow, radius: 5.0)
          .with(\.$pos, startingAt: .init(x: 75, y: 10))
          .with(\.$lifetime, fixedAt: 40.0)
        Emitter {
          Particle(color: .red, radius: 5.0)
            .with(\.$vel, startingAt: .init(dx: 1.0, dy: 1.0))
            .with(\.$acc, fixedAt: .init(dx: 0.0, dy: 0.1))
        }
        .with(\.$vel, boundTo: $velocity)
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
