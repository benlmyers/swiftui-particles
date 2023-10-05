//
//  Confetti+System.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import Particles
import ParticlesCore

public extension Confetti {
  
  struct System: View {
    
    var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    var sizes: [Confetti.Particle.Size] = [.medium]
    
    public var body: some View {
      ParticleSystem {
        Emitter {
          Confetti.Particle(color: colors.randomElement()!, shape: .circle, size: .medium)
          Confetti.Particle(color: colors.randomElement()!, shape: .circle, size: .medium)
          Confetti.Particle(color: colors.randomElement()!, shape: .circle, size: .medium)
        }
      }
    }
  }
}

fileprivate extension Confetti.Particle {
  
  func modifier() -> Self {
    return self
      .useGravity()
      .start(\.velocity, with: { .random(magnitude: 1.0) })
  }
}
