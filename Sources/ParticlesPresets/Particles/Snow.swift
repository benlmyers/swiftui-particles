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
    
    public var metadata: PresetMetadata {
      .init(
        name: "Snow",
        target: "ParticlesPresets",
        description: "Create cool SwiftUI views with a snow effect.",
        author: "benlmyers",
        version: 1
      )
    }
    
    private var parameters: Parameters
    
    public init(size: CGFloat = 30.0, lifetime: TimeInterval = 5.0, intensity: Int = 20) {
      self.parameters = .init(intensity: intensity, snowSize: size, snowLifetime: lifetime)
    }
    
    public var body: some Entity {
      Emitter(every: 1.0 / Double(parameters.intensity)) {
        Flake(parameters: parameters)
        Drift(parameters: parameters)
      }
      .emitAll()
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
        .initialOffset(withX: { c in
          let w = c.system.size.width * 0.5
          return .random(in: -w ... w)
        })
        .initialVelocity(xIn: -1.0 ... 1.0, yIn: 0.2 ... 0.8)
        .fixAcceleration{ c in
          return CGVectorMake(0.005 * sin(c.proxy.seed.2 + c.system.time * 1.8), 0.01)
        }
        .opacity(in: 0.2 ... 0.8)
        .transition(.opacity)
        .colorOverlay(.init(red: 0.7, green: 0.9, blue: 0.9))
        .initialTorque(angleIn: .degrees(-2.0) ... .degrees(2.0))
        .hueRotation(angleIn: .degrees(-30.0) ... .degrees(30.0))
        .blendMode(.plusLighter)
        .blur(in: 0.0 ... 2.0)
        .scale { c in
          let s = CGFloat.random(in: 0.3 ... 1.0, seed: c.proxy.seed.0)
          return CGSize(width: s /** cos(0.1 * c.system.time + c.proxy.seed.1)*/, height: s)
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
        .initialOffset(withX: { c in
          let w = c.system.size.width * 0.5
          return .random(in: -w ... w)
        })
        .initialVelocity(xIn: -4 ... 0.4, yIn: 1.0 ... 3.0)
        .fixAcceleration{ c in
          return CGVectorMake(0.04 * sin(c.proxy.seed.2 + c.system.time * 1.8), 0.007 + 0.008 * cos(c.system.time * 1.8))
        }
        .opacity(in: 0.2 ... 0.8)
        .scale(factorIn: 0.2 ... 1.4)
        .transition(.scale)
        .lifetime(3)
      }
    }
    
    internal struct Parameters {
      var intensity: Int = 50
      var snowSize: CGFloat
      var snowLifetime: TimeInterval
    }
  }
}
