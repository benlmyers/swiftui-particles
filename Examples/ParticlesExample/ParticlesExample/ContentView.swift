//
//  ContentView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Particles
import ParticlesPresets

struct ContentView: View {
  
  var body: some View {
    ParticleSystem {
      Burst {
        Text("Hello, World!").font(.title).bold()
      } withBehavior: { e in
        e
//                e.initialVelocity(xIn: -0.5 ... 0.5, yIn: -0.5 ... 0.5)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
