//
//  Smoke.swift
//
//
//  Created by Demirhan Mehmet Atabey on 22.03.2024.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Smoke: Entity, PresetEntry {
    
    static public let defaultInstance: Self = .init()
    
    internal var color: Color
    internal var size: CGFloat
    internal var radius: CGSize
    internal var dirty: Bool
    
    public var body: some Entity {
      Emitter(every: 0.01) {
        Particle {
          RadialGradient(
            colors: [color, .clear],
            center: .center,
            startRadius: size / 4.0,
            endRadius: size
          )
          .clipShape(Circle())
        }
        .initialOffset(xIn: -radius.width ... radius.width/2, yIn: -radius.height/2 ... radius.height/2)
        .initialVelocity(xIn: -0.5 ... 0.5, yIn: -3.0 ... 1.0)
        .fixAcceleration(y: -0.02)
        .lifetime(in: 3 +/- 0.2)
        .blendMode(dirty ? .hardLight : .normal)
        .transition(.scale, on: .death, duration: 0.5)
        .transition(.opacity, on: .birth)
        .opacity(0.3)
      }
    }
    
    /// Initializes Smoke with the specified properties.
    /// - Parameter color: The color of the entity. Default `Color(red: 128/255, green: 128/255, blue: 128/255, opacity: 1)`.
    /// - Parameter size: The size of the entity. Default `30.0`.
    /// - Parameter radius: The radius of the entity. Default `CGSize(width: 40.0, height: 8.0)`.
    /// - Parameter dirty: A flag indicating if the entity is dirty. Default `false`.
    public init(
      color: Color = Color(red: 128/255, green: 128/255, blue: 128/255, opacity: 1),
      size: CGFloat = 30.0,
      radius: CGSize = .init(width: 40.0, height: 8.0),
      dirty: Bool = false
    ) {
      self.color = color
      self.size = size
      self.radius = radius
      self.dirty = dirty
    }
    
    public func customizableParameters() -> [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] {
          var result: [(name: String, parameter: PresetParameter, keyPath: PartialKeyPath<Self>)] = [
            ("Size", .floatRange(30.0, min: 10.0, max: 70.0), \.size),
            ("Dirty", .bool(false), \.dirty)
          ]
    #if !os(watchOS)
          result.append(("Color", .color(Color(red: 128/255, green: 128/255, blue: 128/255, opacity: 1)), \.color))
    #endif
          return result
        }
  }
}
