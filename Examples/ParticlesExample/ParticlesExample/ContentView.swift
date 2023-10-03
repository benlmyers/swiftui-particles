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
  
  private let systemData = ParticleSystem.Data()
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      HStack {
        Button("Vel") {
          velocity = CGVector(dx: Double.random(in: -1.0 ... 1.0), dy: Double.random(in: -1.0 ... 1.0))
        }
      }
      ParticleSystem(data: systemData) {
        Emitter {
          Particle(color: .red)
            .start(\.hueRotation, at: .degrees(180.0))
            .start(\.velocity, at: velocity)
        }
        .start(\.canFire) { emitter in
          emitter.emittedCount < 5
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
