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
    
    public var parameters: [String : (PresetParameter, PartialKeyPath<Self>)] {[
      "Color": (.color(.red), \.color),
      "Size": (.floatRange(10.0, min: 5.0, max: 50.0), \.flameSize),
      "Lifetime": (.doubleRange(1.0, min: 0.1, max: 5.0), \.flameLifetime)
    ]}
    
    var color: Color = .red
    var spawnRadius: CGSize
    var flameSize: CGFloat = 10.0
    var flameLifetime: TimeInterval = 1
    
    public var body: some Entity {
      Emitter(every: 0.01) {
        Particle {
          RadialGradient(
            colors: [color, .clear],
            center: .center,
            startRadius: 0.0,
            endRadius: flameSize * 0.8
          )
          .clipShape(Circle())
        }
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .hueRotation(angleIn: .degrees(0.0) ... .degrees(50.0))
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialVelocity(xIn: -0.4 ... 0.4, yIn: -1 ... 0.5)
        .fixAcceleration(y: -0.05)
        .lifetime(in: 1 +/- 0.2)
        .glow(color.opacity(0.5), radius: 18.0)
        .blendMode(.plusLighter)
        .transition(.scale, on: .death, duration: 0.5)
        .transition(.opacity, on: .birth, duration: 0.3)
      }
    }
    
    public init(
      color: Color = .red,
      flameSize: CGFloat = 10.0,
      spawnRadius: CGSize = .init(width: 20.0, height: 4.0)
    ) {
      self.color = color
      self.flameSize = flameSize
      self.spawnRadius = spawnRadius
    }
  }
}
