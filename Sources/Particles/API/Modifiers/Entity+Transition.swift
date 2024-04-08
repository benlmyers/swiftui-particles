//
//  Entity+Transition.swift
//  
//
//  Created by Ben Myers on 3/10/24.
//

import Foundation

public extension Entity {
  
  /// Applies a transition to this entity.
  /// Transitions are applied near an entity's birth and/or death, and you customize how long their duration is.
  /// - Parameter transition: The transition to apply.
  /// - Parameter bounds: The bounds to apply the transition to.
  /// - Parameter duration: The duration, in seconds, of the transition.
  func transition(_ transition: AnyTransition, on bounds: TransitionBounds = .birthAndDeath, duration: TimeInterval = 0.5) -> some Entity {
    var m = ModifiedEntity(entity: self)
    m.preferences.append(.custom(.transition(transition: transition, bounds: bounds, duration: duration)))
    return m
  }
}
