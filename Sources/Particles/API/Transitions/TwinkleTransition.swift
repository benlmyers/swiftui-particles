//
//  TwinkleTransition.swift
//
//
//  Created by Ben Myers on 3/21/24.
//

import SwiftUI
import Foundation

/// A transition modifying the opacity of an entity, making a twinkle effect.
public struct TwinkleTransition: Transition {
  public func modifyRender(progress: Double, physics: Proxy.Context, context: inout GraphicsContext) {
    let r = Double.random(in: 0.0 ... 1.0, seed: physics.proxy.seed.0)
    context.opacity = max(min((1 - progress) + 0.5 * sqrt(1 - progress) * sin(40 * progress + 40 * r), 1), 0)
  }
}

public extension Particles.AnyTransition {
  static var twinkle: AnyTransition {
    return .init(TwinkleTransition())
  }
}
