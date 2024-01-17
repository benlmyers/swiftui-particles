//
//  EntityGroup.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

public struct EntityGroup: Entity {
  public var body: EmptyEntity { .init() }
  internal var values: [AnyEntity]
  internal init(values: [AnyEntity]) {
    self.values = values
  }
  public init<E>(@EntityBuilder entities: () -> E) where E: Entity {
    if let e = entities() as? EntityGroup {
      self = e
    } else {
      self.values = [.init(body: entities())]
    }
  }
}
