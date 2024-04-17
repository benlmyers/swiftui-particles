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
    
    static public var `default`: Self = .init()
    
    public var parameters: [String: (PresetParameter, PartialKeyPath<Self>)] {[:]}
    
    var color: Color
    var spawnPoint: UnitPoint
    var spawnRadius: CGSize
    var flameSize: CGFloat = 25.0
    var flameLifetime: TimeInterval = 1
    
    public var body: some Entity {
      return Group {
        Group {
          Emitter(every: 14.0) {
            Particle {
              RadialGradient(
                colors: [Color.pink, Color.red],
                center: .center,
                startRadius: 0.0,
                endRadius: 10
              )
              .clipShape(Circle())
            }
            .hueRotation(angleIn: .degrees(0) ... .degrees(360))
            .lifetime(12)
            .glow(Color.red.opacity(0.5), radius: 40.0)
            .initialVelocity(x: 2, y: -2)
            .initialPosition { c in
              let pairs = [(-600, 500), (Int(c.system.size.width) - 600, Int(c.system.size.height) + 500)]
              let randomPair = pairs.randomElement()!
              return CGPoint(x: randomPair.0, y: randomPair.1)
            }
          }
          CometStars()
          Emitter(every: 0.01) {
            CometStar(
              color: color,
              spawnPoint: spawnPoint,
              flameSize: flameSize,
              spawnRadius: spawnRadius
            )
          }
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
  
  internal struct CometStar: Entity {
    var color: Color
    var spawnPoint: UnitPoint
    var spawnRadius: CGSize
    var flameSize: CGFloat = 25.0
    var flameLifetime: TimeInterval = 1

    var body: some Entity {
      Particle {
        RadialGradient(
          colors: [Color.blue, Color.clear],
          center: .center,
          startRadius: 0.0,
          endRadius: 50.0 * 0.8
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
  
  internal struct CometStars: Entity {
    public var body: some Entity {
      Emitter(every: 0.01) {
        Star()
      }
    }
    public struct Star: Entity {
      public var body: some Entity {
        Particle {
          Circle()
            .frame(width: 14.0, height: 14.0)
        }
        .initialPosition { c in
          let x = Int.random(in: 0 ... Int(c.system.size.width))
          let y = Int.random(in: 0 ... Int(c.system.size.height))
          return CGPoint(x: x, y: y)
        }
        .opacity { c in
          return 1.0 * (c.timeAlive)
        }
        .lifetime(in: 3.0 +/- 1.0)
        .scale(factorIn: 0.1 ... 0.6)
        .blendMode(.plusLighter)
        .initialVelocity(xIn: 0.2 ... 0.8, yIn: -0.5 ... 0.25)
        .fixAcceleration(x: 0.3, y: -0.3)
      }
    }
  }
}
