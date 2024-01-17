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
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    guard let data = context.system else { return body.onPhysicsBirth(context) }
    guard let birthPhysics else { return body.onPhysicsBirth(context) }
    let newContext: PhysicsProxy.Context = .init(physics: birthPhysics(context), data: data)
    return body.onPhysicsBirth(newContext)
  }
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    guard let data = context.system else { return body.onPhysicsUpdate(context) }
    guard let updatePhysics else { return body.onPhysicsUpdate(context) }
    let newContext: PhysicsProxy.Context = .init(physics: updatePhysics(context), data: data)
    return body.onPhysicsUpdate(newContext)
  }
  func onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy {
    guard let data = context.system else { return body.onRenderBirth(context) }
    guard let birthRender else { return body.onRenderBirth(context) }
    let newContext: RenderProxy.Context = .init(physics: context.physics, render: birthRender(context), data: data)
    return body.onRenderBirth(newContext)
  }
  func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy {
    guard let data = context.system else { return body.onRenderUpdate(context) }
    guard let updateRender else { return body.onRenderUpdate(context) }
    let newContext: RenderProxy.Context = .init(physics: context.physics, render: updateRender(context), data: data)
    return body.onRenderUpdate(newContext)
  }
}
