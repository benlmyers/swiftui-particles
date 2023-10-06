//
//  AdvancedParticle+Modifiers.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import ParticlesCore

public extension AdvancedParticle {
  
  typealias Vector3D = (Double, Double, Double)
  
  /// Applies a blur effect to the particle.
  /// - Parameter radius: The radius of the blur effect. Default value is 5.0.
  /// - Returns: The modified particle.
  final func blurEffect(radius: CGFloat = 5.0) -> Self {
    self.fix(\.blur, at: radius)
  }
  
  /// Sets the blend mode of the particle.
  /// - Parameter mode: The blend mode to set.
  /// - Returns: The modified particle.
  final func blendMode(_ mode: GraphicsContext.BlendMode) -> Self {
    self.fix(\.blendMode, at: mode)
  }
  
  /// <#Description#>
  /// - Parameter amount: <#amount description#>
  /// - Returns: <#description#>
  final func brightness(_ amount: Double) -> Self {
    self.onUpdate { proxy in
      proxy.filters.append(.brightness(amount))
    }
  }
  
  /// <#Description#>
  /// - Parameters:
  ///   - color: <#color description#>
  ///   - radius: <#radius description#>
  /// - Returns: <#description#>
  final func glow(_ color: Color, radius: CGFloat = 5.0) -> Self {
    self.onUpdate { proxy in
      proxy.filters.append(.shadow(color: color, radius: radius))
    }
  }
  
  /// <#Description#>
  /// - Parameters:
  ///   - angle: <#angle description#>
  ///   - axis: <#axis description#>
  /// - Returns: <#description#>
  final func rotation3D(angle: Angle, about axis: Vector3D) -> Self {
    self
      .fix(\.rotation, at: angle)
      .fix(\.axis3D, at: axis)
  }
}
