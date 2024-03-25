//
//  FlatEntity.swift
//
//
//  Created by Ben Myers on 3/23/24.
//

import SwiftUI
import Foundation

internal struct FlatEntity {
  
  internal var preferences: [Preference]
  internal var root: (any Entity)?
  
  init?(single e: Any) {
    guard var body: any Entity = e as? any Entity else { return nil }
    guard !(e is EmptyEntity) else { return nil }
    self.preferences = []
    while true {
      if let group = body as? Group {
        self.root = group
        break
      } else if let m = body as? any _ModifiedEntity {
        self.preferences.insert(contentsOf: m.preferences, at: 0)
        body = body.body
        continue
      } else if body is Particle || body is _Emitter {
        self.root = body
        break
      } else {
        body = body.body
        continue
      }
    }
  }
  
  static func make(_ entity: Any) -> (result: [FlatEntity], merges: Group.Merges?) {
    if let grouped = entity as? any Transparent {
      return FlatEntity.make(grouped.body)
    }
    guard let single = FlatEntity.init(single: entity) else {
      return ([], nil)
    }
    if let group = single.root as? Group {
      let flats: [FlatEntity] = group.values.flatMap({ (e: AnyEntity) in
        var children: [FlatEntity] = FlatEntity.make(e.body).result
        for i in 0 ..< children.count {
          children[i].preferences.insert(contentsOf: single.preferences, at: 0)
        }
        return children
      })
      return (flats, group.merges)
    } else {
      return ([single], nil)
    }
  }
  
  enum Preference {
    case onPhysicsBirth((PhysicsProxy.Context) -> PhysicsProxy)
    case onPhysicsUpdate((PhysicsProxy.Context) -> PhysicsProxy)
    case onRenderBirth((RenderProxy.Context) -> RenderProxy)
    case onRenderUpdate((RenderProxy.Context) -> RenderProxy)
    case custom(Custom)
    
    enum Custom {
      case glow(color: Color, radius: CGFloat)
      case colorOverlay(color: Color)
      case transition(transition: AnyTransition, bounds: TransitionBounds, duration: TimeInterval)
    }
  }
  
  func onPhysicsBirth(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    var proxy: PhysicsProxy = context.physics
    for p in preferences {
      if case .onPhysicsBirth(let c) = p {
        let context = PhysicsProxy.Context(physics: proxy, system: context.system)
        proxy = c(context)
      }
    }
    return proxy
  }
  
  func onPhysicsUpdate(_ context: PhysicsProxy.Context) -> PhysicsProxy {
    var proxy: PhysicsProxy = context.physics
    for p in preferences {
      if case .onPhysicsUpdate(let c) = p {
        let context = PhysicsProxy.Context(physics: proxy, system: context.system)
        proxy = c(context)
      }
    }
    return proxy
  }
  
  func onRenderBirth(_ context: RenderProxy.Context) -> RenderProxy {
    var proxy: RenderProxy = context.render
    for p in preferences {
      if case .onRenderBirth(let c) = p {
        let context = RenderProxy.Context(physics: context.physics, render: proxy, system: context.system)
        proxy = c(context)
      }
    }
    return proxy
  }
  
  func onRenderUpdate(_ context: RenderProxy.Context) -> RenderProxy {
    var proxy: RenderProxy = context.render
    for p in preferences {
      if case .onRenderUpdate(let c) = p {
        let context = RenderProxy.Context(physics: context.physics, render: proxy, system: context.system)
        proxy = c(context)
      }
    }
    return proxy
  }
}
