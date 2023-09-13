//
//  Emitter.swift
//
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Foundation

public class Emitter: Entity {

  // MARK: - Properties
  
  /// The rate at which the emitter fires, in entities per second.
  @Configured public internal(set) var fireRate: Double = 1.0
  /// The velocity to fire entity.
  @Configured public internal(set) var fireVelocity: CGVector = .zero
  /// A closure used to decide which entity to fire.
  @Configured public internal(set) var decider: (Emitter) -> Entity = { e in e.prototypes.randomElement()! }
  /// The maximum amount of entities this emitter may spawn.
  @Configured public internal(set) var maxChildren: Int?
  
  /// The last time the emitter fired a particle.
  var lastFire: Date?
  /// The prototypes this emitter can spawn.
  var prototypes: [Entity]

  // MARK: - Initalizers

  public init(rate: Double = 3.0, @Builder<Entity> entities: @escaping () -> [Entity]) {
    self.prototypes = entities()
    super.init()
    self.lifetime = .infinity
    self.fireRate = rate
  }

  // MARK: - Overrides

  override func debug(_ context: GraphicsContext) {
    super.debug(context)
    // TODO: Debug
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
    let e: Entity = decider(self)
    if let p = e as? Particle {
      system.entities.append(Particle(copying: p))
    } else if let em = e as? Emitter {
      system.entities.append(Emitter(copying: em))
    } else {
      system.entities.append(Entity(copying: e))
    }
    children.insert(system.entities.last)
    self.lastFire = Date()
  }

  override func render(_ context: GraphicsContext) {
    super.render(context)
    // Do nothing
  }
  
  override init(copying e: Entity) {
    guard let em = e as? Emitter else {
      fatalError("An entity failed to cast to an emitter.")
    }
    self.prototypes = em.prototypes
    super.init(copying: e)
    self._fireRate = em.$fireRate.copy()
    self._fireVelocity = em.$fireVelocity.copy()
    self._decider = em.$decider.copy()
    self._maxChildren = em.$maxChildren.copy()
  }
}
