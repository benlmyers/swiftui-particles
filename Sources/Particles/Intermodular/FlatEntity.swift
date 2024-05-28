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
  
  init?(single e: Any, centered: Bool = true) {
    guard var body: any Entity = e as? any Entity else { return nil }
    guard !(e is EmptyEntity) else { return nil }
    self.preferences = []
    if centered {
      self.preferences = [.onBirth({ c in
        var p = c.proxy
        let s = c.system.size
        p.position = .init(x: 0.5 * s.width, y: 0.5 * s.height)
        return p
      })]
    }
    while true {
      if let group = body as? Group {
        self.root = group
        break
      } else if let m = body as? any _ModifiedEntity {
        self.preferences.append(contentsOf: m.preferences)
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
  
  static func make(_ entity: Any, merges: Group.Merges? = nil, centered: Bool = true) -> [(result: FlatEntity, merges: Group.Merges?)] {
    if let grouped = entity as? any Transparent {
      return FlatEntity.make(grouped.body)
    }
    guard let single = FlatEntity.init(single: entity, centered: centered) else {
      return []
    }
    if let group = single.root as? Group {
      let flats: [(FlatEntity, Group.Merges?)] = group.values.flatMap({ (e: AnyEntity) in
        var children: [(FlatEntity, Group.Merges?)] = FlatEntity.make(e.body, merges: group.merges)
        for i in 0 ..< children.count {
          children[i].0.preferences.insert(contentsOf: single.preferences, at: 0)
        }
        return children
      })
      return flats
    } else {
      return [(single, merges)]
    }
  }
  
  enum Preference {
    case onBirth((Proxy.Context) -> Proxy)
    case onUpdate((Proxy.Context) -> Proxy)
    case custom((Proxy.Context) -> Custom)
    
    enum Custom {
      case glow(color: Color?, radius: CGFloat)
      case colorOverlay(color: Color)
      case transition(transition: AnyTransition, bounds: TransitionBounds, duration: TimeInterval)
      case delay(duration: TimeInterval)
      case emitChance(_ chance: Double)
    }
  }
  
  func onBirth(_ context: Proxy.Context) -> Proxy {
    var proxy: Proxy = context.proxy
    for p in preferences {
      if case .onBirth(let c) = p {
        let context = Proxy.Context(proxy: proxy, system: context.system)
        proxy = c(context)
      }
    }
    return proxy
  }
  
  func onUpdate(_ context: Proxy.Context) -> Proxy {
    var proxy: Proxy = context.proxy
    for p in preferences {
      if case .onUpdate(let c) = p {
        let context = Proxy.Context(proxy: proxy, system: context.system)
        proxy = c(context)
      }
    }
    return proxy
  }
}
