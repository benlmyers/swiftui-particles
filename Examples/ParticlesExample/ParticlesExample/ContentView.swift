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
      Lattice(spacing: 3) {
        v
      } withBehavior: { p in
        p
          .initialVelocity(xIn: -0.05 ... 0.05, yIn: -0.05 ... 0.05)
          .initialOffset(y: 100.0)
          .lifetime(4)
          .transition(.twinkle, on: .death, duration: 1.0)
          .initialAcceleration(y: 0.0002)
      } customView: {
        Circle().frame(width: 3.0, height: 3.0)
      }
    }
    .debug()
    .frame(width: 400.0, height: 300.0)
  }
  
  var v: some View {
    Text("Hi, Ben!")
      .font(.system(size: 48))
      .fontWeight(.black)
      .foregroundStyle(LinearGradient(colors: [.red, .yellow, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
