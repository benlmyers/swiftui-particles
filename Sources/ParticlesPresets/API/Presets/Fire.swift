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
    
    static public var `default`: Preset.Fire = .init()
    
    public var parameters: [String : (PresetParameter, PartialKeyPath<Self>)] {
      var result: [String : (PresetParameter, PartialKeyPath<Self>)] = [
        "Size": (.floatRange(18.0, min: 10.0, max: 40.0), \._parameters.flameSize),
        "Lifetime": (.doubleRange(1.0, min: 0.5, max: 2.0), \._parameters.flameLifetime)
      ]
      
#if !os(watchOS)
      result["Color"] = (.color(.red), \._parameters.color)
#endif
      
      return result
    }
    
    public var body: some Entity {
      Emitter(every: 0.01) {
        Flame(parameters: _parameters)
      }
    }
    
    internal var _parameters: Parameters
    
    public init(
      color: Color = .red,
      flameSize: CGFloat = 10.0,
      spawnRadius: CGSize = .init(width: 20.0, height: 4.0)
    ) {
      self._parameters = .init(color: color, spawnRadius: .zero, flameSize: flameSize, flameLifetime: 1)
    }
    
    public struct Flame: Entity {
      
      internal var parameters: Fire.Parameters
      
      public var body: some Entity {
        Particle {
          RadialGradient(
            colors: [parameters.color, .clear],
            center: .center,
            startRadius: 0.0,
            endRadius: parameters.flameSize * 0.8
          )
          .clipShape(Circle())
        }
        .initialOffset(xIn: -parameters.spawnRadius.width/2 ... parameters.spawnRadius.width/2, yIn: -parameters.spawnRadius.height/2 ... parameters.spawnRadius.height/2)
        .hueRotation(angleIn: .degrees(0.0) ... .degrees(50.0))
        .initialVelocity(xIn: -0.4 ... 0.4, yIn: -1 ... 0.5)
        .fixAcceleration(y: -0.05)
        .lifetime(in: parameters.flameLifetime +/- parameters.flameLifetime * 0.2)
        .glow(parameters.color.opacity(0.5), radius: 18.0)
        .blendMode(.plusLighter)
        .transition(.scale, on: .death, duration: 0.5)
        .transition(.opacity, on: .birth, duration: 0.3)
      }
      
      public init() {
        self.parameters = .init(color: .red, spawnRadius: .zero, flameSize: 10.0, flameLifetime: 1.0)
      }
      
      internal init(parameters: Fire.Parameters) {
        self.parameters = parameters
      }
    }
    
    internal struct Parameters {
      var color: Color
      var spawnRadius: CGSize
      var flameSize: CGFloat
      var flameLifetime: TimeInterval
    }
  }
}
