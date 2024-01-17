//
//  Emitter.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

/// An ``Entity`` that emits other entities.
/// To create an emitter, pass an optional spawn interval and the entities to spawn using `@EntityBuilder`:
/// ```
/// ParticleSystem {
///   // Emits ✨ and 🌟 every 1.5 seconds
///   Emitter(interval: 1.5) {
///     Particle { Text("✨") }
///     Particle { Text("🌟") }
///   }
/// }
/// ```
public struct Emitter: Entity {
  
  // MARK: - Properties
  
  public var body: EmptyEntity { .init() }
  
  internal private(set) var prototype: AnyEntity
  internal private(set) var emitInterval: TimeInterval
  
  // MARK: - Initalizers
  
  public init<E>(interval: TimeInterval = 1.0, @EntityBuilder emits: () -> E) where E: Entity {
    self.emitInterval = interval
    self.prototype = .init(body: emits())
  }
}
