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
  
  /// Applies a delay to this entity. This causes it to wait for a specified amount of time until birth.
  /// - Parameter duration: The duration, in seconds, of the delay.
  /// - Returns: The modified entity.
  func delay(_ duration: TimeInterval) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .delay(duration: duration) }))
    return m
  }
  
  /// Applies a delay to this entity randomly. This causes it to wait for a specified amount of time until birth.
  /// - Parameter range: The range of durations, in seconds, of the possible delay value.
  /// - Returns: The modified entity.
  func delay(in range: ClosedRange<TimeInterval>) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .delay(duration: .random(in: range)) }))
    return m
  }
  
  /// Applies a delay to this entity using the provided closure before birth. This causes it to wait for a specified amount of time.
  /// - Parameter withDelay: A closure that produces a value to use as the delay interval for this proxy.
  /// - Returns: The modified entity.
  func delay(with withDelay: @escaping (Proxy.Context) -> TimeInterval) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .delay(duration: withDelay(c)) }))
    return m
  }
  
  /// Sets the chance that this entity (if it contains an ``Emitter``) emits child entities for each scheduled spawn.
  /// This allows ``Emitter`` to have a more random effect when spawning proxies.
  /// When an Emitter is ready to spawn a new proxy, there is a `1 - value` probability the action will be skipped.
  /// The Emitter will wait again to spawn the next proxy.
  /// - parameter value: The chance , from `0.0` to `1.0`, underlying emitters spawn children on their timers. Default `1.0`.
  func emitChance(_ value: Double) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom({ c in .emitChance(max(min(value, 1), 0)) }))
    return m
  }
}
