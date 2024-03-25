//
//  Rain.swift
//
//
//  Created by Ben Myers on 3/20/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Rain: Entity, PresetEntry {
    
    var metadata: PresetMetadata {
      .init(
        name: "Rain",
        target: "ParticlesPresets",
        description: "Create cool SwiftUI views with a rain effect.",
        author: "benlmyers",
        version: 1
      )
    }
    
    private var parameters: Parameters
    
    public init(lifetime: TimeInterval = 1.0, intensity: Int = 20, wind: CGFloat = 0.5) {
      self.parameters = .init(intensity: intensity, rainLifetime: lifetime, windVelocity: wind)
    }
    
    public var body: some Entity {
      Emitter(every: 1.0 / Double(parameters.intensity)) {
        Drop(parameters: parameters)
      }
      .emitAll()
      .initialPosition(.top)
    }
    
    public struct Drop: Entity {
      
      internal var parameters: Rain.Parameters
      
      public var body: some Entity {
        Particle {
          Rectangle().frame(width: 3.0, height: 12.0)
            .foregroundColor(.blue)
        }
        .initialOffset(withX: { c in
          let w = c.system.size.width * 0.5
          return .random(in: -w ... w)
        })
        .initialVelocity(xIn: parameters.windVelocity +/- 1, yIn: 13 ... 15)
        .initialAcceleration(y: 0.1)
        .opacity(in: 0.5 ... 1.0)
        .transition(.opacity)
        .lifetime(parameters.rainLifetime)
        .initialRotation(.degrees(-5.0 * parameters.windVelocity))
        .hueRotation(angleIn: .degrees(-10.0) ... .degrees(10.0))
        .blendMode(.plusLighter)
        .scale { c in
          let s = CGFloat.random(in: 0.3 ... 1.0, seed: c.physics.seed.0)
          return CGSize(width: s /** cos(0.1 * c.system.time + c.physics.seed.1)*/, height: s)
        }
      }
    }
    
    internal struct Parameters {
      var intensity: Int
      var rainLifetime: TimeInterval
      var windVelocity: CGFloat
    }
  }
}
