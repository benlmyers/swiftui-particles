//
//  ContentView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Particles
import ParticlesCore
import ParticlesExtensions

struct ContentView: View {
  
  @State var velocity: CGVector = .init(dx: 1, dy: 1)
  @State var acceleration: CGVector = .zero
  @State var opacity: CGFloat = 1.0
  
  private let systemData = ParticleSystem.Data()
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      HStack {
        Button("Acc") {
          acceleration = .random(magnitude: 0.05)
        }
      }
      Confetti.System()
//      ParticleSystem(data: systemData) {
//        Emitter {
//          AdvancedParticle(color: .purple)
//            .start(\.velocity, with: { .random(magnitudeIn: 1.0 ... 3.0) })
//            .start(\.blur, at: 3.0)
//            .fix(\.acceleration, at: acceleration)
//            .fix(\.scaleEffect, updatingFrom: { v in v * 0.98 })
//            .onBirth { particle, _ in
//              particle.hueRotation = .random()
//            }
//        }
//        .fix(\.fireRate, at: 500.0)
//        .startPosition(.center)
//      }
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
