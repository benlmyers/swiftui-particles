//
//  Emitter.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

internal protocol _Emitter {
  
  var emitInterval: TimeInterval { get set }
  var emitChooser: ((PhysicsProxy.Context) -> Int)? { get set }
}

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
public struct Emitter<Children>: Entity, _Emitter where Children: Entity {
  
  // MARK: - Properties
  
  public var body: Children
  
  internal var emitInterval: TimeInterval
  internal var emitChooser: ((PhysicsProxy.Context) -> Int)?
  
  // MARK: - Initalizers
  
  /// Creates an emitter that emits passed entities on an interval.
  /// If a group of entities is passed in `emits`, you can use ``emitAll()`` or ``emitSingle(choosing:)`` to change the entities spawned in the interval.
  /// - Parameter interval: The interval to emit entities.
  /// - Parameter emits: A closure returning the entity/entities to spawn on the interval.
  public init(every interval: TimeInterval = 1.0, @EntityBuilder emits: () -> Children) {
    self.emitInterval = interval
    self.body = emits()
  }
  
  // MARK: - Methods
  
  /// Modifies the ``Emitter`` to emit only one entity at a time.
  /// - Parameter choice: A closure that decides the index of the entity to spawn when the ``Emitter`` can spawn a new entity. By default, it will increment based on the number of proxies spawned in the ``ParticleSystem`` simulation.
  /// - Returns: The modified emitter
  public func emitSingle(choosing choice: @escaping (PhysicsProxy.Context) -> Int = { c in Int(c.system?.proxiesSpawned ?? 0)}) -> Emitter {
    var copy = self
    copy.emitChooser = choice
    return copy
  }
  
  /// Modifies the ``Emitter`` to emit all the passed entities at once.
  public func emitAll() -> Emitter {
    var copy = self
    copy.emitChooser = nil
    return copy
  }
  
  /// Modifies the ``Emitter`` to spawn a specified number of entities.
  /// Under the hood, this modifier is equivalent to `.lifetime(count * emitInterval)`.
  /// - Parameter count: The number of entities particles that can be spawned before the emitter is to be destroyed.
  /// - Returns: The modified entity.
  public func maxSpawn(count: Int) -> some Entity {
    self.lifetime(Double(count) * emitInterval)
  }
}
