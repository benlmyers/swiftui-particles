//
//  Emitter.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import Foundation

public struct Emitter: Entity {
  public var body: EmptyEntity { .init() }
  internal private(set) var prototype: AnyEntity
  internal private(set) var emitInterval: TimeInterval
  public init<E>(interval: TimeInterval, @EntityBuilder emits: () -> E) where E: Entity {
    self.emitInterval = interval
    self.prototype = .init(body: emits())
  }
}
