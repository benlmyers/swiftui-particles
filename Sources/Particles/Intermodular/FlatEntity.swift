//
//  FlatEntity.swift
//
//
//  Created by Ben Myers on 3/23/24.
//

import SwiftUI
import Foundation

internal struct FlatEntity {
  
  internal var preferences: [Preference] = []
  internal var view: AnyView?
  
  init(_ entity: any Entity) {
    var body: any Entity = entity
    while true {
      if let particle = body as? Particle {
        self.view = particle.view
        return
      } else if body is EmptyEntity {
        return
      } else {
        body = body.body
        continue
      }
      return
    }
  }
  
  enum Preference {
    case onPhysicsBirth((PhysicsProxy.Context) -> PhysicsProxy)
    case onPhysicsUpdate((PhysicsProxy.Context) -> PhysicsProxy)
    case onRenderBirth((RenderProxy.Context) -> RenderProxy)
    case onRenderUpdate((RenderProxy.Context) -> RenderProxy)
    case custom(Custom)
    
    enum Custom {
      
    }
  }
  
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    var proxy: PhysicsProxy = context.physics
    for p in preferences {
      if case Preference.onPhysicsBirth(let c) = p {
        let context = PhysicsProxy.Context(physics: proxy, system: context.system)
        proxy = c(context)
      }
    }
    return proxy
  }
  
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    var proxy: PhysicsProxy = context.physics
    for p in preferences {
      if case Preference.onPhysicsUpdate(let c) = p {
        let context = PhysicsProxy.Context(physics: proxy, system: context.system)
        proxy = c(context)
      }
    }
    return proxy
  }
  
  func onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy {
    var proxy: RenderProxy = context.render
    for p in preferences {
      if case Preference.onRenderBirth(let c) = p {
        let context = RenderProxy.Context(physics: context.physics, render: proxy, system: context.system)
        proxy = c(context)
      }
    }
    return proxy
  }
  
  func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy {
    var proxy: RenderProxy = context.render
    for p in preferences {
      if case Preference.onRenderUpdate(let c) = p {
        let context = RenderProxy.Context(physics: context.physics, render: proxy, system: context.system)
        proxy = c(context)
      }
    }
    return proxy
  }
}
