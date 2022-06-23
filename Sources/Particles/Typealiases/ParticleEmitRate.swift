//
//  ParticleEmitRate.swift
//  
//
//  Created by Ben Myers on 6/19/22.
//

import Foundation

public typealias ParticleEmitRate = TimeInterval

public extension ParticleEmitRate {
  
  /// All particles will burst at once.
  static let burst: Self = .zero
  /// Particles will emit very fast.
  static let veryFast: Self = 0.01
  /// Particles will emit fast.
  static let fast: Self = 0.05
  /// Particles will emit at a moderate pace.
  static let medium: Self = 0.1
  /// Particles will emit slowly.
  static let slow: Self = 0.2
  /// Particles will emit very slowly.
  static let verySlow: Self = 0.4
}
