//
//  Emitter.swift
//
//
//  Created by Ben Myers on 10/2/23.
//

import SwiftUI
import Foundation

/// An emitter declaration.
///
/// Emitters spawn other entities on a regular time interval. To spawn an entity using an `Emitter`, place it within the emitter's declaration:
///
/// ```swift
/// ParticleSystem {
///   Emitter(
/// }
/// ```
public class Emitter: Entity {
  
  // MARK: - Properties
  
  private final var prototypes: [Entity]
  
  // MARK: - Initalizers
  
  /// Creates an entity emitter.
  /// - Parameter entities: The entities to emit. Each fire, one of the entities declared is selected using ``Emitter/Proxy/decider``, a closure determining the index of
  /// the entity to spawn.
  public init(@Builder<Entity> entities: @escaping () -> [Entity]) {
    self.prototypes = entities()
  }
  
  // MARK: - Overrides
  
  final override func makeProxy(source: Emitter.Proxy?, data: ParticleSystem.Data) -> Proxy {
    return Proxy(prototypes: prototypes, systemData: data, entityData: self)
  }
  
  // MARK: - Subtypes
  
  public class Proxy: Entity.Proxy {
    
    // MARK: - Properties
    
    private final var prototypes: [Entity]
    
    /// The date this emitter last fired a new entity.
    public private(set) var lastEmitted: Date?
    /// The number of entities this emitter has fired.
    public private(set) var emittedCount: Int = 0
    
    /// The rate, in entities per second, upon which to fire new entities.
    public var fireRate: Double = 1.0
    
    /// A decider closure that chooses a declared ``Entity`` to spawn via index.
    ///
    /// By default, emitters choose a random declared entity to spawn.
    /// If `decider` returns an integer value greater than the number of declared entities, its index will wrap to the first entity's.
    /// One may, for instance, create an emitter that fires each entity in a sequential loop:
    ///
    /// ```swift
    /// ParticleSystem {
    ///   // This emitter spawns red, yellow, blue, red, yellow, blue, and so on.
    ///   Emitter {
    ///     Particle(color: .red)
    ///     Particle(color: .yellow)
    ///     Particle(color: .blue)
    ///   }
    ///   .onBirth { proxy, _ in
    ///     (proxy as? Emitter.Proxy)?.decider = { proxy in
    ///       // This decider returns the number of entities the emitter itself has spawned.
    ///       // For instance, if 2 have spawned, then the emitter will choose to emit a new blue particle, since
    ///       // the blue particle was declared third and thus has an index of 2 (from zero).
    ///       return proxy.emittedCount
    ///     }
    ///   }
    /// }
    /// ```
    public var decider: (Proxy) -> Int = { _ in Int.random(in: 0 ... .max) }
    
    // MARK: - Initalizers
    
    init(prototypes: [Entity], systemData: ParticleSystem.Data, entityData: Entity) {
      self.prototypes = prototypes
      super.init(systemData: systemData, entityData: entityData)
    }
    
    // MARK: - Overrides
    
    override func onUpdate(_ context: inout GraphicsContext) {
      super.onUpdate(&context)
      context.stroke(.init(ellipseIn: .init(x: position.x, y: position.y, width: 2.0, height: 2.0)), with: .color(.white))
      if let lastEmitted {
        guard Date().timeIntervalSince(lastEmitted) >= 1.0 / fireRate else {
          return
        }
      }
      guard !prototypes.isEmpty else {
        // TODO: Warn
        return
      }
      guard let systemData else {
        // TODO: Warn
        return
      }
      let prototype: Entity = prototypes[decider(self) % prototypes.count]
      let newProxy = prototype.makeProxy(source: self, data: systemData)
      systemData.proxies.append(newProxy)
      lastEmitted = Date()
      emittedCount += 1
      newProxy.onBirth(self)
    }
  }
}
