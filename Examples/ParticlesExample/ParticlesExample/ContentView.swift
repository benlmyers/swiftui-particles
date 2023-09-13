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
  @State var vel: CGVector = .init(dx: 1, dy: 1)
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      Button("Vel") {
        vel = CGVector(dx: Double.random(in: -0.5 ... 0.5), dy: Double.random(in: -0.5 ... 0.5))
      }
      ParticleSystem {
        Emitter {
          Particle(color: .red, radius: 5.0)
            .setConstant(\.$vel, to: .init(dx: 2, dy: 0))
        }
        .bind(\.$vel, to: $vel)
      }
      .paused($pause)
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
