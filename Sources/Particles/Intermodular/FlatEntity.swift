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
  internal var root: (any Entity)?
  
  init?(single e: Any) {
    guard var body: any Entity = e as? any Entity else { return nil }
    guard !(e is EmptyEntity) else { return }
    while true {
      if let group = body as? Group {
        self.root = group
      } else if let m = body as? any _ModifiedEntity {
        self.preferences.append(contentsOf: m.preferences)
        body = body.body
        continue
      } else if body is Particle || body is _Emitter {
        self.root = body
        return
      } else {
        body = body.body
        continue
      }
    }
  }
  
  static func make(_ entity: Any) -> [FlatEntity] {
    if let group = entity as? Group {
      return group.values.flatMap { entity in
        FlatEntity.make(entity.body)
      }
    }
    if let single = FlatEntity.init(single: entity) {
      return [single]
    }
    return []
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
