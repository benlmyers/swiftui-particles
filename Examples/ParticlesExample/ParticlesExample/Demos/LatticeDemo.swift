//
//  LatticeDemo.swift
//  ParticlesExample
//
//  Created by Ben Myers on 5/26/24.
//

import SwiftUI
import Particles

/// A demo with `Lattice`.
struct LatticeDemo: View {
  
  @Environment(\.debug) var debug: Bool
  
  var body: some View {
    ParticleSystem {
      Lattice(spacing: 4) {
        Text("Particles")
          .fontWeight(.black)
          .font(.system(size: 90))
          .foregroundStyle(Color.red)
      }
      .delay(with: { c in
        return Double(c.proxy.position.x) * 0.005 + Double.random(in: 0.0 ... 0.5)
      })
      .transition(.scale, on: .birth, duration: 1.0)
      .hueRotation(with: { c in
        return .degrees(c.proxy.position.x + 60 * (c.timeAlive + c.proxy.seed.0))
      })
      .glow(radius: 8)
      .scale(1.5)
      .lifetime(99)
      .zIndex(1)
      .fixVelocity { c in
          .init(dx: 0.1 * cos(6 * (c.timeAlive + c.proxy.seed.0)), dy: 0.1 * sin(6 * (c.timeAlive + c.proxy.seed.1)))
      }
    }
    .debug(debug)
  }
}
