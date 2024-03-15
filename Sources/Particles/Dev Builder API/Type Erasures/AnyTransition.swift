//
//  AnyTransition.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import Foundation

/// A type-erased ``Transition`` struct.
public struct AnyTransition {
  
  internal private(set) var withPhysics: (PhysicsProxy.Context, Int, TransitionBound) -> PhysicsProxy
  internal private(set) var withRender: (RenderProxy.Context, Int, TransitionBound) -> RenderProxy
  
  public init<T>(_ transition: T) where T: Transition {
    self.withPhysics = transition.withPhysics
    self.withRender = transition.withRender
  }
}
