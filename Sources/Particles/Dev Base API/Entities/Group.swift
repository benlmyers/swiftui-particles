//
//  Group.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

/// A group of entities.
/// Applying a modifier to a ``Group`` will affect all its children:
/// ```
/// // Both particles are twice as large
/// Group {
///   Particle { Text("☁️") }
///   Particle { Text("☀️") }
/// }
/// .scale(2.0)
/// ```
public struct Group: Entity {
  
  // MARK: - Properties
  
  public var body: EmptyEntity { .init() }
  
  internal var values: [AnyEntity]
  
  internal private(set) var merges: Merges?
  
  // MARK: - Initalizers
  
  public init<E>(@EntityBuilder entities: () -> E) where E: Entity {
    if let e = entities() as? Group {
      self = e
    } else {
      self.values = [.init(body: entities())]
    }
  }
  
  internal init(values: [AnyEntity], merges: Merges? = nil) {
    self.values = values
    self.merges = merges
  }
  
  // MARK: - Subtypes
  
  /// Controls what types of data are merged when a group is instantiated.
  /// When data is *merged*, the first of that data element is copied on the proxy level.
  ///
  /// For instance, consider this ``ForEach`` example:
  /// ```
  /// ParticleSystem {
  ///   ForEach([5, 10, 15], merges: nil) { x in
  ///     Particle {
  ///       Circle()
  ///         .foregroundColor(x % 2 == 0 ? .red : .yellow)   // A
  ///         .frame(width: x, height: x)                     // B
  ///       }
  ///     }
  ///     .initialPosition(.center)
  ///     .initialOffset(xIn: -50.0 ... 50.0)
  ///     .initialVelocity(y: 0.1 * x)                        // C
  ///   }
  /// }
  /// ```
  /// Here, three circle particles are created. We can see that `A` alternates the color, `B` sets a size, and `C` endows a different y-speed for each circle.
  /// Since `merges: nil` is passed, we expect default behavior. Indeed, we see 3 particles of varying sizes and speeds with alternating colors.
  ///
  /// However, this comes at a cost: If ``ParticleSystem/debug()`` is enabled, you can see that 3 views and 3 entities are registered.
  ///
  /// Use `merges: .views` to only register the **first view** encountered.
  /// Likewise, use `merges: .entities` to only register the **first entity** behavior encountered. Then, the system will iterate over the data array and create different initial ``PhysicsProxy`` and ``RenderProxy`` "clones".
  /// Note that ``entities`` automatically also merges ``views``.
  ///
  /// Use of ``Merges`` is recommended, as it always speeds up rendering time.
  public enum Merges {
    case views
    case entities
  }
}
