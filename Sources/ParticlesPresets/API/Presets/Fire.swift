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
  
  /// A fire particle effect.
  struct Fire: Entity, PresetEntry {
    
    public static let defaultInstance = Self.init()
    
    public var body: some Entity {
      Emitter(every: 0.01) {
        flame
      }
    }
    
    internal var color: Color
    internal var size: CGFloat
    internal var radius: CGSize
    internal var lifetime: Double
    
    /// Initializes Fire with specified properties.
    /// - Parameter color: The color of the entity. Default `.red`.
    /// - Parameter size: The size of the entity. Default `10.0`.
    /// - Parameter radius: The radius of the entity. Default `CGSize(width: 20.0, height: 4.0)`.
    /// - Parameter lifetime: The lifetime of the entity. Default `1.0`.
    public init(
      color: Color = .red,
      size: CGFloat = 10.0,
      radius: CGSize = .init(width: 20.0, height: 4.0),
      lifetime: Double = 1.0
    ) {
      self.color = color
      self.size = size
      self.radius = radius
      self.lifetime = lifetime
    }
    
    /// A single fire flame.
    public var flame: some Entity {
      Particle {
        RadialGradient(
          colors: [color, .clear],
          center: .center,
          startRadius: 0.0,
          endRadius: size * 0.8
        )
        .clipShape(Circle())
      }
      .initialOffset(xIn: -radius.width/2.0 ... radius.width/2.0, yIn: -radius.height/2.0 ... radius.height/2.0)
      .hueRotation(angleIn: .degrees(0.0) ... .degrees(50.0))
      .initialVelocity(xIn: -0.4 ... 0.4, yIn: -1 ... 0.5)
      .fixAcceleration(y: -0.05)
      .lifetime(in: 1.0 +/- 0.2)
      .glow(color.opacity(0.5), radius: 18.0)
      .blendMode(.plusLighter)
      .transition(.scale, on: .death, duration: 0.5)
      .transition(.opacity, on: .birth, duration: 0.3)
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
