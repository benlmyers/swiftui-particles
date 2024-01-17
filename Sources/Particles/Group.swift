//
//  Group.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

/// A group of entities.
/// Applying a modifier to an ``Group`` will affect all its children:
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
  
  // MARK: - Initalizers
  
  public init<E>(@EntityBuilder entities: () -> E) where E: Entity {
    if let e = entities() as? Group {
      self = e
    } else {
      self.values = [.init(body: entities())]
    }
  }
  
  internal init(values: [AnyEntity]) {
    self.values = values
  }
}
