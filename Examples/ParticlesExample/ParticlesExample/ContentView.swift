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
        Particle(color: .red)
          .onBirth { e, _ in
            e.velocity = .init(dx: 1, dy: 1)
          }
          .onDeath { e in
            print("HELLO")
          }
        Emitter {
          Particle {
            Text("Hi")
          }
          .onUpdate { e in
            e.velocity = .init(dx: 0, dy: 1)
            if let p = e as? Particle.Proxy {
              p.opacity = 0.5
            }
          }
        }
        .onUpdate { e in
          e.position = .init(x: 200.0, y: 100.0)
        }
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
