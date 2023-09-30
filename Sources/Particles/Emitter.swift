//
//  Emitter.swift
//
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Foundation

public class Emitter: PhysicalEntity {

  // MARK: - Properties
  
  /// The rate at which the emitter fires, in entities per second.
  @Configured public internal(set) var fireRate: Double = 1.0
  /// The velocity to fire entity.
  @Configured public internal(set) var fireVelocity: CGVector = .zero
  /// A closure used to decide which entity to fire.
  @Configured public internal(set) var decider: (Emitter) -> PhysicalEntity = { e in e.prototypes.randomElement()! }
  /// The maximum amount of entities this emitter may spawn.
  @Configured public internal(set) var maxChildren: Int?
  
  /// The last time the emitter fired a particle.
  var lastFire: Date?
  /// The prototypes this emitter can spawn.
  var prototypes: [PhysicalEntity]

  // MARK: - Initalizers

  public init(rate: Double = 3.0, @Builder<Entity> entities: @escaping () -> [Entity]) {
    self.prototypes = entities().compactMap({ $0 as? PhysicalEntity })
    super.init()
    self.lifetime = .infinity
    self.fireRate = rate
  }

  // MARK: - Overrides

  override func debug(_ context: GraphicsContext) {
    super.debug(context)
  }

  override func update() {
    super.update()
    if let lastFire {
      guard Date().timeIntervalSince(lastFire) >= 1.0 / fireRate else {
        return
      }
    }
    // Spawn a new entity
    guard let system else { return }
    let e: PhysicalEntity = decider(self)
    if let p = e as? Particle {
      system.entities.append(Particle(copying: p, from: self))
    } else if let em = e as? Emitter {
      system.entities.append(Emitter(copying: em, from: self))
    } else {
      system.entities.append(PhysicalEntity(copying: e, from: self))
    }
    children.insert(system.entities.last)
    self.lastFire = Date()
  }

  override func render(_ context: GraphicsContext) {
    super.render(context)
    // Do nothing
  }
  
  override init(copying e: PhysicalEntity, from emitter: Emitter) {
    guard let em = e as? Emitter else {
      fatalError("An entity failed to cast to an emitter.")
    }
    self.prototypes = em.prototypes
    super.init(copying: e, from: emitter)
    self._fireRate = em.$fireRate.copy()
    self._fireVelocity = em.$fireVelocity.copy()
    self._decider = em.$decider.copy()
    self._maxChildren = em.$maxChildren.copy()
  }
  
  // MARK: - Methods
  
  public func with<V>(_ key: KeyPath<Emitter, Configured<V>>, startingAt val: V) -> Self {
    self[keyPath: key].setInitial(to: val)
    return self
  }
  
  public func with<V>(_ key: KeyPath<Emitter, Configured<V>>, fixedAt val: V) -> Self {
    self[keyPath: key].fix(to: val)
    return self
  }
  
  public func with<V>(_ key: KeyPath<Emitter, Configured<V>>, boundTo binding: Binding<V>) -> Self {
    self[keyPath: key].bind(to: binding)
    return self
  }
  
  public func with<V>(_ key: KeyPath<Emitter, Configured<V>>, using closure: @escaping (Entity) -> V) -> Self {
    self[keyPath: key].setBehavior(to: closure)
    return self
  }
}
