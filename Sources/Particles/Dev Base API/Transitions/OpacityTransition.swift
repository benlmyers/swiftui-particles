//
//  OpacityTransition.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import Foundation

public struct OpacityTransition: Transition {
  
  public func withPhysics(_ context: PhysicsProxy.Context, frames: Int, untilEndOf bound: TransitionBound) -> PhysicsProxy {
    return context.physics
  }
  
  public func withRender(_ context: RenderProxy.Context, frames: Int, untilEndOf bound: TransitionBound) -> RenderProxy {
    var r = context.render
    print("\(frames)" + " " + (bound == .birth ? "b" : "d"))
    if context.physics.inception + 1 == context.system.currentFrame && bound == .birth {
      r.opacity = 0.001
    } else if frames > 0 {
      switch bound {
      case .birth:
        r.opacity += (1.0 - r.opacity) / Double(frames)
        break
      case .death:
        r.opacity -= r.opacity / Double(frames)
      }
    }
    return r
  }
}

public extension AnyTransition {
  static var opacity: AnyTransition {
    return .init(OpacityTransition())
  }
}
