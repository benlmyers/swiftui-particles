//
//  Particle+Modifiers.swift
//
//
//  Created by Ben Myers on 10/3/23.
//

import SwiftUI
import ParticlesCore

public extension Particle {
  
  /// Sets the opacity of the particle.
  /// - Parameter value: The opacity value to set.
  /// - Returns: The modified particle.
  final func opacity(_ value: Double) -> Self {
    self.fix(\.opacity, at: value)
  }
  
  /// Applies a scale effect to the particle.
  /// - Parameter value: The scale value to apply.
  /// - Returns: The modified particle.
  final func scaleEffect(_ value: CGFloat) -> Self {
    self.fix(\.scaleEffect, at: value)
  }
}
