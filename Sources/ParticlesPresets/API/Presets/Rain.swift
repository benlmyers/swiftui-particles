//
//  Rain.swift
//
//
//  Created by Ben Myers on 3/20/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  /// A rain effect.
  struct Rain: Entity, PresetEntry {
    
    internal var lifetime: TimeInterval
    internal var intensity: Int
    internal var wind: CGFloat
    
    public var body: some Entity {
      Emitter(every: 1.0 / Double(intensity)) {
        drop
      }
      .emitAll()
      .initialPosition(.top)
    }
    
    /// An individual raindrop.
    public var drop: some Entity {
      Particle {
        Rectangle().frame(width: 3.0, height: 12.0)
          .foregroundColor(.blue)
      }
      .initialOffset(withX: { c in
        let w = c.system.size.width * 0.5
        return .random(in: -w ... w)
      })
      .initialVelocity(xIn: wind +/- 1, yIn: 13 ... 15)
      .initialAcceleration(y: 0.1)
      .opacity(in: 0.5 ... 1.0)
      .transition(.opacity)
      .lifetime(lifetime)
      .initialRotation(.degrees(-5.0 * wind))
      .hueRotation(angleIn: .degrees(-10.0) ... .degrees(10.0))
      .blendMode(.plusLighter)
      .scale { c in
        let s = CGFloat.random(in: 0.3 ... 1.0, seed: c.proxy.seed.0)
        return CGSize(width: s /** cos(0.1 * c.system.time + c.proxy.seed.1)*/, height: s)
      }
    }
    
    public init(
      lifetime: TimeInterval = 1.0,
      intensity: Int = 20,
      wind: CGFloat = 0.5
    ) {
      self.lifetime = lifetime
      self.intensity = intensity
      self.wind = wind
    }
    
    
    public func customizableParameters() -> [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] {[
      ("Intensity", .intRange(20, min: 1, max: 100), \.intensity),
      ("Wind", .floatRange(0.5, min: -3.0, max: 3.0), \.wind)
    ]}
  }
}
