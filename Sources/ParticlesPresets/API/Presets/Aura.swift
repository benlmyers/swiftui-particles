//
//  Aura.swift
//
//
//  Created by Ben Myers on 5/29/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Aura: Entity, PresetEntry {
    
    internal var color: Color
    internal var hueVariation: Angle
    internal var size: CGFloat
    internal var intensity: Int
    
    public var body: some Entity {
      Emitter(rate: Double(intensity)) {
        Particle {
          RadialGradient(colors: [color, Color.clear], center: .center, startRadius: 0.0, endRadius: size)
            .opacity(0.1)
        }
        .initialPosition { c in
          CGPoint(x: Int.random(in: 0 ... Int(c.system.size.width)), y: Int.random(in: 0 ... Int(c.system.size.height)))
        }
        .scale(with: { c in
          CGSize(width: 1.0 + 0.2 * c.proxy.seed.2 * sin(c.timeAlive), height: 1.0 + 0.2 * c.proxy.seed.0 * cos(c.timeAlive))
        })
        .fixTorque(with: { c in
          Angle(degrees: sin(c.timeAlive))
        })
        .initialVelocity(xIn: -1.0 ... 1.0, yIn: -1.0 ... 1.0)
        .transition(.opacity, duration: 3.0)
        .lifetime(in: 7.5 ... 12.5)
        .hueRotation(angleIn: .zero ... hueVariation)
        .blendMode(.lighten)
      }
    }
    
    public init(
      color: Color = .red,
      hueVariation: Angle = .degrees(30.0),
      size: CGFloat = 300.0,
      intensity: Int = 50
    ) {
      self.color = color
      self.hueVariation = hueVariation
      self.size = size
      self.intensity = intensity
    }
    
    public func customizableParameters() -> [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Preset.Aura>)] {[
      ("Size", .floatRange(70.0, min: 30.0, max: 100.0), \.size),
      ("Color", .color(.red), \.color),
      ("Intensity", .intRange(50, min: 10, max: 100), \.intensity),
      ("Hue Variation", .angle(.degrees(30.0)), \.hueVariation)
    ]}
  }
}
