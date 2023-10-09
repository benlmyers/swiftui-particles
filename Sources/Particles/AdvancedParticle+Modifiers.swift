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
  
  /// Applies a brightness effect to the particle.
  /// - Parameter amount: The amount of brightness to apply.
  /// - Returns: The modified particle.
  final func brightness(_ amount: Double) -> Self {
    self.onUpdate { proxy in
      proxy.filters.append(.brightness(amount))
    }
  }
  
  /// Applies a glow effect to the particle.
  /// - Parameters:
  ///   - color: The color of the glow effect.
  ///   - radius: The radius of the glow effect. Default value is 5.0.
  /// - Returns: The modified particle.
  final func glow(_ color: Color, radius: CGFloat = 5.0) -> Self {
    self.onUpdate { proxy in
      proxy.filters.append(.shadow(color: color, radius: radius))
    }
  }
  
  /// Applies a 3D rotation to the particle.
  /// - Parameters:
  ///   - angle: The angle of rotation.
  ///   - axis: The axis of rotation in 3D space.
  /// - Returns: The modified particle.
  final func rotation3D(angle: Angle, about axis: Vector3D) -> Self {
    self
      .fix(\.rotation3D, at: angle)
      .fix(\.axis3D, at: axis)
  }
  
  /// Sets the trail color and width for the particle.
  /// - Parameters:
  ///   - color: The color of the trail.
  ///   - width: The width of the trail line. Default value is 2.0.
  /// - Returns: The modified particle.
  final func trail(color: Color, lineWidth width: CGFloat = 2.0) -> Self {
    self
      .fix(\.trail, at: (.color(color), .init(lineWidth: width)))
  }
}
