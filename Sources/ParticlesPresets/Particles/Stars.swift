//
//  Stars.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Stars: Entity, PresetEntry {
    
    public var metadata: PresetMetadata {
      .init(
        name: "Stars",
        target: "ParticlesPresets",
        description: "Create a beautiful night sky inside a SwiftUI view.",
        author: "benlmyers",
        version: 1
      )
    }
    
    private var parameters: Parameters
    
    public init(size: CGFloat = 30.0, lifetime: TimeInterval = 5.0, intensity: Int = 20, twinkle: Bool = true) {
      self.parameters = .init(intensity: intensity, starSize: size, starLifetime: lifetime, twinkle: twinkle)
    }
    
    public var body: some Entity {
      Emitter(every: 1.0 / Double(parameters.intensity)) {
        Star(parameters: parameters)
      }
      .emitAll()
    }
    
    public struct Star: Entity {
      
      internal var parameters: Stars.Parameters
      
      public var body: some Entity {
        Particle {
          Image("sparkle", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: parameters.starSize, height: parameters.starSize)
        }
        .initialPosition { c in
          let x = Int.random(in: 0 ... Int(c.system.size.width))
          let y = Int.random(in: 0 ... Int(c.system.size.width))
          return CGPoint(x: x, y: y)
        }
        .transition(.opacity, duration: 3.0)
        .opacity { c in
          return 0.5 + sin(c.timeAlive)
        }
        .scale(factorIn: 0.5 ... 1.0)
        .blendMode(.plusLighter)
      }
    }
    
    internal struct Parameters {
      var intensity: Int = 3
      var starSize: CGFloat
      var starLifetime: TimeInterval
      var twinkle: Bool = false
    }
  }
}
