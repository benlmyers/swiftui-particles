//
//  Transition.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import Foundation

public protocol Transition {
  func withPhysics(_ context: PhysicsProxy.Context, frames: Int, untilEndOf bound: TransitionBound) -> PhysicsProxy
  func withRender(_ context: RenderProxy.Context, frames: Int, untilEndOf bound: TransitionBound) -> RenderProxy
}

public enum TransitionBound {
  case birth
  case death
}
