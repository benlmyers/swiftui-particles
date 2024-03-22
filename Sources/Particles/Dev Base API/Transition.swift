//
//  Transition.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import SwiftUI
import Foundation

/// A particle render transition.
/// A few presets are provided. See ``AnyTransition``.
public protocol Transition {
  
  /// A required method for ``Transition``s that modifies a `GraphicsContext` during the transition's designated timeframe.
  /// For implementation examples, see ``OpacityTransition`` or ``ScaleTransition``.
  /// - Parameter progress: Upon birth, progress goes `1.0 -> 0.0`. Upon death, progress goes `0.0 -> 1.0`.
  /// - Parameter physics: Physics context provided for use in the transition.
  /// - Parameter context: The `GraphicsContext` that is to be modified.
  func modifyRender(progress: Double, physics: PhysicsProxy.Context, context: inout GraphicsContext)
}

/// Bounds for a transition.
public enum TransitionBounds {
  /// Perform the transition after the particle is spawned.
  case birth
  /// Perform the transition before the particle is to be removed.
  case death
  /// Perform at both ``birth`` and ``death``.
  case birthAndDeath
}
