//
//  SpaceCometDemo.swift
//
//
//  Created by Ben Myers on 5/26/24.
//

import SwiftUI
import Particles
import ParticlesPresets

/// A demo with a comet, in space, passing by planets.
struct SpaceCometDemo: View {
  
  @Environment(\.debug) var debug: Bool
  
  var body: some View {
    ParticleSystem {
      planetEmitter
      starsEmitter
      Preset.Comet()
    }
    .debug(debug)
  }
  
  private var planetEmitter: some Entity {
    Emitter(every: 14.0) {
      Particle {
        RadialGradient(
          colors: [Color.pink, Color.red],
          center: .center,
          startRadius: 0.0,
          endRadius: 10
        )
        .clipShape(Circle())
      }
      .hueRotation(angleIn: .degrees(0) ... .degrees(360))
      .lifetime(12)
      .glow(Color.red.opacity(0.5), radius: 40.0)
      .initialVelocity(x: 2, y: -2)
      .initialPosition { c in
        let pairs = [(-600, 500), (Int(c.system.size.width) - 600, Int(c.system.size.height) + 500)]
        let randomPair = pairs.randomElement()!
        return CGPoint(x: randomPair.0, y: randomPair.1)
      }
    }
  }
  
  private var starsEmitter: some Entity {
    Emitter(every: 0.01) {
      Particle {
        Circle()
          .frame(width: 14.0, height: 14.0)
      }
      .initialPosition { c in
        let x = Int.random(in: 0 ... Int(c.system.size.width))
        let y = Int.random(in: 0 ... Int(c.system.size.height))
        return CGPoint(x: x, y: y)
      }
      .opacity { c in
        return 1.0 * (c.timeAlive)
      }
      .lifetime(in: 3.0 +/- 1.0)
      .scale(factorIn: 0.1 ... 0.6)
      .blendMode(.plusLighter)
      .initialVelocity(xIn: 0.2 ... 0.8, yIn: -0.5 ... 0.25)
      .fixAcceleration(x: 0.3, y: -0.3)
    }
  }
}
