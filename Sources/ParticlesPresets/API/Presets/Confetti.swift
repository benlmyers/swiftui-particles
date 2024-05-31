//
//  Confetti.swift
///
///
//  Created by Ben Myers on 4/15/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  /// A Confetti entity that can be customized with various properties.
  struct Confetti: Entity, PresetEntry {
    
    internal var color: Color
    internal var hueVariation: Angle
    internal var size: CGFloat
    internal var lifetime: Double
    
    public var body: some Entity {
      ForEach(1 ... 33, merges: .entities) { _ in
        single(Circle().frame(width: size, height: size))
        single(Rectangle().frame(width: size, height: size))
      }
      .initialPosition { c in
        CGPoint(x: CGFloat.random(in: 0.0 ... c.system.size.width), y: 0.0)
      }
    }
    
    /// A single confetti particle.
    public func single<V>(_ body: V) -> some Entity where V: View {
      Particle(view: { body.foregroundColor(Color.red) })
        .lifetime(lifetime)
        .hueRotation(angleIn: Angle.zero ... hueVariation)
        .initialAcceleration(xIn: 0.0 ... 0.0, yIn: 0.004 ... 0.005)
        .delay(in: 0.0 ... 2.0)
        .fixRotation(with: { c in
          Angle.degrees(c.timeAlive * 100)
        })
        .scale(with: { c in
          CGSize(width: sin(5 * c.proxy.seed.2 * c.timeAlive + 2 * Double.pi * c.proxy.seed.1), height: 1)
        })
        .fixVelocity(with: { c in
          CGVector(dx: sin(2 * c.timeAlive + 2 * Double.pi * c.proxy.seed.3), dy: c.proxy.velocity.dy + 0.01 * sin(4 * c.timeAlive + 2 * Double.pi * c.proxy.seed.3))
        })
        .rotation3D { c in
          (
            Angle.degrees(90 * c.proxy.seed.2 + 15 * cos(2 * c.timeAlive + 2 * Double.pi * c.proxy.seed.0)),
            Angle.degrees(20 * sin(2 * c.timeAlive + 2 * Double.pi * c.proxy.seed.1)),
            Angle.degrees(0)
          )
        }
    }
    
    /// Initializes Confetti with specified properties.
    /// - Parameter color: The color of the confetti. Default `.red`.
    /// - Parameter hueVariation: The hue variation of the confetti. Default `.degrees(360.0)`.
    /// - Parameter size: The size of the confetti. Default `10.0`.
    /// - Parameter lifetime: The lifetime of the confetti. Default `5.0`.
    public init(
      color: Color = .red,
      hueVariation: Angle = .degrees(360.0),
      size: CGFloat = 10.0,
      lifetime: Double = 5.0
    ) {
      self.color = color
      self.hueVariation = hueVariation
      self.size = size
      self.lifetime = lifetime
    }
    
    public func customizableParameters() -> [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] {
      var result: [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] = [
        ("Size", .floatRange(18.0, min: 10.0, max: 40.0), \.size),
        ("Lifetime", .doubleRange(1.0, min: 0.5, max: 2.0), \.lifetime),
        ("Hue Variation", .angle(.degrees(360.0)), \.hueVariation)
      ]
#if !os(watchOS)
      result.append(("Color", .color(.red), \.color))
#endif
      return result
    }
  }
}
