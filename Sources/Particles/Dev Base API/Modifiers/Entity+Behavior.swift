//
//  Entity+Behavior.swift
//
//
//  Created by Ben Myers on 1/22/24.
//

import Foundation

public extension Entity {
  
  /// Adds entity behavior upon birth.
  /// - Parameter closure: A closure describing what happens to the entity's physics proxy. The closure parameter can be directly modified to change an entity's properties.
  /// - Returns: The modified entity.
  func onAppear(perform closure: @escaping (inout PhysicsProxy) -> Void) -> some Entity {
    onAppear { p, _, _ in closure(&p) }
  }
  
  /// Adds entity behavior upon birth.
  /// - Parameter closure: A closure describing what happens to the entity's physics and rendering proxies. The closure parameters can be directly modified to change an entity's properties.
  /// - Returns: The modified entity.
  func onAppear(perform closure: @escaping (inout PhysicsProxy, inout RenderProxy) -> Void) -> some Entity {
    onAppear { p, r, _ in closure(&p, &r) }
  }
  
  /// Adds entity behavior upon birth.
  /// - Parameter closure: A closure describing what happens to the entity's physics and rendering proxies. The first two closure parameters can be directly modified to change an entity's properties.
  /// - Returns: The modified entity.
  func onAppear(perform closure: @escaping (inout PhysicsProxy, inout RenderProxy, ParticleSystem.Data) -> Void) -> some Entity {
    let newPhysicsClosure: (PhysicsProxy.Context) -> PhysicsProxy = { context in
      var newContext = context
      var p = RenderProxy()
      closure(&newContext.physics, &p, context.system)
      return newContext.physics
    }
    let newRenderClosure: (RenderProxy.Context) -> RenderProxy = { context in
      var newContext = context
      closure(&newContext.physics, &newContext.render, context.system)
      return newContext.render
    }
    return ModifiedEntity(entity: self, onBirthPhysics: newPhysicsClosure, onBirthRender: newRenderClosure)
  }
  
  /// Adds entity behavior upon birth.
  /// - Parameter closure: A closure describing what happens to the entity's physics proxy. The closure parameter can be directly modified to change an entity's properties.
  /// - Returns: The modified entity.
  func onUpdate(perform closure: @escaping (inout PhysicsProxy) -> Void) -> some Entity {
    onUpdate { p, _, _ in closure(&p) }
  }
  
  /// Adds entity behavior upon birth.
  /// - Parameter closure: A closure describing what happens to the entity's physics and rendering proxies. The closure parameters can be directly modified to change an entity's properties.
  /// - Returns: The modified entity.
  func onUpdate(perform closure: @escaping (inout PhysicsProxy, inout RenderProxy) -> Void) -> some Entity {
    onUpdate { p, r, _ in closure(&p, &r) }
  }
  
  /// Adds entity behavior upon birth.
  /// - Parameter closure: A closure describing what happens to the entity's physics and rendering proxies. The first two closure parameters can be directly modified to change an entity's properties.
  /// - Returns: The modified entity.
  func onUpdate(perform closure: @escaping (inout PhysicsProxy, inout RenderProxy, ParticleSystem.Data) -> Void) -> some Entity {
    let newPhysicsClosure: (PhysicsProxy.Context) -> PhysicsProxy = { context in
      var newContext = context
      var p = RenderProxy()
      closure(&newContext.physics, &p, context.system)
      return newContext.physics
    }
    let newRenderClosure: (RenderProxy.Context) -> RenderProxy = { context in
      var newContext = context
      closure(&newContext.physics, &newContext.render, context.system)
      return newContext.render
    }
    return ModifiedEntity(entity: self, onUpdatePhysics: newPhysicsClosure, onUpdateRender: newRenderClosure)
  }
}
