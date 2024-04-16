//
//  Confetti.swift
//
//
//  Created by Ben Myers on 4/15/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Confetti: Entity, PresetEntry {
    
    static public var `default`: Preset.Confetti = .init()
    
    public var parameters: [String : (PresetParameter, PartialKeyPath<Self>)] {[:]}
    
    public var body: some Entity {
      ForEach(1 ... 33, merges: .entities) { _ in
        particle(Circle().frame(width: 10.0, height: 10.0))
        particle(Rectangle().frame(width: 10.0, height: 10.0))
      }
    }
    
    private func particle<V>(_ body: V) -> some Entity where V: View {
      Particle(view: { body.foregroundColor(.red) })
        .lifetime(20)
        .hueRotation(angleIn: .zero ... .degrees(360.0))
        .initialPosition { c in
            .init(x: .random(in: 0.0 ... c.system.size.width), y: 0.0)
        }
        .initialAcceleration(xIn: 0.0 ... 0.0, yIn: 0.004 ... 0.005)
        .delay(in: 0.0 ... 2.0)
        .fixRotation(with: { c in
            .degrees(c.timeAlive * 100)
        })
        .scale(with: { c in
            .init(width: sin(5 * c.proxy.seed.2 * c.timeAlive + 2 * .pi * c.proxy.seed.1), height: 1)
        })
        .fixVelocity(with: { c in
            .init(dx: sin(2 * c.timeAlive + 2 * .pi * c.proxy.seed.3), dy: c.proxy.velocity.dy + 0.01 * sin(4 * c.timeAlive + 2 * .pi * c.proxy.seed.3))
        })
        .rotation3D { c in
          (
            .degrees(90 * c.proxy.seed.2 + 15 * cos(2 * c.timeAlive + 2 * .pi * c.proxy.seed.0)),
            .degrees(20 * sin(2 * c.timeAlive + 2 * .pi * c.proxy.seed.1)),
            .degrees(0)
          )
        }
    }
    
    public init() {}
  }
}
