//
//  Leaves.swift
//
//
//  Created by Ben Myers on 4/16/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  /// Leaves blowing in the wind.
  struct Leaves: Entity, PresetEntry {
    
    static public var `default`: Preset.Leaves = .init()
    
    public var parameters: [String : (PresetParameter, PartialKeyPath<Self>)] {[
      "Amount": (.intRange(50, min: 10, max: 300), \.amount),
      "Wind Speed": (.doubleRange(1.0, min: 0.1, max: 3.0), \.windSpeed),
      "Scale": (.doubleRange(1.0, min: 0.1, max: 5.0), \.scale)
    ]}
    
    /// The amount of leaves to spawn.
    public var amount: Int = 50
    /// The speed factor of wind. Default `1.0`.
    public var windSpeed: Double = 1.0
    /// The scale factor of the leaves. Default `1.0`.
    public var scale: Double = 1.0
    
    public var body: some Entity {
      ForEach(0 ..< amount, merges: .entities) { _ in
        Leaf(scale: scale)
          .initialPosition(with: { c in
              .init(x: .random(in: -c.system.size.width * 0.7 ... 0.0), y: .random(in: 0.0 ... c.system.size.height * 0.5))
          })
          .initialVelocity(xIn: 1.0 ... 3.0, yIn: 0.2 ... 0.6)
          .fixAcceleration { c in
              .init(dx: 0.001 * cos(c.timeAlive + 2 * .pi * c.proxy.seed.3), dy: 0.003 * c.proxy.seed.1 * sin(c.timeAlive + 2 * .pi * c.proxy.seed.0))
          }
      }
    }
    
    public init(amount: Int = 50, windSpeed: Double = 1.0, scale: Double = 1.0) {
        self.amount = amount
        self.windSpeed = windSpeed
        self.scale = scale
    }
    
    /// A single leaf particle.
    public struct Leaf: Entity {
      
      /// The scale factor of the leaf. Default `1.0`.
      public var scale: Double = 1.0
      
      public var body: some Entity {
        Particle {
          Image("leaf", bundle: .module).resizable().frame(width: 20.0, height: 20.0)
        }
        .lifetime(in: 5.0 ... 8.0)
        .transition(.scale, duration: 1.0)
        .scale(factorIn: scale +/- 0.4)
        .hueRotation(angleIn: .degrees(0) ... .degrees(30))
        .fixTorque(with: { c in
            .degrees(cos(c.timeAlive + 2 * .pi * c.proxy.seed.3))
        })
      }
    }
  }
}
