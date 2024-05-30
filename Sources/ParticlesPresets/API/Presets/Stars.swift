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
    
    static public let defaultInstance: Self = .init()
    
    internal var intensity: Int = 3
    internal var size: CGFloat
    internal var lifetime: TimeInterval
    internal var twinkle: Bool = false
    
    public var body: some Entity {
      Emitter(every: 1.0 / Double(intensity)) {
        star
          .initialPosition { c in
            let x = Int.random(in: 0 ... Int(c.system.size.width))
            let y = Int.random(in: 0 ... Int(c.system.size.height))
            return CGPoint(x: x, y: y)
          }
      }
      .emitAll()
    }
    
    /// A single star particle.
    public var star: some Entity {
      Particle {
        Image("sparkle", bundle: .module)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: size, height: size)
      }
      
      .transition(.opacity, duration: 3.0)
      .opacity { c in
        return 0.5 + sin(c.timeAlive)
      }
      .scale(factorIn: 0.5 ... 1.0)
      .blendMode(.plusLighter)
    }
    
    /// Creates a sky of stars.
    /// - Parameter size: The size of each star.
    /// - Parameter lifetime: The lifetime of each star.
    /// - Parameter intensity: The amount of stars to spawn.
    /// - Parameter twinkle: Whether the stars should twinkle.
    public init(
      size: CGFloat = 30.0,
      lifetime: TimeInterval = 5.0,
      intensity: Int = 20,
      twinkle: Bool = true
    ) {
      self.size = size
      self.lifetime = lifetime
      self.intensity = intensity
      self.twinkle = twinkle
    }
    
    public func customizableParameters() -> [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] {[
      ("Size", .floatRange(18.0, min: 10.0, max: 40.0), \.size),
      ("Lifetime", .doubleRange(1.0, min: 0.5, max: 2.0), \.lifetime),
      ("Intensity", .intRange(20, min: 5, max: 50), \.intensity),
      ("Twinkle", .bool(true), \.twinkle)
    ]}
  }
}
