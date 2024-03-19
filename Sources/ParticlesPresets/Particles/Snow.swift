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
    
    public init(in width: CGFloat = 750.0, size: CGFloat = 30.0, lifetime: TimeInterval = 5.0, intensity: Int = 50) {
      self.parameters = .init(intensity: intensity, spawnWidth: width, snowSize: size, snowLifetime: lifetime)
    }
    
    public var body: some Entity {
      Emitter(interval: 1.0 / Double(parameters.intensity)) {
        Flake(parameters: parameters)
        Drift(parameters: parameters)
      }
      .emitSingle()
      .initialPosition(.top)
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
        .initialOffset(xIn: -parameters.spawnWidth/2.0 ... parameters.spawnWidth/2.0)
        .initialVelocity(xIn: -0.1 ... 0.1, yIn: 0.02 ... 0.08)
        .fixAcceleration({ c in
          return CGVectorMake(0.0005 * sin(c.physics.seed.2 + c.system.time * 1.8), 0.001)
        })
        .opacity(in: 0.2 ... 0.8)
        .transition(.opacity)
        .colorOverlay(.init(red: 0.7, green: 0.9, blue: 0.9))
        .initialTorque(angleIn: .degrees(-0.2) ... .degrees(0.2))
        .hueRotation(angleIn: .degrees(-30.0) ... .degrees(30.0))
        .blendMode(.plusLighter)
        .blur(in: 0.0 ... 2.0)
        .scale { c in
          let s = CGFloat.random(in: 0.3 ... 1.0, seed: c.physics.seed.0)
          return CGSize(width: s /** cos(0.1 * c.system.time + c.physics.seed.1)*/, height: s)
        }
      }
    }
    
    public struct Drift: Entity {
      
      internal var parameters: Snow.Parameters
      
      public var body: some Entity {
        Particle {
          RadialGradient(colors: [.white, .clear], center: .center, startRadius: 0.0, endRadius: 5.0)
            .frame(width: 10.0, height: 10.0)
            .clipShape(Circle())
        }
        .initialOffset(xIn: -parameters.spawnWidth/2.0 ... parameters.spawnWidth/2.0, yIn: -10.0 ... 0.0)
        .initialVelocity(xIn: -0.4 ... 0.4, yIn: 0.01 ... 0.03)
        .fixAcceleration({ c in
          return CGVectorMake(0.0004 * sin(c.physics.seed.2 + c.system.time * 1.8), 0.0007 + 0.0008 * cos(c.system.time * 1.8))
        })
        .opacity(in: 0.2 ... 0.8)
        .scale(factorIn: 0.2 ... 1.4)
        .transition(.scale)
        .lifetime(3)
      }
    }
    
    internal struct Parameters {
      var intensity: Int = 50
      var spawnWidth: CGFloat = 700.0
      var snowSize: CGFloat
      var snowLifetime: TimeInterval
    }
  }
}
