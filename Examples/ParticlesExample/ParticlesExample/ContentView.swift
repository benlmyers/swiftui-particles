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
  
  @State var systemData = ParticleSystem.Data()
  
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
      ParticleSystem(data: systemData) {
        Emitter {
          Particle(color: .red)
            .start(\.hueRotation, at: .degrees(180.0))
            .start(\.velocity, with: { velocity })
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
