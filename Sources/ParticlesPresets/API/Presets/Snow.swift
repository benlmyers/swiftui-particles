//
//  Snow.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Snow: Entity, PresetEntry {
    
    internal var intensity: Int
    internal var size: CGFloat
    internal var lifetime: TimeInterval
    
    public var body: some Entity {
      Emitter(rate: Double(intensity)) {
        flake
        drift
      }
      .emitAll()
      .initialPosition(.top)
    }
    
    /// An indiviudal snow flake.
    public var flake: some Entity {
      Particle {
        Image("snow1", bundle: .module)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: size, height: size)
      }
      .initialOffset(withX: { c in
        let w = c.system.size.width * 0.5
        return .random(in: -w ... w)
      })
      .initialPosition(.top)
      .initialVelocity(xIn: -1.0 ... 1.0, yIn: 0.2 ... 0.8)
      .fixAcceleration{ c in
        return CGVectorMake(0.005 * sin(c.proxy.seed.2 + c.system.time * 1.8), 0.01)
      }
      .opacity(in: 0.2 ... 0.8)
      .transition(.opacity, duration: 1.0)
      .colorOverlay(.init(red: 0.7, green: 0.9, blue: 0.9))
      .initialTorque(angleIn: .degrees(-2.0) ... .degrees(2.0))
      .hueRotation(angleIn: .degrees(-30.0) ... .degrees(30.0))
      .blendMode(.plusLighter)
      .blur(in: 0.0 ... 2.0)
      .scale { c in
        let s = CGFloat.random(in: 0.3 ... 1.0, seed: c.proxy.seed.0)
        return CGSize(width: s /** cos(0.1 * c.system.time + c.proxy.seed.1)*/, height: s)
      }
    }
    
    /// An individual snow drift.
    public var drift: some Entity {
      Particle {
        RadialGradient(colors: [.white, .clear], center: .center, startRadius: 0.0, endRadius: 5.0)
          .frame(width: 10.0, height: 10.0)
          .clipShape(Circle())
      }
      .initialOffset(withX: { c in
        let w = c.system.size.width * 0.5
        return .random(in: -w ... w)
      })
      .initialPosition(.top)
      .initialVelocity(xIn: -4 ... 0.4, yIn: 1.0 ... 3.0)
      .fixAcceleration{ c in
        return CGVectorMake(0.04 * sin(c.proxy.seed.2 + c.system.time * 1.8), 0.007 + 0.008 * cos(c.system.time * 1.8))
      }
      .opacity(in: 0.2 ... 0.8)
      .scale(factorIn: 0.2 ... 1.4)
      .transition(.scale)
      .lifetime(3)
    }
    
    /// Creates a Snow scene, with snow and drift falling from the top of the system.
    /// - Parameter size: The size of the snow. Default `30.0`.
    /// - Parameter lifetime: The lifetime of the snow. Default `5.0`.
    /// - Parameter intensity: How much snow is emitted. Default `20`.
    public init(
      size: CGFloat = 30.0,
      lifetime: TimeInterval = 5.0,
      intensity: Int = 20
    ) {
      self.size = size
      self.lifetime = lifetime
      self.intensity = intensity
    }
    
    public func customizableParameters() -> [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] {[
      ("Size", .floatRange(18.0, min: 10.0, max: 40.0), \.size),
      ("Lifetime", .doubleRange(1.0, min: 0.5, max: 2.0), \.lifetime),
      ("Intensity", .intRange(20, min: 5, max: 50), \.intensity)
    ]}
  }
}
