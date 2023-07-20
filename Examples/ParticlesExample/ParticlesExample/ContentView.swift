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
        Field(bounds: .all, effect: .gravity(.init(dx: 0.0, dy: 0.01)))
        Emitter(rate: 10.0) {
          Particle {
            Text("⭐️")
          }
          .lifetime(3.0)
          .floatDownward()
          .customScale(.inAndOut(strength: 20))
          Particle(color: .red, radius: 4.0)
        }
        .initialPosition(x: 100.0, y: 100.0)
        .emitVelocity(x: .random(in: -1.0...1.0), y: .random(in: -1.0...1.0))
        .particlesInheritVelocity(false)
        .ignoreFields(true)
        
      }
      //.debug()
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
