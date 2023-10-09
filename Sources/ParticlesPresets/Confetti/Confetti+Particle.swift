//
//  Confetti+Particle.swift
//  
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import Particles
import ParticlesCore

public extension Confetti {
  
  class Particle: ParticlesCore.AdvancedParticle {
    
    public init(shape: Shape, size: Size) {
      super.init(from: ParticlesCore.AdvancedParticle(onDraw: { context in
        switch shape {
        case .square:
          context.translateBy(x: -size.value, y: -size.value)
          context.fill(.square(radius: size.value), with: .color(.white))
        case .circle:
          context.translateBy(x: -size.value, y: -size.value)
          context.fill(.circle(radius: size.value), with: .color(.white))
        case .rectangle:
          context.translateBy(x: -2 * size.value, y: -size.value)
          context.fill(.rectangle(width: 2 * 1.5 * size.value, height: 2 * size.value), with: .color(.white))
        }
      })
        .useGravity()
        .start(\.torque, with: { .random(degreesIn: -8.0 ... 8.0) })
        .onUpdate(perform: { proxy in
          let t = proxy.timeAlive * 4.0
          proxy.rotation3D = .radians(t)
          proxy.axis3D = (1, cos(t), 0)
          proxy.velocity.dx += 0.1 * cos(t + 0.001 * Double(proxy.id.hashValue))
        })
        .dampenVelocity()
      )
    }
    
    public enum Shape {
      case square
      case circle
      case rectangle
    }
    
    public enum Size {
      case small
      case medium
      case large
      case custom(CGFloat)
      
      var value: CGFloat {
        switch self {
        case .small:
          return 4.0
        case .medium:
          return 6.0
        case .large:
          return 8.0
        case .custom(let cgFloat):
          return cgFloat
        }
      }
    }
  }
}
