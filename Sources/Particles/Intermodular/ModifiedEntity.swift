//
//  ModifiedEntity.swift
//  
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

internal struct ModifiedEntity<E>: Entity where E: Entity {
  private var birthPhysics: ((PhysicsProxy.Context) -> PhysicsProxy)?
  private var updatePhysics: ((PhysicsProxy.Context) -> PhysicsProxy)?
  private var birthRender: ((RenderProxy.Context) -> RenderProxy)?
  private var updateRender: ((RenderProxy.Context) -> RenderProxy)?
  var body: E
  init(
    entity: E,
    onBirthPhysics: ((PhysicsProxy.Context) -> PhysicsProxy)? = nil,
    onUpdatePhysics: ((PhysicsProxy.Context) -> PhysicsProxy)? = nil,
    onBirthRender: ((RenderProxy.Context) -> RenderProxy)? = nil,
    onUpdateRender: ((RenderProxy.Context) -> RenderProxy)? = nil
  ) {
    self.body = entity
    self.birthPhysics = onBirthPhysics
    self.updatePhysics = onUpdatePhysics
    self.birthRender = onBirthRender
    self.updateRender = onUpdateRender
  }
  func _onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    guard let data = context.system else { return body._onPhysicsBirth(context) }
    guard let birthPhysics else { return body._onPhysicsBirth(context) }
    let newContext: PhysicsProxy.Context = .init(physics: birthPhysics(context), system: data)
    return body._onPhysicsBirth(newContext)
  }
  func _onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    guard let data = context.system else { return body._onPhysicsUpdate(context) }
    guard let updatePhysics else { return body._onPhysicsUpdate(context) }
    let newContext: PhysicsProxy.Context = .init(physics: updatePhysics(context), system: data)
    return body._onPhysicsUpdate(newContext)
  }
  func _onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy {
    guard let data = context.system else { return body._onRenderBirth(context) }
    guard let birthRender else { return body._onRenderBirth(context) }
    let newContext: RenderProxy.Context = .init(physics: context.physics, render: birthRender(context), system: data)
    return body._onRenderBirth(newContext)
  }
  func _onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy {
    guard let data = context.system else { return body._onRenderUpdate(context) }
    guard let updateRender else { return body._onRenderUpdate(context) }
    let newContext: RenderProxy.Context = .init(physics: context.physics, render: updateRender(context), system: data)
    return body._onRenderUpdate(newContext)
  }
}
