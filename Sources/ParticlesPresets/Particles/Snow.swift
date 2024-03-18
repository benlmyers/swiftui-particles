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
    
    private var parameters: Parameters
    
    public init(in width: CGFloat = 750.0, size: CGFloat = 30.0, lifetime: TimeInterval = 5.0) {
      self.parameters = .init(spawnWidth: width, snowSize: size, snowLifetime: lifetime)
    }
    
    public var body: some Entity {
      Emitter(interval: 0.01) {
        Flake(parameters: parameters)
      }
    }
    
    public struct Flake: Entity {
      
      internal var parameters: Snow.Parameters
      
      public var body: some Entity {
        Particle {
          Image("snow1", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: parameters.snowSize, height: parameters.snowSize)
        }
        .initialVelocity(xIn: -0.1 ... 0.1, yIn: 0.02 ... 0.08)
        .initialPosition(.top)
        .initialOffset(xIn: -parameters.spawnWidth/2.0 ... parameters.spawnWidth/2.0)
        .fixAcceleration({ c in
          return CGVectorMake(0.0005 * sin(c.system.time * 1.8), 0.003)
        })
        .opacity(in: 0.5 ... 1.0)
        .transition(.opacity)
        .colorOverlay(.init(red: 0.7, green: 0.9, blue: 0.9))
        .initialTorque(angleIn: .degrees(-1.0) ... .degrees(1.0))
        .hueRotation(angleIn: .degrees(-360.0) ... .degrees(30.0))
        .blendMode(.plusLighter)
        .lifetime(2)
        .scale { c in
          let s = CGFloat.random(in: 0.3 ... 1.0, seed: c.physics.seed.0)
          return CGSize(width: s * sin(0.02 * Double(c.physics.seed.0) * c.system.time), height: s)
        }
      }
    }
    
//    public struct Drift: Entity {
//      
//      internal var parameters: Snow.Parameters
//      
//      public var body: some Entity {
//        
//      }
//    }
    
    internal struct Parameters {
      var spawnWidth: CGFloat = 700.0
      var snowSize: CGFloat
      var snowLifetime: TimeInterval
    }
  }
}
