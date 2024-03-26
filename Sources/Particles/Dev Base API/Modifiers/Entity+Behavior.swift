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
  func onAppear(perform closure: @escaping (inout Proxy) -> Void) -> some Entity {
    onAppear { p, _ in closure(&p) }
  }
  
  /// Adds entity behavior upon birth.
  /// - Parameter closure: A closure describing what happens to the entity's physics and rendering proxies. The first two closure parameters can be directly modified to change an entity's properties.
  /// - Returns: The modified entity.
  func onAppear(perform closure: @escaping (inout Proxy, ParticleSystem.Data) -> Void) -> some Entity {
    return ModifiedEntity(entity: self, onBirth: { c in
      var proxy = c.proxy
      closure(&proxy, c.system)
      return proxy
    }, onUpdate: nil)
  }
  
  /// Adds entity behavior upon birth.
  /// - Parameter closure: A closure describing what happens to the entity's physics proxy. The closure parameter can be directly modified to change an entity's properties.
  /// - Returns: The modified entity.
  func onUpdate(perform closure: @escaping (inout Proxy) -> Void) -> some Entity {
    onUpdate { p, _ in closure(&p) }
  }
  
  /// Adds entity behavior upon birth.
  /// - Parameter closure: A closure describing what happens to the entity's physics and rendering proxies. The first two closure parameters can be directly modified to change an entity's properties.
  /// - Returns: The modified entity.
  func onUpdate(perform closure: @escaping (inout Proxy, ParticleSystem.Data) -> Void) -> some Entity {
    return ModifiedEntity(entity: self, onUpdate: { c in
      var proxy = c.proxy
      closure(&proxy, c.system)
      return proxy
    })
  }
}
