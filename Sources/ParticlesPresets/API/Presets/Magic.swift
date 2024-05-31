//
//  Magic.swift
//
//
//  Created by Ben Myers on 3/22/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  /// A Magic effect that bursts outward radially.
  struct Magic: Entity, PresetEntry {
    
    static public var defaultInstance: Self = .init()
    
    var color: Color
    var intensity: Int
    var lifetime: TimeInterval
    
    public var body: some Entity {
      Emitter(rate: Double(intensity)) {
        Particle {
          RadialGradient(
            colors: [color, .clear],
            center: .center,
            startRadius: 0.0,
            endRadius: 10.0
          )
          .clipShape(Circle())
          .frame(width: 15.0, height: 15.0)
        }
        .initialPosition(.center)
        .initialVelocity { c in
            .init(angle: .random(), magnitude: .random(in: 0.3 ... 0.5))
        }
        .fixVelocity{ c in
          return .init(dx: c.proxy.velocity.dx + c.timeAlive * 0.02 * sin(5 * (c.proxy.seed.0 - 0.5) * c.timeAlive), dy: c.proxy.velocity.dy - c.timeAlive * 0.02 * cos(5 * (c.proxy.seed.1 - 0.5) * c.timeAlive))
        }
        .blendMode(.plusLighter)
        .hueRotation(angleIn: .degrees(-10.0) ... .degrees(10.0))
        .transition(.twinkle, on: .death, duration: 2.0)
        .transition(.opacity, on: .birth, duration: 0.5)
        .lifetime(lifetime)
        .glow(color, radius: 4)
      }
    }
    
    /// Initializes Magic with specified properties.
    /// - Parameter color: The color of the entity. Default `.purple`.
    /// - Parameter intensity: The intensity of the entity. Default `30`.
    public init(
      color: Color = .purple,
      intensity: Int = 30,
      lifetime: TimeInterval = 3.0
    ) {
      self.color = color
      self.intensity = intensity
      self.lifetime = lifetime
    }
    
    public func customizableParameters() -> [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] {
      var result: [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] = [
        ("Intensity", .intRange(30, min: 1, max: 100), \.intensity),
        ("Lifetime", .doubleRange(3.0, min: 0.5, max: 2.0), \.lifetime)
      ]
#if !os(watchOS)
      result.append(("Color", .color(.purple), \.color))
#endif
      return result
    }
  }
}
