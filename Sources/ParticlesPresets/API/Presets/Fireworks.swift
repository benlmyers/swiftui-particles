//
//  Fireworks.swift
//
//
//  Created by Demirhan Mehmet Atabey on 31.03.2024.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Fireworks: Entity, PresetEntry {
    
    static public var `default`: Self = .init()
    
    public var parameters: [String: (PresetParameter, PartialKeyPath<Self>)] {[:]}
    
    private var _parameters: Parameters
    
    public init (shootFor shootDuration: TimeInterval = 1.0, color: Color = .blue, spread: Double = 1.0) {
      self._parameters = .init(shootDuration: shootDuration, color: color, spread: spread)
    }
    
    public var body: some Entity {
      Group {
        ForEach(0 ... 500, merges: .views) { i in
          Particle {
            RadialGradient(colors: [_parameters.color, .clear], center: .center, startRadius: 0.0, endRadius: 4.0)
              .clipShape(Circle())
              .frame(width: 4.0, height: 4.0)
          }
          .initialPosition(.center)
          .lifetime(4)
          .transition(.twinkle, on: .death, duration: 3.0)
          .blendMode(.plusLighter)
          .glow(radius: 6.0)
          .onUpdate { p, c in
            if c.time < _parameters.shootDuration {
              p.velocity = .zero
              p.opacity = .zero
            } else {
              p.opacity = 1.0
              if p.velocity == .zero {
                p.velocity = .init(angle: .degrees(Double(i) * 7), magnitude: _parameters.spread * Double.random(in: 0.1 ... 3.0))
              } else {
                p.velocity.dx *= 0.98
                p.velocity.dy *= 0.98
              }
            }
          }
        }
        Emitter(every: 0.04) {
          Particle {
            RadialGradient(colors: [Color.yellow, .clear], center: .center, startRadius: 0.0, endRadius: 4.0)
              .clipShape(Circle())
              .frame(width: 4.0, height: 4.0)
          }
          .lifetime(2.0)
          .transition(.scale, on: .death, duration: 1.0)
          .initialVelocity(xIn: -0.3 ... 0.3, yIn: -0.3 ... 0.3)
          .initialAcceleration(y: 0.003)
          .blur(in: 0.0 ... 5.0)
          .opacity(in: 0.2 ... 0.5)
          .blendMode(.plusLighter)
        }
        .maxSpawn(count: 30)
        .onUpdate { p, c in
          if p.position.y < c.size.height * 0.5 {
            p.position.y = c.size.height
          }
        }
        .lifetime(10)
        .initialPosition(.bottom)
        .initialVelocity { c in
            .init(dx: 0.0, dy: -0.01 * c.system.size.height / _parameters.shootDuration)
        }
        .fixAcceleration(y: 0.05)
      }
    }
    
    internal struct Parameters {
      var shootDuration: TimeInterval
      var color: Color
      var spread: Double = 1.0
    }
  }
}
