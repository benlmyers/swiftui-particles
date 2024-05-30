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
  
  /// A Comet entity that can be customized with various properties.
  struct Comet: Entity, PresetEntry {
    
    static public var defaultInstance: Self = .init()
    
    /// The color of the comet.
    var color: Color
    
    /// The size (width) of the comet.
    var size: CGFloat
    
    /// The lifetime of the comet.
    var lifetime: TimeInterval
    
    /// The direction of the comet.
    var direction: Angle
    
    public var body: some Entity {
      Emitter(every: 0.01) {
        trail
      }
    }
    
    /// The trail of the comet.
    public var trail: some Entity {
      Particle {
        RadialGradient(
          colors: [Color.blue, Color.clear],
          center: .center,
          startRadius: 0.0,
          endRadius: 50.0 * 0.8
        )
        .clipShape(Circle())
      }
      .hueRotation(angleIn: .degrees(0.0) ... .degrees(20.0))
      .fixAcceleration(x: 4.0 * cos(direction), y: 4.0 * sin(direction))
      .lifetime(in: 2 +/- 0.5)
      .glow(color.opacity(0.9), radius: 18.0)
      .blendMode(.plusLighter)
      .transition(.scale, on: .death, duration: 0.5)
      .fixScale { c in
        return 1.0 - (c.timeAlive * 0.1)
      }
    }
    
    /// Initializes a Comet with specified properties.
    /// - Parameter color: The color of the comet. Default `.blue`.
    /// - Parameter size: The size (width) of the comet. Default `50.0`.
    /// - Parameter lifetime: The lifetime of the comet. Default `1.0`.
    /// - Parameter direction: The direction of the comet. Default `.init(degrees: -45.0)`.
    public init(
      color: Color = .blue,
      size: CGFloat = 50.0,
      lifetime: TimeInterval = 1.0,
      direction: Angle = .init(degrees: -45.0)
    ) {
      self.color = color
      self.size = size
      self.lifetime = lifetime
      self.direction = direction
    }
    
    public func customizableParameters() -> [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] {
      var result: [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] = [
        ("Size", .floatRange(18.0, min: 10.0, max: 40.0), \.size),
        ("Lifetime", .doubleRange(1.0, min: 0.5, max: 2.0), \.lifetime)
      ]
#if !os(watchOS)
      result.append(("Color", .color(.red), \.color))
#endif
      return result
    }
  }
}
