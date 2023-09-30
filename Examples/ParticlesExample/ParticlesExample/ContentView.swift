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
        let p = Particle(color: .red, radius: 5.0)
//          .fix(\.$vel, at: .init(dx: 3.0, dy: 0.0))
          .start(\.$vel) { e in
            return .init(dx: cos(e.timeAlive), dy: sin(e.timeAlive))
          }
        Emitter {
          p
        }
        .fix(\.$pos, at: .init(x: 100.0, y: 100.0))
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
