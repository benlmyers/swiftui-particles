//
//  Magic.swift
//
//
//  Created by Ben Myers on 3/22/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Magic: Entity, PresetEntry {
    
    public var metadata: PresetMetadata {
      .init(
        name: "Magic",
        target: "ParticlesPresets",
        description: "Stir up some magic in your SwiftUI views.",
        author: "benlmyers",
        version: 1
      )
    }
    
    var color: Color
    var spawnPoint: UnitPoint
    
    public var body: some Entity {
      Emitter(every: 0.03) {
        Particle {
          RadialGradient(
            colors: [color, .clear],
            center: .center,
            startRadius: 0.0,
            endRadius: 10.0
          )
          .clipShape(Circle())
          .frame(width: 15.0, height: 15.0)
        }
        .initialPosition(.center)
        .initialVelocity { c in
            .init(angle: .random(), magnitude: .random(in: 0.3 ... 0.5))
        }
        .fixVelocity{ c in
          return .init(dx: c.proxy.velocity.dx + c.timeAlive * 0.02 * sin(5 * (c.proxy.seed.0 - 0.5) * c.timeAlive), dy: c.proxy.velocity.dy - c.timeAlive * 0.02 * cos(5 * (c.proxy.seed.1 - 0.5) * c.timeAlive))
        }
        .blendMode(.plusLighter)
        .hueRotation(angleIn: .degrees(-10.0) ... .degrees(10.0))
        .transition(.twinkle, on: .death, duration: 2.0)
        .transition(.opacity, on: .birth, duration: 0.5)
        .lifetime(3)
        .glow(color, radius: 4)
      }
    }
    
    public init(
      color: Color = .purple,
      spawnPoint: UnitPoint = .center
    ) {
      self.color = color
      self.spawnPoint = spawnPoint
    }
  }
}
