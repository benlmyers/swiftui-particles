//
//  Confetti+Particle.swift
//  
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import ParticlesCore

public extension Confetti {
  
  class Particle: ParticlesCore.Particle {
    
    public var shape: Shape
    
    public init(shape: Shape) {
      self.shape = shape
      super.init { context in
        switch shape {
        case .square:
          context.fill(.init, with: <#T##GraphicsContext.Shading#>)
        case .circle:
          <#code#>
        case .rectangle:
          <#code#>
        }
      }
    }
    
    public enum Shape {
      case square
      case circle
      case rectangle
    }
  }
}
