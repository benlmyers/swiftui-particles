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
    var flameSize: CGFloat = 10.0
    var flameLifetime: TimeInterval = 1
    
    public var body: some Entity {
      Emitter(every: 0.01) {
        Particle {
          RadialGradient(
            colors: [color, .clear],
            center: .center,
            startRadius: 0.0,
            endRadius: flameSize * 0.8
          )
          .clipShape(Circle())
        }
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialPosition(.center)
        .hueRotation(angleIn: .degrees(0.0) ... .degrees(50.0))
        .initialTorque(angleIn: .degrees(0.0) ... .degrees(8))
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialVelocity(xIn: -1 ... 1, yIn: -3 ... 1)
        .fixAcceleration(y: -0.02)
        .lifetime(in: 1 +/- 0.2)
        .glow(color.opacity(0.5), radius: 18.0)
        .blendMode(.plusLighter)
        .transition(.scale, on: .death, duration: 0.5)
        .transition(.opacity, on: .birth)
      }
    }
    
    public init(
      color: Color = .red,
      spawnPoint: UnitPoint = .center,
      flameSize: CGFloat = 10.0,
      spawnRadius: CGSize = .init(width: 20.0, height: 4.0)
    ) {
      self.color = color
      self.spawnPoint = spawnPoint
      self.flameSize = flameSize
      self.spawnRadius = spawnRadius
    }
  }
}
