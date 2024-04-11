//
//  Comet.swift
//
//
//  Created by Demirhan Mehmet Atabey on 6.04.2024.
//


import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Comet: Entity, PresetEntry {
    
    public var parameters: [String: (PresetParameter, PartialKeyPath<Self>)] {[:]}
    
    var color: Color
    var spawnPoint: UnitPoint
    var spawnRadius: CGSize
    var flameSize: CGFloat = 25.0
    var flameLifetime: TimeInterval = 1
    
    public var body: some Entity {
      Emitter(every: 0.01) {
        Particle {
          RadialGradient(
            colors: [color, Color.clear],
            center: .center,
            startRadius: 0.0,
            endRadius: flameSize * 0.8
          )
          .clipShape(Circle())
        }
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialPosition(.center)
        .hueRotation(angleIn: .degrees(0.0) ... .degrees(20.0))
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialVelocity(xIn: 0.2 ... 0.8, yIn: -0.5 ... 0.25)
        .fixAcceleration(x: 0.4, y: -0.4)
        .lifetime(in: 2 +/- 0.5)
        .glow(color.opacity(0.9), radius: 18.0)
        .blendMode(.plusLighter)
        .transition(.scale, on: .death, duration: 0.5)
//        .transition(.twinkle, on: .birth, duration: 0.3)
        .fixScale { c in
          return 1.0 - (c.timeAlive * 0.1)
        }
      }
    }
    
    public init(
      color: Color = Color.blue,
      spawnPoint: UnitPoint = .center,
      flameSize: CGFloat = 50.0,
      spawnRadius: CGSize = .init(width: 8.0, height: 8.0)
    ) {
      self.color = color
      self.spawnPoint = spawnPoint
      self.flameSize = flameSize
      self.spawnRadius = spawnRadius
    }
  }
}
