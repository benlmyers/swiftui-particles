//
//  TransitionEntity.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import Foundation

internal struct TransitionEntity<E>: Entity where E: Entity {
  internal private(set) var transition: AnyTransition
  internal private(set) var bounds: TransitionBounds
  internal private(set) var duration: TimeInterval
  var body: E
  init(
    entity: E,
    transition: AnyTransition,
    bounds: TransitionBounds,
    duration: TimeInterval
  ) {
    self.body = entity
    self.transition = transition
    self.bounds = bounds
    self.duration = duration
  }
}
