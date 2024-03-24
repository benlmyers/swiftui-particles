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
    onBirthPhysics: ((PhysicsProxy.Context) -> PhysicsProxy)? = nil,
    onUpdatePhysics: ((PhysicsProxy.Context) -> PhysicsProxy)? = nil,
    onBirthRender: ((RenderProxy.Context) -> RenderProxy)? = nil,
    onUpdateRender: ((RenderProxy.Context) -> RenderProxy)? = nil
  ) {
    self.body = entity
    if let onBirthPhysics {
      preferences.insert(.onPhysicsBirth(onBirthPhysics), at: 0)
    }
    if let onUpdatePhysics {
      preferences.insert(.onPhysicsUpdate(onUpdatePhysics), at: 0)
    }
    if let onBirthRender {
      preferences.insert(.onRenderBirth(onBirthRender), at: 0)
    }
    if let onUpdateRender {
      preferences.insert(.onRenderUpdate(onUpdateRender), at: 0)
    }
  }
}
