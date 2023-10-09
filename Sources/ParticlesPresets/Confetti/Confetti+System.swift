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
    
    var source: UnitPoint
    var colors: [Color]
    var sizes: [Confetti.Particle.Size]
    
    public var body: some View {
      ParticleSystem {
        Emitter {
          Confetti.Particle(color: colors.randomElement()!, shape: .circle, size: .medium)
          Confetti.Particle(color: colors.randomElement()!, shape: .square, size: .medium)
          Confetti.Particle(color: colors.randomElement()!, shape: .rectangle, size: .medium)
        }
        .startPosition(source)
        .fireRate(30.0)
      }
    }
    
    public init(source: UnitPoint = .center, colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple], sizes: [Confetti.Particle.Size] = [.medium]) {
      self.source = source
      self.colors = colors
      self.sizes = sizes
    }
  }
}
