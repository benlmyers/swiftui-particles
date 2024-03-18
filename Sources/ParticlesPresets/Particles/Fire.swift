//
//  Fire.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Fire: Entity, PresetEntry {
    
    var metadata: PresetMetadata {
      .init(
        name: "Fire",
        target: "ParticlesPresets",
        description: "Heat up your SwiftUI views with fire particles.",
        author: "benlmyers",
        version: 1
      )
    }
    
    var color: Color
    var spawnPoint: UnitPoint
    var spawnRadius: CGSize
    var flameSize: CGFloat = 1.0
    var flameLifetime: TimeInterval = 1.0
    
    public var body: some Entity {
      Emitter(interval: 0.005) {
        Particle {
          RadialGradient(colors: [color, .clear], center: .center, startRadius: 2.0, endRadius: 12.0)
            .clipShape(Circle())
            .frame(width: 150.0 * flameSize, height: 150.0 * flameSize)
        }
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialPosition(.center)
        .hueRotation(angleIn: .degrees(0.0) ... .degrees(50.0))
        .initialTorque(angleIn: .degrees(0.0) ... .degrees(8))
        .scale({ c in
          return .init(width: 1.0 + 0.05 * sin(0.1 * Double(c.physics.seed.0) * c.system.time + Double(c.physics.seed.1)), height: 1.0 + 0.05 * cos(0.1 * Double(c.physics.seed.2) * c.system.time + Double(c.physics.seed.3)))
        })
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialVelocity(xIn: -0.2 ... 0.2, yIn: -0.3 ... 0.3)
        .fixAcceleration(y: -0.01)
        .lifetime(in: flameLifetime +/- 0.3)
        .blendMode(.plusLighter)
//        .transition(.scale, on: .death, duration: 0.3)
        .transition(.opacity, on: .birthAndDeath, duration: 0.1)
      }
    }
    
    public init(color: Color = .yellow, spawnPoint: UnitPoint = .center, spawnRadius: CGSize = .init(width: 50.0, height: 4.0)) {
      self.color = color
      self.spawnPoint = spawnPoint
      self.spawnRadius = spawnRadius
    }
  }
}
