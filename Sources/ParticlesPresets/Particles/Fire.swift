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
    
    public var body: some Entity {
      Emitter(interval: 0.01) {
        Particle {
          RadialGradient(colors: [.yellow, .clear], center: .center, startRadius: 2.0, endRadius: 12.0)
            .clipShape(Circle())
            .frame(width: 40.0, height: 40.0)
        }
        .initialPosition(.center)
        .hueRotation(.degrees(0))
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialVelocity(xIn: -0.8 ... 0.8, yIn: -1.0 ... 0.5)
        .fixAcceleration(y: -0.01)
        .opacity(0.5)
        .blendMode(.exclusion)
      }
    }
    
    public init(color: Color = .yellow, spawnPoint: UnitPoint = .center, spawnRadius: CGSize = .init(width: 50.0, height: 4.0)) {
      self.color = color
      self.spawnPoint = spawnPoint
      self.spawnRadius = spawnRadius
    }
  }
}

