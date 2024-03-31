//
//  Fireworks.swift
//
//
//  Created by Demirhan Mehmet Atabey on 31.03.2024.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  struct Fireworks: Entity, PresetEntry {
    
    public init () {
      
    }
    public var body: some Entity {
      Emitter(every: 1.5) {
        ForEach(0..<500, merges: .views) { i in
          Particle {
            RadialGradient(
              colors: [Color.white, .clear],
              center: .center,
              startRadius: 0.0,
              endRadius: 3
            )
            .clipShape(Circle())
          }
          .transition(.opacity, duration: 0.5)
          .initialVelocity(xIn: -5...5, yIn: -15...(-5))
          .initialAcceleration(y: 0.15)
          .lifetime(2.5)
          .scale(1.5)
        }
      }
      .maxSpawn(count: 50)
    }
  }
}
