//
//  Particle.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI

/// A basic ``Entity`` that renders a provided `View`.
/// To create a particle inside of a ``ParticleSystem``, use Particles' declarative syntax:
/// ```
/// ParticleSystem {
///   Particle {
///     Text("Any view can be a particle")
///   }
///   .initialPosition(x: 100.0, y: 100.0)
/// }
/// ```
public struct Particle: Entity {
  
  // MARK: - Properties
  
  public var body = EmptyEntity()
  
  internal var view: AnyView
  
  // MARK: - Initalizers
  
  /// Create a particle with the appearance of a passed view.
  /// - Parameter view: The view to create the particle with.
  public init<V>(@ViewBuilder view: () -> V) where V: View {
    self.view = .init(view())
  }
  
  internal init(anyView: AnyView) {
    self.view = anyView
  }
}
