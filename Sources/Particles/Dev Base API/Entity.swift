//
//  Entity.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

// MARK: - Protocol Definition

/// A protocol used to define the behavior of objects within a ``ParticleSystem``.
/// Like views in SwiftUI, new entity types can be defined using ``Entity/body`` conformance:
/// ```
/// struct MyCustomParticle: Entity {
///   var body: some Entity {
///     Particle { Text("☀️") }
///       .hueRotation(.degrees(45.0))
///       .scale({ _ in .random(in: 1.0 ... 3.0) })
///   }
/// }
/// ```
public protocol Entity {
  
  associatedtype Body: Entity
  
  /// The inner content of the entity.
  /// Inner content often holds additional modifiers to apply to ``PhysicsProxy`` or ``RenderProxy`` instances upon spawn.
  var body: Self.Body { get }
}
