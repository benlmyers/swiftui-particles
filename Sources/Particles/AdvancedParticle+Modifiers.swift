//
//  AdvancedParticle+Modifiers.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import ParticlesCore

public extension AdvancedParticle {
  
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
  
  /// Rotates the particle in 3D.
  /// - Parameters:
  ///   - x: The angle, in degrees, around the x-axis to rotate.
  ///   - y: The angle, in degrees, around the y-axis to rotate.
  /// - Returns: The modified particle.
  final func rotate3D(x: Double, y: Double) -> Self {
    self.fix(\.rotation3D, at: Rotation3D(theta: .degrees(x), phi: .degrees(y)))
  }
}
