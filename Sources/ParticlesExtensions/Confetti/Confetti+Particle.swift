//
//  Confetti+Particle.swift
//  
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import ParticlesCore

public extension Confetti {
  
  class Particle: ParticlesCore.AdvancedParticle {
    
    public init(color: Color, shape: Shape, size: Size) {
      super.init { context in
        switch shape {
        case .square:
          context.fill(.square(radius: size.value), with: .color(color))
        case .circle:
          context.fill(.circle(radius: size.value), with: .color(color))
        case .rectangle:
          context.fill(.rectangle(width: 1.5 * size.value, height: 0.75 * size.value), with: .color(color))
        }
      }
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
          return 8.0
        case .medium:
          return 12.0
        case .large:
          return 16.0
        case .custom(let cgFloat):
          return cgFloat
        }
      }
    }
    
//    public class Proxy: AdvancedParticle.Proxy {
//
//    }
  }
}
