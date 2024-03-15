//
//  Entity+Transition.swift
//
//
//  Created by Ben Myers on 3/10/24.
//

import Foundation

public extension Entity {
  
  func transition(_ transition: AnyTransition, duration: TimeInterval = 1.0, onBirth: Bool = false, onDeath: Bool = false) -> some Entity {
    return ModifiedEntity(entity: self, onUpdatePhysics: { context in
      if let (frames, bound) = getFramesToNearestBound(context: context, duration: duration, birth: onBirth, death: onDeath) {
        return transition.withPhysics(context, frames, bound)
      } else {
        return context.physics
      }
    }, onUpdateRender: { context in
      let pp = PhysicsProxy.Context(physics: context.physics, system: context.system)
      if let (frames, bound) = getFramesToNearestBound(context: pp, duration: duration, birth: onBirth, death: onDeath) {
        return transition.withRender(context, frames, bound)
      } else {
        return context.render
      }
    })
  }
  
  func transition(_ transition: AnyTransition, duration: TimeInterval = 1.0) -> some Entity {
    self.transition(transition, duration: duration, onBirth: true, onDeath: true)
  }
}

fileprivate func getFramesToNearestBound(context: PhysicsProxy.Context, duration: TimeInterval, birth: Bool, death: Bool) -> (Int, TransitionBound)? {
  if death {
    let end: Int = Int(Double(context.physics.inception) + context.physics.lifetime * context.system.fps)
    let frames: Int = end - context.system.currentFrame
    if frames < Int(duration * context.system.fps), frames > 0 {
      return (frames, .death)
    }
  }
  if birth {
    let end: Int = Int(Double(context.physics.inception) + duration * context.system.fps)
    let frames: Int = end - context.system.currentFrame
    if frames < Int(duration * context.system.fps) && frames > 0 {
      return (frames, .birth)
    }
  }
  return nil
}
