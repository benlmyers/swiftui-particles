//
//  ScaleTransition.swift
//
//
//  Created by Ben Myers on 3/14/24.
//

import SwiftUI
import Foundation

/// A transition modifying the scale of an entity.
public struct ScaleTransition: Transition {
  public func modifyRender(progress: Double, physics: Proxy.Context, context: inout GraphicsContext) {
    context.scaleBy(x: 1 - progress, y: 1 - progress)
  }
}

public extension Particles.AnyTransition {
  static var scale: AnyTransition {
    return .init(ScaleTransition())
  }
}
