//
//  OpacityTransition.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import SwiftUI
import Foundation

/// A transition modifying the opacity of an entity.
public struct OpacityTransition: Transition {
  public func modifyRender(progress: Double, physics: PhysicsProxy.Context, context: inout GraphicsContext) {
    context.opacity = 1 - progress
  }
}

public extension Particles.AnyTransition {
  static var opacity: AnyTransition {
    return .init(OpacityTransition())
  }
}
