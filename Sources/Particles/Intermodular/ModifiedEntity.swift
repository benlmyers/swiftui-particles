//
//  ModifiedEntity.swift
//  
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

internal protocol _ModifiedEntity {
  var preferences: [FlatEntity.Preference] { get set }
}

internal struct ModifiedEntity<E>: Entity, _ModifiedEntity where E: Entity {
  
  var body: E
  
  internal var preferences: [FlatEntity.Preference] = []
  
  init(
    entity: E,
    onBirth: ((Proxy.Context) -> Proxy)? = nil,
    onUpdate: ((Proxy.Context) -> Proxy)? = nil
  ) {
    self.body = entity
    if let onBirth {
      preferences.insert(.onBirth(onBirth), at: 0)
    }
    if let onUpdate {
      preferences.insert(.onUpdate(onUpdate), at: 0)
    }
  }
}
