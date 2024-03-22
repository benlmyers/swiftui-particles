//
//  ScaleTransition.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import SwiftUI
import Foundation

public struct ScaleTransition: Transition {
  public func modifyRender(progress: Double, physics: PhysicsProxy.Context, context: inout GraphicsContext) {
    context.scaleBy(x: 1 - progress, y: 1 - progress)
  }
}

public extension Particles.AnyTransition {
  static var scale: AnyTransition {
    return .init(ScaleTransition())
  }
}
