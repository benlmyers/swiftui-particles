//
//  Snow.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Snow: Entity, PresetEntry {
    
    var metadata: PresetMetadata {
      .init(
        name: "Snow",
        target: "ParticlesPresets",
        description: "Create cool SwiftUI views with a snow effect.",
        author: "benlmyers",
        version: 1
      )
    }
    
    var spawnWidth: CGFloat = 300.0
    var snowSize: CGFloat
    var snowLifetime: TimeInterval
    
    public init(snowSize: CGFloat = 30.0, snowLifetime: TimeInterval = 1.0) {
      self.snowSize = snowSize
      self.snowLifetime = snowLifetime
    }
    
    public var body: some Entity {
      Emitter(interval: 0.01) {
        Particle {
          Image("snow1", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: snowSize, height: snowSize)
        }
        .initialOffset(xIn: -spawnWidth/2.0 ... spawnWidth/2.0)
        .initialPosition(.center)
        .initialTorque(angleIn: .degrees(-1.0) ... .degrees(1.0))
        .initialAcceleration(y: 0.01)
        .transition(.scale)
        .colorOverlay(.red)
        .scale { c in
          CGSize(width: sin(0.01 * Double(c.physics.seed.0) * c.system.time), height: 1.0)
        }
      }
    }
  }
}
