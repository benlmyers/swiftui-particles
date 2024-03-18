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
    
    var spawnWidth: CGFloat = 700.0
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
        .initialVelocity(xIn: -0.1 ... 0.1, yIn: 0.02 ... 0.08)
        .initialPosition(.top)
        .initialOffset(xIn: -spawnWidth/2.0 ... spawnWidth/2.0)
        .fixAcceleration({ c in
          return CGVectorMake(0.0005 * sin(c.system.time * 1.8), 0.003)
        })
        .opacity(in: 0.5 ... 1.0)
        .transition(.scale)
        .colorOverlay(.init(red: 0.7, green: 0.9, blue: 0.9))
        .initialTorque(angleIn: .degrees(-1.0) ... .degrees(1.0))
        .hueRotation(angleIn: .degrees(-360.0) ... .degrees(30.0))
        .blendMode(.plusLighter)
        .scale { c in
          let s = CGFloat.random(in: 0.3 ... 1.0, seed: c.physics.seed.0)
          return CGSize(width: s * sin(0.04 * Double(c.physics.seed.0) * c.system.time), height: s)
        }
//        .initialTorque(.degrees(2))
      }
    }
  }
}
