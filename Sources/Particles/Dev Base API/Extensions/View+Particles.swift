//
//  View+Particles.swift
//
//
//  Created by Ben Myers on 3/22/24.
//

import SwiftUI

public extension View {
  
  /// Applies a particle system to this view with its center at the center of the view.
  /// - Parameter atop: Whether particles are laid atop the view. Pass `false` to lay particles under the view.
  /// - Parameter entities: The entities to spawn in the particle system.
  func particleSystem<E>(
    atop: Bool = true,
    offset: CGPoint = .zero,
    @EntityBuilder entities: () -> E
  ) -> some View where E: Entity {
    self.boundlessOverlay(
      atop: atop,
      offset: offset)
    {
      ParticleSystem(entity: entities)
    }
  }
  
  /// Applies a particle emitter to this view.
  /// - Parameter interval: How often to emit the passed entities.
  /// - Parameter condition: Used to conditionally emit entities.
  /// - Parameter atop: Whether particles are laid atop the view. Pass `false` to lay particles under the view.
  /// - Parameter simultaneously: Whether to spawn passed entities simultaneously. If not, they are spawned sequentially in a cycle.
  /// - Parameter entities: The entities to spawn.
  func emits<E>(every interval: TimeInterval = 1.0, if condition: Bool = true, atop: Bool = true, simultaneously: Bool = false, @EntityBuilder entities: () -> E) -> some View where E: Entity {
    if simultaneously {
      return self.boundlessOverlay(atop: atop) {
        ParticleSystem {
          if condition {
            Emitter(every: interval, emits: entities)
              .emitAll()
              .initialPosition(.center)
          }
        }
      }
    } else {
      return self.boundlessOverlay(atop: atop) {
        ParticleSystem {
          Emitter(every: interval, emits: entities)
            .emitSingle()
            .initialPosition(.center)
        }
      }
    }
  }
}
